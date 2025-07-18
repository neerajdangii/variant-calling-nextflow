process DEEPVARIANT {
    tag "$sample_id"
    container 'google/deepvariant:1.6.0'
    publishDir "${params.output_dir}/deepvariant", pattern: "*.vcf.gz", mode: 'copy'

    input:
    tuple val(sample_id), path(bam), path(bai), path(ref), path(fai), path(dict)

    output:
    tuple val(sample_id), path("${sample_id}_deepvariant.vcf.gz")

    script:
    """
    /opt/deepvariant/bin/run_deepvariant \
        --model_type=WES \
        --ref=${ref} \
        --reads=${bam} \
        --output_vcf=${sample_id}_deepvariant.vcf.gz \
        --num_shards=${task.cpus}
    """
}
