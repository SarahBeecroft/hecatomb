"""
All target output files for Hecatomb are declared here
"""

# Preprocessing files
PreprocessingFiles = [
    # os.path.join(RESULTS, "seqtable_all.tsv"),
    os.path.join(RESULTS, "seqtable.fasta"),
    os.path.join(RESULTS, "sampleSeqCounts.tsv"),
    # os.path.join(RESULTS, "seqtable.counts.tsv"),
    # os.path.join(RESULTS, "seqtable.stats"),
    # os.path.join(RESULTS, "seqtable.fasta.fai"),
    # os.path.join(RESULTS, "seqtable.properties.gc"),
    # os.path.join(RESULTS, "seqtable.properties.tetramer"),
    os.path.join(RESULTS, "seqtable.properties.tsv")]

if doAssembly:
    # Assembly files
    AssemblyFiles = [
        expand(os.path.join(ASSEMBLY, PATTERN_R1 + ".norm.fastq"), sample=SAMPLES),
        expand(os.path.join(ASSEMBLY, PATTERN_R2 + ".norm.fastq"), sample=SAMPLES),
        expand(os.path.join(ASSEMBLY, PATTERN, PATTERN + ".contigs.fa"), sample=SAMPLES),
        os.path.join(ASSEMBLY, "CONTIG_DICTIONARY", "all_megahit_contigs.fasta"),
        os.path.join(ASSEMBLY, "CONTIG_DICTIONARY", "all_megahit_contigs_size_selected.fasta"),
        os.path.join(ASSEMBLY, "CONTIG_DICTIONARY", "all_megahit_contigs.stats"),
        os.path.join(ASSEMBLY, "CONTIG_DICTIONARY", "FLYE", "assembly.fasta"),
        os.path.join(ASSEMBLY, "CONTIG_DICTIONARY", "FLYE", "contig_dictionary.stats"),
        expand(os.path.join(ASSEMBLY, "CONTIG_DICTIONARY", "MAPPING", PATTERN + ".aln.sam.gz"), sample=SAMPLES),
        expand(os.path.join(ASSEMBLY, "CONTIG_DICTIONARY", "MAPPING", PATTERN + ".unmapped.fastq"), sample=SAMPLES),
        expand(os.path.join(ASSEMBLY, "CONTIG_DICTIONARY", "MAPPING", PATTERN + ".cov_stats"), sample=SAMPLES),
        expand(os.path.join(ASSEMBLY, "CONTIG_DICTIONARY", "MAPPING", PATTERN + ".rpkm"), sample=SAMPLES),
        expand(os.path.join(ASSEMBLY, "CONTIG_DICTIONARY", "MAPPING", PATTERN + ".statsfile"), sample=SAMPLES),
        expand(os.path.join(ASSEMBLY, "CONTIG_DICTIONARY", "MAPPING", PATTERN + ".scafstats"), sample=SAMPLES),
        expand(os.path.join(ASSEMBLY, "CONTIG_DICTIONARY", "MAPPING", PATTERN + "_contig_counts.tsv"), sample=SAMPLES),
        os.path.join(ASSEMBLY, "CONTIG_DICTIONARY", "MAPPING",  "contig_count_table.tsv"),
        #os.path.join(RESULTS, "assembly.properties.gc"),
        #os.path.join(RESULTS, "assembly.properties.tetramer"),
        os.path.join(RESULTS, "assembly.properties.tsv")]
    # Congtig annotations
    ContigAnnotFiles = [
        os.path.join(ASSEMBLY,"CONTIG_DICTIONARY","FLYE","results","tophit.index"),
        os.path.join(ASSEMBLY,"CONTIG_DICTIONARY","FLYE","results","tophit.m8"),
        os.path.join(ASSEMBLY,"CONTIG_DICTIONARY","FLYE","SECONDARY_nt.tsv"),
        os.path.join(ASSEMBLY,"CONTIG_DICTIONARY","FLYE","SECONDARY_nt_phylum_summary.tsv"),
        os.path.join(ASSEMBLY,"CONTIG_DICTIONARY","FLYE","SECONDARY_nt_class_summary.tsv"),
        os.path.join(ASSEMBLY,"CONTIG_DICTIONARY","FLYE","SECONDARY_nt_order_summary.tsv"),
        os.path.join(ASSEMBLY,"CONTIG_DICTIONARY","FLYE","SECONDARY_nt_family_summary.tsv"),
        os.path.join(ASSEMBLY,"CONTIG_DICTIONARY","FLYE","SECONDARY_nt_genus_summary.tsv"),
        os.path.join(ASSEMBLY,"CONTIG_DICTIONARY","FLYE","SECONDARY_nt_species_summary.tsv")
    ]
    # Mapping files
    MappingFiles = [
        os.path.join(MAPPING, "assembly.seqtable.bam"),
        os.path.join(MAPPING, "assembly.seqtable.bam.bai"),
        os.path.join(RESULTS, "contigSeqTable.tsv"),
        # os.path.join(RESULTS, "contigKrona.txt"),
        os.path.join(RESULTS, "contigKrona.html")
    ]
else:
    AssemblyFiles = []
    ContigAnnotFiles = []
    MappingFiles = []

# Primary AA search files
PrimarySearchFilesAA = [
    os.path.join(PRIMARY_AA_OUT, "MMSEQS_AA_PRIMARY_lca.tsv"),
    os.path.join(PRIMARY_AA_OUT, "MMSEQS_AA_PRIMARY_report"),
    os.path.join(PRIMARY_AA_OUT, "MMSEQS_AA_PRIMARY_tophit_report"),
    os.path.join(PRIMARY_AA_OUT, "MMSEQS_AA_PRIMARY_tophit_aln"),
    os.path.join(PRIMARY_AA_OUT, "MMSEQS_AA_PRIMARY_tophit_aln_sorted"),
    os.path.join(PRIMARY_AA_OUT, "MMSEQS_AA_PRIMARY_classified.fasta"),
    os.path.join(PRIMARY_AA_OUT, "MMSEQS_AA_PRIMARY_unclassified.fasta"),
    # os.path.join(PRIMARY_AA_OUT, "MMSEQS_AA_PRIMARY_virus_order_summary.tsv"),
    # os.path.join(PRIMARY_AA_OUT, "MMSEQS_AA_PRIMARY_virus_family_summary.tsv"),
    # os.path.join(PRIMARY_AA_OUT, "MMSEQS_AA_PRIMARY_virus_genus_summary.tsv"),
    # os.path.join(PRIMARY_AA_OUT, "MMSEQS_AA_PRIMARY_virus_species_summary.tsv"),
    # os.path.join(PRIMARY_AA_OUT, "MMSEQS_AA_PRIMARY_tophit_only.tsv"),
    # os.path.join(PRIMARY_AA_OUT, "MMSEQS_AA_PRIMARY_tophit_broken_taxID.tsv"),
    # os.path.join(PRIMARY_AA_OUT, "MMSEQS_AA_PRIMARY_summary.tsv")
]

# Secondary AA search files
SecondarySearchFilesAA = [
    os.path.join(SECONDARY_AA_OUT, "MMSEQS_AA_SECONDARY_lca.tsv"),
    os.path.join(SECONDARY_AA_OUT, "MMSEQS_AA_SECONDARY_report"),
    os.path.join(SECONDARY_AA_OUT, "MMSEQS_AA_SECONDARY_tophit_report"),
    os.path.join(SECONDARY_AA_OUT, "MMSEQS_AA_SECONDARY_tophit_aln"),
    os.path.join(SECONDARY_AA_OUT, "MMSEQS_AA_SECONDARY_tophit_aln_sorted"),
    #os.path.join(SECONDARY_AA_OUT, "tophit.tax_tmp_updated.tsv"),
    os.path.join(SECONDARY_AA_OUT, "AA_bigtable.tsv"),
    # os.path.join(SECONDARY_AA_OUT, "tophit.kingdom.freq"),
    # os.path.join(SECONDARY_AA_OUT, "tophit.unclass_superkingdom.freq"),
    # os.path.join(SECONDARY_AA_OUT, "tophit.keyword_nonviral.freq"),
    # os.path.join(SECONDARY_AA_OUT, "tophit.keyword_nonviral.list"),
    # os.path.join(SECONDARY_AA_OUT, "tophit.keyword_bac.freq"),
    # os.path.join(SECONDARY_AA_OUT, "tophit.keyword_vir.freq"),
    # os.path.join(SECONDARY_AA_OUT, "tophit.keyword_vir.list"),
    # os.path.join(SECONDARY_AA_OUT, "tophit.keyword_all.list"),
    # os.path.join(SECONDARY_AA_OUT, "lca_virus_root.vir.tsv"),
    # os.path.join(SECONDARY_AA_OUT, "lca_unclass.vir.tsv"),
    # os.path.join(SECONDARY_AA_OUT, "translated_final.tsv"),
    # os.path.join(SECONDARY_AA_OUT, "translated_unclassified.fasta")
    ]

# Primary NT search files
PrimarySearchFilesNT = [
    os.path.join(PRIMARY_NT_OUT, "queryDB"),
    os.path.join(PRIMARY_NT_OUT, "results", "result.index"),
    os.path.join(PRIMARY_NT_OUT, "results", "firsthit.index"),
    os.path.join(PRIMARY_NT_OUT, "results", "result.m8"),
    os.path.join(PRIMARY_NT_OUT, "primary_nt.tsv"),
    # os.path.join(PRIMARY_NT_OUT, "primary_nt_phylum_summary.tsv"),
    # os.path.join(PRIMARY_NT_OUT, "primary_nt_class_summary.tsv"),
    # os.path.join(PRIMARY_NT_OUT, "primary_nt_class_summary.tsv"),
    # os.path.join(PRIMARY_NT_OUT, "primary_nt_order_summary.tsv"),
    # os.path.join(PRIMARY_NT_OUT, "primary_nt_family_summary.tsv"),
    # os.path.join(PRIMARY_NT_OUT, "primary_nt_genus_summary.tsv"),
    # os.path.join(PRIMARY_NT_OUT, "primary_nt_species_summary.tsv"),
    os.path.join(PRIMARY_NT_OUT, "classified_seqs.fasta"),
    os.path.join(PRIMARY_NT_OUT, "unclassified_seqs.fasta")]

# Secondary NT search files
SecondarySearchFilesNT = [
    os.path.join(SECONDARY_NT_OUT, "queryDB"),
    os.path.join(SECONDARY_NT_OUT, "results", "result.index"),
    os.path.join(SECONDARY_NT_OUT, "results", "tophit.index"),
    os.path.join(SECONDARY_NT_OUT, "results", "tophit.m8"),
    os.path.join(SECONDARY_NT_OUT, "SECONDARY_nt.tsv"),
    # os.path.join(SECONDARY_NT_OUT, "SECONDARY_nt_phylum_summary.tsv"),
    # os.path.join(SECONDARY_NT_OUT, "SECONDARY_nt_class_summary.tsv"),
    # os.path.join(SECONDARY_NT_OUT, "SECONDARY_nt_order_summary.tsv"),
    # os.path.join(SECONDARY_NT_OUT, "SECONDARY_nt_family_summary.tsv"),
    # os.path.join(SECONDARY_NT_OUT, "SECONDARY_nt_genus_summary.tsv"),
    # os.path.join(SECONDARY_NT_OUT, "SECONDARY_nt_species_summary.tsv"),
    os.path.join(SECONDARY_NT_OUT, "results","all.m8"),
    os.path.join(SECONDARY_NT_OUT, "results","lca.lineage"),
    os.path.join(SECONDARY_NT_OUT, "results","secondary_nt_lca.tsv"),
    os.path.join(SECONDARY_NT_OUT, "NT_bigtable.tsv"),
    os.path.join(RESULTS, "bigtable.tsv"),
    # os.path.join(RESULTS, "kronaText.tsv"),
    os.path.join(RESULTS, "krona.html")]

# Summary files
SummaryFiles = [
    #os.path.join(SUMDIR, "taxonLevelCounts.tsv"),
    os.path.join(SUMDIR, "Step00_counts.tsv"),
    os.path.join(SUMDIR, "Step01_counts.tsv"),
    os.path.join(SUMDIR, "Step02_counts.tsv"),
    os.path.join(SUMDIR, "Step03_counts.tsv"),
    os.path.join(SUMDIR, "Step04_counts.tsv"),
    os.path.join(SUMDIR, "Step05_counts.tsv"),
    os.path.join(SUMDIR, "Step06_counts.tsv"),
    os.path.join(SUMDIR, "Step07_counts.tsv"),
    os.path.join(SUMDIR, "Step08_counts.tsv"),
    os.path.join(SUMDIR, "Step09_counts.tsv"),
    os.path.join(SUMDIR, "Step10_counts.tsv"),
    os.path.join(SUMDIR, "Step11_counts.tsv"),
    os.path.join(SUMDIR, "Step12_counts.tsv"),
    os.path.join(SUMDIR, "Step13_counts.tsv"),
    os.path.join(SUMDIR, "Sankey.svg"),
    os.path.join(SUMDIR, "taxonLevelCounts.tsv")
]
