process BCFTOOLS_IMPUTE_INFO {

    label 'process_medium'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bcftools:1.18--h8b25389_0':
        'biocontainers/bcftools:1.18--h8b25389_0' }"

    publishDir "${params.publishdir}", mode: 'copy', pattern: "glimpse_vcf_annotated.vcf.gz"
    publishDir "${params.publishdir}", mode: 'copy', pattern: "glimpse_vcf_annotated.vcf.gz.csi"

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