# glimpse-nextflow

Nextflow pipeline to run GLIMPSE2 on a multisample VCF.

This pipeline first lists the samples in the input multisample VCF, splits these samples into batches, and then splits the multisample VCF into separate (smaller) mutisample VCFs for each batch. GLIMPSE2 phase is then run on each batch for each file in the binary reference directory. The output of GLIMPSE2 phase is ligated using GLIMPSE2 ligate to produce a phased VCF per batch. These per-batch phased VCFs are them merged using bcftools merge resulting in a VCF containing phased variants for all samples. Finally bcftools +impute-info is used to recalculate INFO scores.

In order to run this pipeline you will first need to generate a binary reference panel, as described
on https://odelaneau.github.io/GLIMPSE/docs/tutorials/getting_started/#4-create-binary-reference-panel
This reference panel shoud be appropriate for the ancestry of your cohort.

To run, modify the following parameters in nextflow.config

    batch_size = 100 
    vcf_in = "path/to/vcf.gz
    refdir = "/path/to/binary/reference/directory/"
    workdir = "/path/to/nextflow//work/"
    fasta = "/path/to/reference/genome/fasta.fa"
    fai = "/path/to/reference/genome/fasta.fa.fai"
    ref_bed = "/path/to/regions.bed"
    publishdir = "/path/to/nextflow/output/"

Batch_size gives a target batch size, 100-200 is recommended. The multisample VCF is split into batches of approximately the target batch size, which is adjusted so that the final batch is not too small.
The ref_bed file gives the regions you are interested in, this can be a bed file with a row for each chromosome covering the entire chromosome.

For users at Sanger, this can be submitted to the farm as follows:

    bsub -J nextflow -R "select[mem>4000] rusage[mem=4000]" -M 4000 -o out -e err -qoversubscribed "nextflow run /path/to/glimpse-nextflow/main.nf -with-trace -profile sanger"
