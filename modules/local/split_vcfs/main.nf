process SPLIT_VCFS {

    input:
    tuple path(vcf), path(sample_list)

    output:
    path('vcf_sample_subset.vcf.gz')

    script:
    """
    bcftools view -S $sample_list $vcf -Oz -o vcf_sample_subset.vcf.gz
    """

}