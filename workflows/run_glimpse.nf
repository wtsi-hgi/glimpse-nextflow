include { SPLIT_SAMPLES } from '../modules/local/split_samples/main'
include { SPLIT_VCFS } from '../modules/local/split_vcfs/main'

workflow RUN_GLIMPSE {

    SPLIT_SAMPLES(params.batch_size, params.vcf_in)

    vcf = channel.fromPath(params.vcf_in)
    vcf_samples = vcf.combine(SPLIT_SAMPLES.out.sample_lists.flatten())

    SPLIT_VCFS(vcf_samples)

}