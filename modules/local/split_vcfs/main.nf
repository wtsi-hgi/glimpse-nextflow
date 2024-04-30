process SPLIT_VCFS {

    label 'process_medium'

    input:
    tuple path(vcf), path(sample_list)

    output:
    tuple path('vcf_sample_subset_*.vcf.gz'), path('vcf_sample_subset_*.vcf.gz.csi'), emit: split_vcfs

    script:
    """
    bcftools view -S $sample_list $vcf -Oz -o vcf_sample_subset_${sample_list}.vcf.gz
    bcftools index vcf_sample_subset_${sample_list}.vcf.gz
    """

}