process ADD_READ_GROUPS {
    tag "$sample_id"
    label 'medium_mem'
    conda "bioconda::gatk4"
    publishDir "${params.output_dir}/bam_processing", pattern: "*.bam", mode: 'copy'

    input:
    tuple val(sample_id), path(input_bam)

    output:
    tuple val(sample_id), path("${sample_id}.rg.bam")

    script:
    """
    gatk AddOrReplaceReadGroups \
        -I $input_bam \
        -O ${sample_id}.rg.bam \
        -RGID ${sample_id} \
        -RGLB lib1 \
        -RGPL ILLUMINA \
        -RGPU unit1 \
        -RGSM ${sample_id}
    """
}