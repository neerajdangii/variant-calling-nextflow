process MAPPING {
    tag "$sample_id"
    conda "bioconda::bwa=0.7.17 bioconda::samtools=1.19.2"
    publishDir "${params.output_dir}/mapped", pattern: "*.sam", mode: 'copy'
    cpus 4

    input:
    path index_dir
    val index_name
    tuple val(sample_id), path(read1), path(read2)

    output:
    tuple val(sample_id), path("${sample_id}.sam")

    script:
    """
    bwa mem -t ${task.cpus} ${index_dir}/${index_name} ${read1} ${read2} > ${sample_id}.sam
    """
}