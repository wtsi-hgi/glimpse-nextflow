# glimpse-nextflow

Nextflow pipeline to run GLIMPSE2 on a multisample VCF.

This pipeline first lists the samples in the input multisample VCF, splits this into batches, splits the multisample VCF into VCFs for each batch. GLIMPSE2 phase is then run on each batch for each file in the reference directory. The output of GLIMPSE2 phase is ligated using GLIMPSE2 ligate to produce a phased VCF per batch. These per-batch phased VCFs are them merged using bcftools merge resulting in a VCF containing phased variants for all samples. Finally bcftools +impute-info is used to recalculate INFO scores.

To run, modify the following parameters in nextflow.config

    batch_size = 10 
    vcf_in = "/lustre/scratch126/humgen/teams/hgi/users/re3/blended_genomes_exomes/glimpse_pipe_test/test_vcfs/test_for_glimpse.vcf.gz"
    refdir = "/lustre/scratch126/humgen/teams/hgi/users/re3/blended_genomes_exomes/glimpse_pipe_test/ref_mini/"
    workdir = "/lustre/scratch126/humgen/teams/hgi/users/re3/blended_genomes_exomes/glimpse_pipe_test/work"
    fasta = "/lustre/scratch125/humgen/resources/ref/Homo_sapiens/GRCh38_15/Homo_sapiens.GRCh38_15.fa"
    fai = "/lustre/scratch125/humgen/resources/ref/Homo_sapiens/GRCh38_15/Homo_sapiens.GRCh38_15.fa.fai"
    ref_bed = "/lustre/scratch125/humgen/resources/ref/Homo_sapiens/GRCh38_15/Homo_sapiens.GRCh38_15.bed"
    publishdir = "/lustre/scratch126/humgen/teams/hgi/users/re3/blended_genomes_exomes/glimpse_pipe_test/output/"

batch_size gives a target batch size, 100-200 is recommended. The multisample VCF is split into batches of approximately the target batch size, which is adjusted so that the final batch is not too small.

Submit to the farm as follows:

    bsub -J nextflow -R "select[mem>4000] rusage[mem=4000]" -M 4000 -o out -e err -qlong "nextflow run /path/to/glimpse-nextflow/main.nf -with-trace -profile sanger"
