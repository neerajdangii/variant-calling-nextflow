process FASTQ_SPLITTER {
    tag "$sample_id"
    publishDir "${params.output_dir}/fastq", mode: 'copy'

    input:
    tuple val(sample_id), path(sra_file)

    output:
    tuple val(sample_id), path("${sample_id}_1.fastq.gz"), path("${sample_id}_2.fastq.gz")

    script:
    """
    # Create output directory if needed
    mkdir -p ${params.output_dir}/fastq
    
    # Run fastq-dump with direct output naming
    fastq-dump --split-files --gzip -O ./ ${sra_file}
    
    # Rename files only if they don't already match the expected names
    if [ -f "${sra_file.baseName}_1.fastq.gz" ] && [ ! -f "${sample_id}_1.fastq.gz" ]; then
        mv "${sra_file.baseName}_1.fastq.gz" "${sample_id}_1.fastq.gz"
    fi
    if [ -f "${sra_file.baseName}_2.fastq.gz" ] && [ ! -f "${sample_id}_2.fastq.gz" ]; then
        mv "${sra_file.baseName}_2.fastq.gz" "${sample_id}_2.fastq.gz"
    fi
    """
}