process SORT_READ_NAME {
    tag "$sample_id"
    label 'medium_mem'
    publishDir "${params.output_dir}/bam_processing", mode: 'copy'

    input:
    tuple val(sample_id), path(input_bam)

    output:
    tuple val(sample_id), path("${sample_id}.name_sorted.bam")

    script:
    """
    samtools sort -@ ${task.cpus} -n $input_bam -o ${sample_id}.name_sorted.bam
    """
}