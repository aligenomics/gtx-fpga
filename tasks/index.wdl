version 1.0
# all copyrights reserved

#  gtx index
# 	 gtx index <fasta file>
#  		-f            overwriten the existing index file
#  		-h            print this help message
#                   --disable-bwa-index    disable building bwa index
# Example:
# gtx index hg19.fa
# gtx index hg19.fa --disable-bwa-index

task index {
    input {
        File genome_fasta
        Boolean? disable_bwa_index = false

        # Resource 
        Int sys_disk_size = 200
        Int data_disk_size = 500
    }

    String tmp_fasta = basename(genome_fasta)

    command {
        # copy fasta file to work directory
        cp -f ${genome_fasta} ${tmp_fasta}

        # building indexs
        gtx index ${true="--disable-bwa-index" false="" disable_bwa_index} ${tmp_fasta}
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
        Array[File] indexes = glob("${tmp_fasta}*")
    }
}
