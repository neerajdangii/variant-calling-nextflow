process INDEX_BAM {
    tag "$sample_id"
    label 'low_mem'
    publishDir "${params.output_dir}/bam_processing", mode: 'copy'

    input:
    tuple val(sample_id), path(input_bam)

    output:
    tuple val(sample_id), path("${sample_id}.bam"), path("${sample_id}.bam.bai")

    script:
    """
    cp ${input_bam} ${sample_id}.bam
    samtools index -@ ${task.cpus} ${sample_id}.bam
    """
}