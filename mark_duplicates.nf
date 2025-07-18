process MARK_DUPLICATES {
    tag "$sample_id"
    label 'medium_mem'
    publishDir "${params.output_dir}/bam_processing", pattern: "${sample_id}.markdup.*", mode: 'copy'

    input:
    tuple val(sample_id), path(input_bam)

    output:
    tuple val(sample_id), path("${sample_id}.markdup.bam")

    script:
    """
    # Run samtools markdup
    samtools markdup ${input_bam} ${sample_id}.markdup.bam
    
    """
}