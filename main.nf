nextflow.enable.dsl=2

include { RUN_GLIMPSE } from './workflows/run_glimpse'

workflow MAIN {
    RUN_GLIMPSE ()
}

workflow {
    MAIN ()
}

