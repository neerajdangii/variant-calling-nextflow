process FIXMATE {
    tag "$sample_id"
    label 'medium_mem'
    publishDir "${params.output_dir}/bam_processing", mode: 'copy'

    input:
    tuple val(sample_id), path(input_bam)

    output:
    tuple val(sample_id), path("${sample_id}.fixmate.bam")

    script:
    """
     samtools fixmate -m -@ ${task.cpus} $input_bam ${sample_id}.fixmate.bam
    """
}