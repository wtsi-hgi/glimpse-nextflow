include { SPLIT_SAMPLES } from '../modules/local/split_samples/main'
include { SPLIT_VCFS } from '../modules/local/split_vcfs/main'

workflow RUN_GLIMPSE {

    SPLIT_SAMPLES(params.batch_size, params.vcf_dir)

    vcfs = Channel.fromPath("${params.vcf_dir}/*.vcf.gz")
    // pairs = vcfs.combine(SPLIT_SAMPLES.out.sample_lists.flatten())
    // pairs.view()

    vcfs
        .combine(SPLIT_SAMPLES.out.sample_lists.flatten())
        | SPLIT_VCFS

    


    //SPLIT_VCFS(SPLIT_SAMPLES.out.sample_lists, params.vcf_list)

}