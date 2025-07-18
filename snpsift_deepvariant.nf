process SNPSIFT_DEEPVARIANT {
    tag "$sample_id"
    label 'medium_mem'
    publishDir "${params.output_dir}/annotation", mode: 'copy'

    input:
    tuple val(sample_id), path(vcf), val(clinvar_db)

    output:
    tuple val(sample_id), path("${sample_id}.deepvariant.annotated.vcf")

    script:
    """
    # SnpEff annotation
    java -Xmx8g -jar \$SNPEFF_HOME/snpEff.jar \
        -c \$SNPEFF_HOME/snpEff.config \
        -v -stats ${sample_id}.deepvariant.snpEff.html \
        ${params.snpeff_db} \
        $vcf > ${sample_id}.deepvariant.snpEff.vcf

    # SnpSift annotation with ClinVar
    java -Xmx8g -jar \$SNPEFF_HOME/SnpSift.jar \
        annotate \
        $clinvar_db \
        ${sample_id}.deepvariant.snpEff.vcf > ${sample_id}.deepvariant.annotated.vcf
    """
}