process SPLIT_SAMPLES {

    label 'process_low'

    input:
    val(batch_size)
    path(vcf_dir)

    output:
    path('samples_*.txt'), emit: sample_lists

    script:
    """
    split_samples.py --vcf_dir ${vcf_dir} --batch_size ${batch_size} --outdir .
    """

}