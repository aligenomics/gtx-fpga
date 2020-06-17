version 1.0
# all copyrights reserved

# gtx wgs [options] <-o out.vcf> <-R read_group> <reference.fasta> <in1.fq> [in2.fq]
	#  -o    <file>  output VCF file
	#  -b    <file>  output sorted and duplicates-marked BAM file
	#  -R    <str>   read group header line such as '@RG\tID:foo\tSM:bar’
	#  -A    <int>   score for a sequence match, default [1]
#  	 -B    <int>   penalty for mismatch, default [4]
# 	 -O    <int>   gap open penalty, default [6]
#  	 -E    <int>   gap extension penalty, default [1]
# 	 -t    <int>   the number of threads, default [36]
#  	 -L    <str>   one (eg. chr1:1-200) or more (BED format) genomic intervals over which to operate
#  	 -g            output in GVCF format
#  	 --bwa         align reads with precision comparable to BWA-mem
# 	 -h            print this help message

# Example
	# gtx wgs –R ‘@RG\tID:test\tSM:test’ –o test.vcf –bwa /index/gtx/hg19/hg19.fa test1.fq test2.fq
    
task wgs {
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

    String intervals_option = if defined(intervals) then "-L " + intervals else ""
    String bam = sample_id + ".bam"
    String bam_idx = sample_id + ".bam.bai"
    String bqsr_output = sample_id + ".bqsr.output.txt"
    String bam_option_str = if is_output_bam then "-b " + bam else ""
    String vcf = if is_gvcf then sample_id + ".g.vcf" else sample_id + ".vcf"
    String bqsr_option_str = if is_bqsr then "--bqsr " + bqsr_output else ""
    Array[File] sites = if is_bqsr then select_all(known_sites) else []
    String prefix = if is_bqsr then "--known-sites" else ""

    command {
        gtx wgs \
        -R ${reads_group} \
        -o ${vcf} \
        ${intervals_option} \
        ${true="--bwa" false="" is_identify_with_bwa} \
        ${bqsr_option_str} \
        ${"-A " + score_for_match } \
        ${"-B " + penalty_for_mismatch } \
        ${"-O " + gap_open_penalty } \
        ${"-E " + gap_extension_penalty } \
        ${"-t " + threads } \
        ${bam_option_str} \
        ${true="-g" false="" is_gvcf} \
        ${prefix} ~{sep=" --known-sites " sites} \
        ${genome_indexes[0]} \
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
        Pair[File, File] alignment = (bam, bam_idx)
        File variants = vcf
    }

}
