version 1.0
import "tasks/index.wdl" as index

workflow gtx_index {

    input {
        File genome_fasta
        Boolean? disable_bwa_index = false

        # Resource
        Int sys_disk_size = 200
        Int data_disk_size = 500
    }

    call index.index as build_index {
        input:
            genome_fasta = genome_fasta,
            disable_bwa_index = disable_bwa_index,
            sys_disk_size = sys_disk_size,
            data_disk_size = data_disk_size
    }

    output {
        Array[File] indexes = build_index.indexes
    }
}
