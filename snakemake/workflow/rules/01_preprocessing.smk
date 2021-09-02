"""
Snakemake rule file to preprocess Illumina sequence data for virome analysis.

What is accomplished with these rules?
    - Non-biological sequence removal (primers, adapters)
    - Host sequence removal
    - Removal of redundant sequences (clustering)
        - Creation of sequence count table
        - Calculation of sequence properties (e.g. GC content, tetramer frequencies)

Rob Edwards, Jan 2020
Updated: Scott Handley, March 2021
Updated: Michael Roach, Q2/3 2021
"""

import os
import sys
    
# NOTE: bbtools uses "threads=auto" by default that typically uses all threads, so no need to specify. 
# -Xmx is used to specify the memory allocation for bbtools operations
# Set your -Xmx specifications in your configuration file 

rule remove_5prime_primer:
    """Step 01: Remove 5' primer.
    
    Default RdA/B Primer sequences are provided in the file primerB.fa. If your lab uses other primers you will need to
    place them in CONPATH (defined in the Hecatomb.smk) and change the file name from primerB.fa to your file name below.
    """
    input:
        r1 = os.path.join(READDIR, PATTERN_R1 + file_extension),
        r2 = os.path.join(READDIR, PATTERN_R2 + file_extension),
        primers = os.path.join(CONPATH, "primerB.fa")
    output:
        r1 = temp(os.path.join(TMPDIR, "step_01", f"{PATTERN_R1}.s1.out.fastq")),
        r2 = temp(os.path.join(TMPDIR, "step_01", f"{PATTERN_R2}.s1.out.fastq")),
        stats = os.path.join(STATS, "step_01", "{sample}.s1.stats.tsv")
    benchmark:
        os.path.join(BENCH, "remove_leftmost_primerB.{sample}.txt")
    log:
        os.path.join(STDERR, "remove_leftmost_primerB.{sample}.log")
    resources:
        mem_mb=BBToolsMem
    threads:
        BBToolsCPU
    conda:
        "../envs/bbmap.yaml"
    shell:
        """
        bbduk.sh in={input.r1} in2={input.r2} \
            ref={input.primers} \
            out={output.r1} out2={output.r2} \
            stats={output.stats} \
            k=16 hdist=1 mink=11 ktrim=l restrictleft=20 \
            removeifeitherbad=f trimpolya=10 ordered=t rcomp=f ow=t \
            threads={threads} -Xmx{resources.mem_mb}m 2> {log}
        """

rule remove_3prime_contaminant:
    """Step 02: Remove 3' read through contaminant. 
    
    This is sequence that occurs if the library fragment is shorter than 250 bases and the sequencer reads through the 
    the 3' end. We use the full length of primerB plus 6 bases of the adapter to detect this event and remove everything
    to the right of that molecule when detected.
    """
    input:
        r1 = os.path.join(TMPDIR, "step_01", f"{PATTERN_R1}.s1.out.fastq"),
        r2 = os.path.join(TMPDIR, "step_01", f"{PATTERN_R2}.s1.out.fastq"),
        primers = os.path.join(CONPATH, "rc_primerB_ad6.fa")
    output:
        r1 = temp(os.path.join(TMPDIR, "step_02", f"{PATTERN_R1}.s2.out.fastq")),
        r2 = temp(os.path.join(TMPDIR, "step_02", f"{PATTERN_R2}.s2.out.fastq")),
        stats = os.path.join(STATS, "step_02", "{sample}.s2.stats.tsv")
    benchmark:
        os.path.join(BENCH, "remove_3prime_contaminant.{sample}.txt")
    log:
        os.path.join(STDERR, "remove_3prime_contaminant.{sample}.log")
    resources:
        mem_mb=BBToolsMem
    threads:
        BBToolsCPU
    conda:
        "../envs/bbmap.yaml"
    shell:
        """
        bbduk.sh in={input.r1} in2={input.r2} \
            ref={input.primers} \
            out={output.r1} out2={output.r2} \
            stats={output.stats} \
            k=16 hdist=1 mink=11 ktrim=r removeifeitherbad=f ordered=t rcomp=f ow=t \
            threads={threads} -Xmx{resources.mem_mb}m 2> {log}
        """

rule remove_primer_free_adapter:
    """Step 03: Remove primer free adapter (both orientations). 
    
    Rarely the adapter will be seen in the molecule indpendent of the primer. This removes those instances as well as 
    everything to the right of the detected primer-free adapter.
    """
    input:
        r1 = os.path.join(TMPDIR, "step_02", f"{PATTERN_R1}.s2.out.fastq"),
        r2 = os.path.join(TMPDIR, "step_02", f"{PATTERN_R2}.s2.out.fastq"),
        primers = os.path.join(CONPATH, "nebnext_adapters.fa")
    output:
        r1 = temp(os.path.join(TMPDIR, "step_03", f"{PATTERN_R1}.s3.out.fastq")),
        r2 = temp(os.path.join(TMPDIR, "step_03", f"{PATTERN_R2}.s3.out.fastq")),
        stats = os.path.join(STATS, "step_03", "{sample}.s3.stats.tsv")
    benchmark:
        os.path.join(BENCH, "remove_primer_free_adapter.{sample}.txt")
    log:
        os.path.join(STDERR, "remove_primer_free_adapter.{sample}.log")
    resources:
        mem_mb=BBToolsMem
    threads:
        BBToolsCPU
    conda:
        "../envs/bbmap.yaml"
    shell:
        """
        bbduk.sh in={input.r1} in2={input.r2} \
            ref={input.primers} \
            out={output.r1} out2={output.r2} \
            stats={output.stats} \
            k=16 hdist=1 mink=10 ktrim=r removeifeitherbad=f ordered=t rcomp=t ow=t \
            threads={threads} -Xmx{resources.mem_mb}m 2> {log}
        """

rule remove_adapter_free_primer:
    """Step 04: Remove adapter free primer (both orientations). 
    
    Rarely the primer is detected without the primer. This removes those instances as well as everything to the right 
    of the detected adapter-free primer. 
    """
    input:
        r1 = os.path.join(TMPDIR, "step_03", f"{PATTERN_R1}.s3.out.fastq"),
        r2 = os.path.join(TMPDIR, "step_03", f"{PATTERN_R2}.s3.out.fastq"),
        primers = os.path.join(CONPATH, "rc_primerB_ad6.fa")
    output:
        r1 = temp(os.path.join(TMPDIR, "step_04", f"{PATTERN_R1}.s4.out.fastq")),
        r2 = temp(os.path.join(TMPDIR, "step_04", f"{PATTERN_R2}.s4.out.fastq")),
        stats = os.path.join(STATS, "step_04", "{sample}.s4.stats.tsv")
    benchmark:
        os.path.join(BENCH, "remove_adapter_free_primer.{sample}.txt")
    log:
        os.path.join(STDERR, "remove_adapter_free_primer.{sample}.log")
    resources:
        mem_mb=BBToolsMem
    threads:
        BBToolsCPU
    conda:
        "../envs/bbmap.yaml"
    shell:
        """
        bbduk.sh in={input.r1} in2={input.r2} \
            ref={input.primers} \
            out={output.r1} out2={output.r2} \
            stats={output.stats} \
            k=16 hdist=0 removeifeitherbad=f ordered=t rcomp=t ow=t \
            threads={threads} -Xmx{resources.mem_mb}m 2> {log}
        """

rule remove_vector_contamination:
    """Step 05: Vector contamination removal (PhiX + NCBI UniVecDB)"""
    input:
        r1 = os.path.join(TMPDIR, "step_04", f"{PATTERN_R1}.s4.out.fastq"),
        r2 = os.path.join(TMPDIR, "step_04", f"{PATTERN_R2}.s4.out.fastq"),
        primers = os.path.join(CONPATH, "vector_contaminants.fa")
    output:
        r1 = temp(os.path.join(TMPDIR, "step_05", f"{PATTERN_R1}.s5.out.fastq")),
        r2 = temp(os.path.join(TMPDIR, "step_05", f"{PATTERN_R2}.s5.out.fastq")),
        stats = os.path.join(STATS, "step_05", "{sample}.s5.stats.tsv")
    benchmark:
        os.path.join(BENCH, "PREPROCESSING", "s05.remove_vector_contamination_{sample}.txt")
    log:
        log = os.path.join(STDERR, "step_05", "s5_{sample}.log")
    resources:
        mem_mb=BBToolsMem
    threads:
        BBToolsCPU
    conda:
        "../envs/bbmap.yaml"
    shell:
        """
        bbduk.sh in={input.r1} in2={input.r2} \
            ref={input.primers} \
            out={output.r1} out2={output.r2} \
            stats={output.stats} \
            k=31 hammingdistance=1 ordered=t ow=t \
            threads={threads} -Xmx{resources.mem_mb}m 2> {log};
        """
        
rule remove_low_quality:
    """Step 06: Remove remaining low-quality bases and short reads. 
    
    Quality score can be modified in config.yaml (QSCORE).
    """
    input:
        r1 = os.path.join(TMPDIR, "step_05", f"{PATTERN_R1}.s5.out.fastq"),
        r2 = os.path.join(TMPDIR, "step_05", f"{PATTERN_R2}.s5.out.fastq")
    output:
        r1 = temp(os.path.join(TMPDIR, "step_06", f"{PATTERN_R1}.s6.out.fastq")),
        r2 = temp(os.path.join(TMPDIR, "step_06", f"{PATTERN_R2}.s6.out.fastq")),
        stats = os.path.join(STATS, "step_06", "{sample}.s6.stats.tsv")
    benchmark:
        os.path.join(BENCH, "PREPROCESSING", "s06.remove_low_quality_{sample}.txt")
    log:
        log = os.path.join(STDERR, "step_06", "s6_{sample}.log")
    resources:
        mem_mb=BBToolsMem
    threads:
        BBToolsCPU
    conda:
        "../envs/bbmap.yaml"
    shell:
        """
        bbduk.sh in={input.r1} in2={input.r2} \
            out={output.r1} out2={output.r2} \
            stats={output.stats} \
            ordered=t \
            qtrim=r maxns=2 \
            entropy={config[ENTROPY]} \
            entropywindow={config[ENTROPYWINDOW]} \
            trimq={config[QSCORE]} \
            minlength={config[READ_MINLENGTH]} \
            threads={threads} -Xmx{resources.mem_mb}m 2> {log};
        """

rule create_host_index:
    """Create the minimap2 index for mapping to the host; this will save time."""
    input:
        HOSTFA,
        # os.path.join(CONPATH, "line_sine.fasta") ########### TODO: check implementation
    output:
        HOSTINDEX
    benchmark:
        os.path.join(BENCH, "create_host_index.txt")
    log:
        os.path.join(STDERR, 'create_host_index.log')
    resources:
        mem_mb=BBToolsMem
    threads:
        BBToolsCPU
    conda:
        "../envs/minimap2.yaml"
    shell:
        "minimap2 -t {threads} -d {output} <(cat {input})"

rule host_removal_mapping:
    """Step 07a: Host removal: mapping to host. 
    
    Must define host in config file (see Paths: Host: in config.yaml). Host should be masked of viral sequence.
    If your reference is not available you need to add it using 'Hecatomb addHost'
    """
    input:
        r1 = os.path.join(TMPDIR, "step_06", f"{PATTERN_R1}.s6.out.fastq"),
        r2 = os.path.join(TMPDIR, "step_06", f"{PATTERN_R2}.s6.out.fastq"),
        host = HOSTINDEX
    output:
        r1 = temp(os.path.join(QC, "HOST_REMOVED", f"{PATTERN_R1}.unmapped.fastq")),
        r2 = temp(os.path.join(QC, "HOST_REMOVED", f"{PATTERN_R2}.unmapped.fastq")),
        s = temp(os.path.join(QC, "HOST_REMOVED", f"{PATTERN_R1}.unmapped.singletons.fastq")),
        o = temp(os.path.join(QC, "HOST_REMOVED", f"{PATTERN_R1}.other.singletons.fastq"))
    benchmark:
        os.path.join(BENCH, "host_removal_mapping.{sample}.txt")
    log:
        mm=os.path.join(STDERR, "host_removal_mapping.{sample}.minimap.log"),
        sv=os.path.join(STDERR, "host_removal_mapping.{sample}.samtoolsView.log"),
        fq=os.path.join(STDERR, "host_removal_mapping.{sample}.samtoolsFastq.log")
    resources:
        mem_mb=BBToolsMem
    threads:
        BBToolsCPU
    conda:
        "../envs/minimap2.yaml"
    shell:
        """
        minimap2 -ax sr -t {threads} --secondary=no {input.host} {input.r1} {input.r2} 2> {log.mm} \
            | samtools view -f 4 -h 2> {log.sv} \
            | samtools fastq -NO -1 {output.r1} -2 {output.r2} -0 {output.o} -s {output.s} 2> {log.fq}
        """

# rule extract_host_unmapped:
#     """Step 07b: Extract unmapped (non-host) sequences from sam files"""
#     input:
#         sam = os.path.join(QC, "HOST_REMOVED", PATTERN_R1 + ".sam")
#     output:
#         r1 = temp(os.path.join(QC, "HOST_REMOVED", PATTERN_R1 + ".unmapped.fastq")),
#         r2 = temp(os.path.join(QC, "HOST_REMOVED", PATTERN_R2 + ".unmapped.fastq")),
#         singletons = temp(os.path.join(QC, "HOST_REMOVED", PATTERN_R1 + ".unmapped.singletons.fastq"))
#     benchmark:
#         os.path.join(BENCH, "PREPROCESSING", "s07b.extract_host_unmapped_{sample}.txt")
#     log:
#         log = os.path.join(LOGS, "step_07b", "s07b_{sample}.log")
#
#     resources:
#         mem_mb=100000,
#         cpus=64
#     conda:
#         "../envs/samtools.yaml"
#     shell:
#         """
#         samtools fastq --threads {resources.cpus} -NO -1 {output.r1} -2 {output.r2} \
#         -0 /dev/null \
#         -s {output.singletons} \
#         {input.sam} 2> {log};
#         """

rule nonhost_read_repair:
    """Step 07b: Parse R1/R2 singletons (if singletons at all)"""
    input:
        s = os.path.join(QC, "HOST_REMOVED", f"{PATTERN_R1}.unmapped.singletons.fastq"),
        o = os.path.join(QC, "HOST_REMOVED", f"{PATTERN_R1}.other.singletons.fastq")
    output:
        sr1 = temp(os.path.join(QC, "HOST_REMOVED", f"{PATTERN_R1}.u.singletons.fastq")),
        sr2 = temp(os.path.join(QC, "HOST_REMOVED", f"{PATTERN_R2}.u.singletons.fastq")),
        or1 = temp(os.path.join(QC, "HOST_REMOVED", f"{PATTERN_R1}.o.singletons.fastq")),
        or2 = temp(os.path.join(QC, "HOST_REMOVED", f"{PATTERN_R2}.o.singletons.fastq"))
    benchmark:
        os.path.join(BENCH, "PREPROCESSING", "s07c.nonhost_read_repair_{sample}.txt")
    log:
        log = os.path.join(STDERR, "step_07c", "s07c_{sample}.log")
    resources:
        mem_mb=BBToolsMem
    threads:
        BBToolsCPU
    conda:
        "../envs/bbmap.yaml"
    shell:
        """
        reformat.sh in={input.s} out={output.sr1} out2={output.sr2} \
            -Xmx{resources.mem_mb}m 2> {log};
        reformat.sh in={input.o} out={output.or1} out2={output.or2} \
            -Xmx{resources.mem_mb}m 2> {log};
        """

rule nonhost_read_combine:
    """Step 07c: Combine paired and singleton reads."""
    input:
        r1 = os.path.join(QC, "HOST_REMOVED", f"{PATTERN}_R1.unmapped.fastq"),
        r2 = os.path.join(QC, "HOST_REMOVED", f"{PATTERN}_R2.unmapped.fastq"),
        sr1 = os.path.join(QC, "HOST_REMOVED", f"{PATTERN}_R1.u.singletons.fastq"),
        sr2 = os.path.join(QC, "HOST_REMOVED", f"{PATTERN}_R2.u.singletons.fastq"),
        or1 = os.path.join(QC, "HOST_REMOVED", f"{PATTERN}_R1.o.singletons.fastq"),
        or2 = os.path.join(QC, "HOST_REMOVED", f"{PATTERN}_R2.o.singletons.fastq")
    output:
        t1 = os.path.join(QC, "HOST_REMOVED", f"{PATTERN}_R1.singletons.fastq"),
        t2 = os.path.join(QC, "HOST_REMOVED", f"{PATTERN}_R2.singletons.fastq"),
        r1 = os.path.join(QC, "HOST_REMOVED", f"{PATTERN}_R1.all.fastq"),
        r2 = os.path.join(QC, "HOST_REMOVED", f"{PATTERN}_R2.all.fastq")
    benchmark:
        os.path.join(BENCH, "PREPROCESSING", f"s07d.nonhost_read_combine_{PATTERN}.txt")
    shell:
        """
        cat {input.sr1} {input.or1} > {output.t1};
        cat {input.sr2} {input.or2} > {output.t2};
        cat {input.r1} {output.t1} > {output.r1};
        cat {input.r2} {output.t2} > {output.r2};
        """

rule remove_exact_dups:
    """Step 08: Remove exact duplicates
    
    Exact duplicates are considered PCR generated and not accounted for in the count table (seqtable_all.tsv)
    """
    input:
        os.path.join(QC, "HOST_REMOVED", f"{PATTERN_R1}.all.fastq")
    output:
        temp(os.path.join(QC, "CLUSTERED", f"{PATTERN_R1}.deduped.out.fastq"))
    benchmark:
        os.path.join(BENCH, "remove_exact_dups.{sample}.txt")
    log:
        os.path.join(STDERR, "remove_exact_dups.{sample}.log")
    resources:
        mem_mb=BBToolsMem
    threads:
        BBToolsCPU
    conda:
        "../envs/bbmap.yaml"
    shell:
        """
        dedupe.sh in={input} out={output} \
            ac=f ow=t \
            threads={threads} -Xmx{resources.mem_mb}m 2> {log}
        """
          
rule cluster_similar_sequences: ### TODO: CHECK IF WE STILL HAVE ANY READS LEFT AT THIS POINT
    """Step 09: Cluster similar sequences.
     
     Sequences clustered at CLUSTERID in config.yaml.
    """
    input:
        os.path.join(QC, "CLUSTERED", f"{PATTERN_R1}.deduped.out.fastq")
    output:
        temp(os.path.join(QC, "CLUSTERED", f"{PATTERN_R1}_rep_seq.fasta")),
        temp(os.path.join(QC, "CLUSTERED", f"{PATTERN_R1}_cluster.tsv")),
        temp(os.path.join(QC, "CLUSTERED", f"{PATTERN_R1}_all_seqs.fasta"))
    params:
        respath=os.path.join(QC, "CLUSTERED"),
        tmppath=os.path.join(QC, "CLUSTERED", "{sample}_TMP"),
        prefix=PATTERN_R1
    benchmark:
        os.path.join(BENCH, "cluster_similar_sequences.{sample}.txt")
    log:
        os.path.join(STDERR, "cluster_similar_sequences.{sample}.log")
    resources:
        mem_mb=MMSeqsMem
    threads:
        MMSeqsCPU
    conda:
        "../envs/mmseqs2.yaml"
    shell:
        """ 
        mmseqs easy-linclust {input} {params.respath}/{params.prefix} {params.tmppath} \
            --kmer-per-seq-scale 0.3 \
            -c {config[CLUSTERID]} --cov-mode 1 --threads {threads} &>> {log};
        """
        
rule create_individual_seqtables:
    """Step 10: Create individual seqtables. 
    
    A seqtable is a count table with each sequence as a row, each column as a sample and each cell the counts of each 
    sequence per sample.
    """
    input:
        seqs = os.path.join(QC, "CLUSTERED", f"{PATTERN_R1}_rep_seq.fasta"),
        counts = os.path.join(QC, "CLUSTERED", f"{PATTERN_R1}_cluster.tsv")
    output:
        seqs = temp(os.path.join(QC, "CLUSTERED", f"{PATTERN_R1}.seqs")),
        counts = temp(os.path.join(QC, "CLUSTERED", f"{PATTERN_R1}.counts")),
        seqtable = temp(os.path.join(QC, "CLUSTERED", f"{PATTERN_R1}.seqtable"))
    benchmark:
        os.path.join(BENCH, "create_individual_seqtables.{sample}.txt")
    resources:
        mem_mb=BBToolsMem
    threads:
        BBToolsCPU
    conda:
        "../envs/seqkit.yaml"
    shell:
        """
        seqkit sort {input.seqs} --quiet -j {threads} -w 5000 -t dna \
            | seqkit fx2tab -w 5000 -t dna \
            | sed 's/\\t\\+$//' \
            | cut -f2,3 \
            | sed '1i sequence' > {output.seqs};
        cut -f1 {input.counts} \
            | sort \
            | uniq -c \
            | awk -F ' ' '{{print$2"\\t"$1}}' \
            | cut -f2 \
            | sed "1i {wildcards.sample}" > {output.counts};
        paste {output.seqs} {output.counts} > {output.seqtable};
        """


rule merge_seq_table:
    """Step 11: Merge seq tables
    
    Reads the sequences and counts from each samples' seqtable text file and converts to fasta format for the rest of 
    the pipline.
    """
    input:
        expand(os.path.join(QC, "CLUSTERED", "{sample}_R1.seqtable"), sample=SAMPLES)
    output:
        fa = os.path.join(RESULTS, "seqtable.fasta"),
        tsv = os.path.join(RESULTS, "sampleSeqCounts.tsv")
    params:
        resultsdir = directory(RESULTS),
    benchmark:
        os.path.join(BENCH, "merge_seq_table.txt")
    run:
        outFa = open(output.fa, 'w')
        outTsv = open(output.tsv, 'w')
        for sample in SAMPLES:
            seqId = 0
            seqCounts = 0
            counts = open(os.path.join(QC, "CLUSTERED", f"{sample}_R1.seqtable"), 'r')
            line = counts.readline() # skip header
            for line in counts:
                l = line.split()
                id = ':'.join((sample, l[1], str(seqId))) # fasta header = >sample:count:seqId
                seqCounts += int(l[1])
                seqId = seqId + 1
                outFa.write(f'>{id}\n{l[0]}\n')
            counts.close()
            outTsv.write(f'{sample}\t{seqCounts}\n')
        outFa.close()
        outTsv.close()

