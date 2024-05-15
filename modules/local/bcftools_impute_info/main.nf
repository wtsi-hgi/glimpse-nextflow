process BCFTOOLS_IMPUTE_INFO {

    label 'process_medium'

    input:
    tuple val(meta), path(vcf), path(csi)

    output:
    tuple val(meta), path('glimpse_vcf_annotated.vcf.gz'), path('glimpse_vcf_annotated.vcf.gz.csi'), emit: annotated_variants

    script:
    """
    bcftools +impute-info -Oz -o glimpse_vcf_annotated.vcf.gz ${vcf}
    bcftools index glimpse_vcf_annotated.vcf.gz
    """

}