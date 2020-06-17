version 1.0

import "tasks/wgs.wdl" as one

workflow gtx_one {

    input {
        # sequence reads pair
        File fastq1
        File fastq2

        # pre-built genome index files
        Array[File?] genome_indexes

        Array[File?] known_sites

        # genomic intervals
        File? intervals

        # experiments info
        String reads_group
        String sample_id

        # parameters
        Boolean is_identify_with_bwa = false
        Boolean is_output_bam = false
        Boolean is_gvcf = false
        Boolean is_bqsr = false

        Int? score_for_match
        Int? penalty_for_mismatch
        Int? gap_extension_penalty
        Int? gap_open_penalty
        Int? threads
    
        # Resource
        Int sys_disk_size = 200
        Int data_disk_size = 500
    
    }

    call one.wgs as wgs {
        input:
            fastq1 = fastq1,
            fastq2 = fastq2,
            genome_indexes = genome_indexes,
            known_sites = known_sites,
            intervals = intervals,
            reads_group = reads_group,
            sample_id = sample_id,
            is_identify_with_bwa = is_identify_with_bwa,
            is_output_bam = is_output_bam,
            is_gvcf = is_gvcf,
            is_bqsr = is_bqsr,
            score_for_match = score_for_match,
            gap_extension_penalty = gap_extension_penalty,
            gap_open_penalty = gap_open_penalty,
            threads =  threads,
            sys_disk_size = sys_disk_size,
            data_disk_size = data_disk_size
    }

    output {
        Pair[File, File] alignment = wgs.alignment
        File variants = wgs.variants
    }

}


