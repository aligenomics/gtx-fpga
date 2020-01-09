version 1.0

# all copyrights reserved
#  -o    <file>  output BAM file
#  -R    <str>   read group header line such as '@RG\tID:foo\tSM:bar'

#  -A    <int>   score for a sequence match, default [1]
#  -B    <int>   penalty for mismatch, default [4]
#  -O    <int>   gap open penalty, default [6]
#  -E    <int>   gap extension penalty, default [1]
#  -t    <int>   the number of threads, default [72]

#  --bwa         align reads with precision comparable to BWA-mem
#  --disable-mark-duplicate     disable mark duplicate
#  --gtz-rbin1 <file> a gtz's rbin file for fastq.gtz file.
#  --gtz-rbin2 <file> a gtz's rbin file for fastq2.gtz file if it's not same as fastq1.gtz.
#  -h            print this help message

# Example
#        gtx align –R ‘@RG\tID:test\tSM:test’-o test.bam /index/gtx/hg19/hg19.fa test1.fq test2.fq


task align {

    input {
        # sequence reads pair
        File fastq1
        File fastq2

        # pre-built genome index files
        Array[File] genome_indexes

        # experiments info
        String reads_group
        String sample_id

        # alignment options
        Boolean is_identify_with_bwa = false
        Boolean is_mark_duplicate = false

        # bwa parameters
        Int? score_for_match
        Int? penalty_for_mismatch
        Int? gap_extension_penalty
        Int? gap_open_penalty
        Int? threads
    
        # Resource
        Int sys_disk_size = 200
        Int data_disk_size = 500
    
    }

    String bam_file = sample_id + ".bam"
    String bam_index = bam_file + ".bai"

    command {
        gtx align \
        -o ${bam_file} \
        -R ${reads_group} \
        ${"-A " + score_for_match } \
        ${"-B " + penalty_for_mismatch } \
        ${"-O " + gap_open_penalty } \
        ${"-E " + gap_extension_penalty } \
        ${"-t " + threads } \
        ${true="--bwa" false="" is_identify_with_bwa} \
        ${true="--disable-mark-duplicate" false="" is_mark_duplicate} \
        "${genome_indexes[0]}" \
        ${fastq1} ${fastq2}
    }

    runtime {
        # data volume
        systemDisk: "cloud_ssd ${sys_disk_size}"
        dataDisk: "cloud_ssd ${data_disk_size} /ssd-cache/"

        # software dependencies, please do not change
        cluster: "OnDemand ecs.f3-c16f1.16xlarge img-gtx-fpga"
        isv: "GTX"
    }

    output {
        Pair[File, File] bam = (bam_file, bam_index)
    }
}
