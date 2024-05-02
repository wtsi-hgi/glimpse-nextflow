include { SPLIT_SAMPLES } from '../modules/local/split_samples/main'
include { SPLIT_VCFS } from '../modules/local/split_vcfs/main'
include { GLIMPSE2_PHASE } from '../modules/nf-core/glimpse2/phase/main'
include { BCFTOOLS_INDEX as INDEX_PHASE  } from '../modules/nf-core/bcftools/index/main.nf'
include { BCFTOOLS_INDEX as INDEX_LIGATE } from '../modules/nf-core/bcftools/index/main.nf'

workflow RUN_GLIMPSE {

    SPLIT_SAMPLES(params.batch_size, params.vcf_in)

    vcf = channel.fromPath(params.vcf_in)
    vcf_samples = vcf.combine(SPLIT_SAMPLES.out.sample_lists.flatten())

    vcf_samples_input = vcf_samples.map{
	vcf, sample_list ->
		[[id: vcf.getSimpleName() + "-" + sample_list.getName(), batch: sample_list.getName()], vcf, sample_list]
}

    SPLIT_VCFS(vcf_samples_input)

    ref = channel.fromPath("${params.refdir}*.bin")

    phase_meta = [id: 'phase']
    
    phase_input = SPLIT_VCFS.out.split_vcfs.combine(ref).map{
                                                                    meta, vcf, index , ref_bin ->
                                                                    [meta, vcf, index, [], [], [], ref_bin, [], []]
                                                                }
    phase_input2 = ['', params.fasta, params.fai]

    GLIMPSE2_PHASE(phase_input, phase_input2)

    //GLIMPSE2_PHASE.out.phased_variants.view()

    INDEX_PHASE ( GLIMPSE2_PHASE.out.phased_variants )

    ligate_input = GLIMPSE2_PHASE.out.phased_variants
                                    .groupTuple()
                                    .combine( INDEX_PHASE.out.csi
                                            .groupTuple()
                                            .collect(), by: 0 )
 
                                     
    
    ligate_input.view()

    // attempt for splitting samples in phase
    ///
    // phase_input = vcf_samples.combine(ref).map {
    //                                                 vcf, samples, ref_bin ->
    //                                                 [phase_meta, vcf, [], samples, [], [], ref_bin, [], []]

    //                                                 }
    
    // phase_input2 = ['', params.fasta, params.fai]

    // GLIMPSE2_PHASE(phase_input, phase_input2)


}