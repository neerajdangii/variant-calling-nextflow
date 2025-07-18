process SORT {
    tag "$sample_id"
    label 'medium_mem'
    publishDir "${params.output_dir}/bam_processing", mode: 'copy'

    input:
    tuple val(sample_id), path(bam_file)

    output:
    tuple val(sample_id), path("${sample_id}.sorted.bam")

    script:
    """
    samtools sort -@ ${task.cpus} $bam_file -o ${sample_id}.sorted.bam
    """
}