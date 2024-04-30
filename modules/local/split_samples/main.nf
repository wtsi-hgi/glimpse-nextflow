process SPLIT_SAMPLES {

    label 'process_low'

    input:
    val(batch_size)
    path(vcf_in)

    output:
    path('samples_*'), emit: sample_lists

    script:
    """
    split_samples.py --vcf ${vcf_in} --batch_size ${batch_size} --outdir .
    """

}