version 1.0
import "tasks/index.wdl" as index
import "tasks/align.wdl" as align
import "tasks/vc.wdl" as vc


workflow fastq2vcf_without_index {
    input {
        # sequence reads pair
        File fastq1
        File fastq2

        # genome fasta
        File genome_fasta

        # genomic intervals
        File? intervals

        # experiments info
        String reads_group
        String sample_id

        # parameters
        Boolean disable_bwa_index = false
        Boolean is_identify_with_bwa = false
        Boolean is_mark_duplicate = false
        Boolean is_gvcf = false

        Int? score_for_match
        Int? penalty_for_mismatch
        Int? gap_extension_penalty
        Int? gap_open_penalty
        Int? threads
    
        # Resource
        # Int sys_disk_size = 200
        # Int data_disk_size = 500
    
    }

    call index.index as build_index {
        input:
            genome_fasta = genome_fasta,
    }

    call align.align as sequence_align {
        input:
            fastq1 = fastq1,
            fastq2 = fastq2,
            genome_indexes = build_index.indexes,
            reads_group = reads_group,
            sample_id = sample_id,
            is_identify_with_bwa = is_identify_with_bwa,
            is_mark_duplicate = is_mark_duplicate,
            score_for_match = score_for_match,
            penalty_for_mismatch = penalty_for_mismatch,
            gap_extension_penalty = gap_extension_penalty,
            gap_open_penalty = gap_open_penalty
    }

    call vc.vc as vairant_calling {
        input:
            bam = sequence_align.bam,
            genome_indexes = build_index.indexes,
            sample_id = sample_id,
            intervals = intervals,
            is_gvcf = is_gvcf,
            threads = threads
    } 

    output {

        Pair[File, File ] bam = sequence_align.bam
        File vcf = vairant_calling.vcf

    }
}
