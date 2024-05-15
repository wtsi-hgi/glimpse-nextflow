include { SPLIT_SAMPLES } from '../modules/local/split_samples/main'
include { SPLIT_VCFS } from '../modules/local/split_vcfs/main'
include { GLIMPSE2_PHASE } from '../modules/nf-core/glimpse2/phase/main'
include { GLIMPSE2_LIGATE } from '../modules/nf-core/glimpse2/ligate/main'
include { BCFTOOLS_INDEX as INDEX_PHASE  } from '../modules/nf-core/bcftools/index/main.nf'
include { BCFTOOLS_INDEX as INDEX_LIGATE } from '../modules/nf-core/bcftools/index/main.nf'
include { BCFTOOLS_MERGE } from '../modules/nf-core/bcftools/merge/main.nf'
include { BCFTOOLS_INDEX as INDEX_MERGE } from '../modules/nf-core/bcftools/index/main.nf'

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

    INDEX_PHASE ( GLIMPSE2_PHASE.out.phased_variants )

    index_output_ch = INDEX_PHASE.out.csi.groupTuple(by: 0)
    ligate_input = GLIMPSE2_PHASE.out.phased_variants.groupTuple(by: 0).join(index_output_ch, by: 0)
   
    GLIMPSE2_LIGATE ( ligate_input )

    INDEX_LIGATE ( GLIMPSE2_LIGATE.out.merged_variants )

    //ligate_index_output_ch = INDEX_LIGATE.out.csi.groupTuple(by: 0)
    // merge_input = GLIMPSE2_LIGATE.out.merged_variants.groupTuple(by: 0).join(ligate_index_output_ch, by: 0)
    // INDEX_LIGATE.out.csi.view()

    merge_meta = [id: 'merge']

    ligate_ch = GLIMPSE2_LIGATE.out.merged_variants.map{ meta, vcf -> [merge_meta, vcf] }.groupTuple(by: 0)
    index_ch = INDEX_LIGATE.out.csi.map{ meta, index -> [merge_meta, index] }.groupTuple(by: 0) 
    merge_ch = ligate_ch.join(index_ch)

    merge_input_2 = [[], params.fasta]
    merge_input_3 = [[], params.fai]

    BCFTOOLS_MERGE ( merge_ch, merge_input_2, merge_input_3, params.ref_bed )

    INDEX_MERGE ( BCFTOOLS_MERGE.out.merged_variants )



}