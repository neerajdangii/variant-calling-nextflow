process SAM_TO_BAM {
    tag "$sample_id"
    label 'medium_mem'
    publishDir "${params.output_dir}/bam_processing", mode: 'copy'

    input:
    tuple val(sample_id), path(sam_file)

    output:
    tuple val(sample_id), path("${sample_id}.bam")

    script:
    """
    samtools view -@ ${task.cpus} -bS $sam_file > ${sample_id}.bam
    """
}