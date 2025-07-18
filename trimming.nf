process TRIMMING {
    tag "${sample_id}"
    conda "bioconda::fastp"
    publishDir "${params.output_dir}/trimmed/${sample_id}",
        mode: 'copy',
        pattern: '*.{json,html}'

    input:
    tuple val(sample_id), path(read1), path(read2)

    output:
    tuple val(sample_id), path("${sample_id}_trimmed_R1.fastq.gz"), path("${sample_id}_trimmed_R2.fastq.gz")

    script:
    """
    fastp \\
        -i ${read1} \\
        -I ${read2} \\
        -o ${sample_id}_trimmed_R1.fastq.gz \\
        -O ${sample_id}_trimmed_R2.fastq.gz \\
        -j fastp.json \\
        -h fastp.html \\
        -q 20 \\
        -l 36
    """
}