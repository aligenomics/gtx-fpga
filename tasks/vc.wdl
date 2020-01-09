version 1.0

# all copyrights reserved

# gtx vc <-r fasta> <-i bam> <-o vcf> [options]
#  	-r    <file>  reference FASTA file
#  	-i    <file>  input sorted and duplicates-marked BAM file
# 	-o   <file>  output VCF file
#  	-t    <int>   the number of threads, default [36]
#  	-L    <str>   one (eg. chr1:1-200) or more (BED format) genomic intervals over which to operate
# 	-g            output in GVCF format
# 	-h            print this help message

# Example：
# 	gtx vc -r /index/gtx/hg19/hg19.fa -o test.vcf -i test.sort.rmdup.bam


task vc {
    input {
        # sorted and duplicates-marked BAM file
        Pair[File, File] bam
        
        # pre-built genome index files
        Array[File] genome_indexes

        # experiment info
        String sample_id

        # genomic intervals
        File? intervals

        # parameters
        Boolean is_gvcf = false

        # threads
        Int? threads

        # Resource
        Int sys_disk_size = 200
        Int data_disk_size = 500

    }

    String intervals_option = if defined(intervals) then "-L " + intervals else ""
    String vcf_file = if is_gvcf then sample_id + ".g.vcf" else sample_id + ".vcf"

    command {
        gtx vc \
        ${intervals_option} \
        ${true="-g" false="" is_gvcf} \
        ${"-t " +threads } \
        -r "${genome_indexes[0]}" \
        -o ${vcf_file} \
        -i ${bam.left}
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
        File vcf = vcf_file
    }
}
