include { SPLIT_SAMPLES } from '../modules/local/split_samples/main'
include { SPLIT_VCFS } from '../modules/local/split_vcfs/main'
include { GLIMPSE2_PHASE } from '../modules/nf-core/glimpse2/phase/main'

workflow RUN_GLIMPSE {

    SPLIT_SAMPLES(params.batch_size, params.vcf_in)

    vcf = channel.fromPath(params.vcf_in)
    vcf_samples = vcf.combine(SPLIT_SAMPLES.out.sample_lists.flatten())

    SPLIT_VCFS(vcf_samples)

    ref = channel.fromPath("${params.refdir}*.bin")
    
    phase_input = SPLIT_VCFS.out.split_vcfs.combine(ref).map{
                                                                    vcf, index , ref_bin ->
                                                                    [[], vcf, index, [], [], [], ref_bin, [], []]
                                                                }
    phase_input2 = channel.empty()

    GLIMPSE2_PHASE(phase_input, phase_input2)

    GLIMPSE2_PHASE.out.versions.view()

}