params.index_dir         = "reference/hg38"
params.ref               = "hg38.fa"
params.ref_fai           = "hg38.fa.fai"
params.ref_dict          = "hg38.dict"
params.sra_dir           = "sample"
params.snpeff_db         = "databases/GRCh38.p14/data"
params.snpeff_data_dir   = "/mnt/d/pipeline/snpEff"
params.clinvar_vcf       = "databases/clinvar.vcf"
params.output_dir        = "results"
params.reads             = '/path/to/reads/*_{1,2}.fastq.gz'

// Module includes
include { FASTQ_SPLITTER }     from './modules/preprocessing/fastq_splitter.nf'
include { TRIMMING }           from './modules/preprocessing/trimming.nf'
include { MAPPING }            from './modules/preprocessing/mapping.nf'
include { SAM_TO_BAM }         from './modules/bam_processing/sam.nf'
include { SORT }               from './modules/bam_processing/sort.nf'
include { SORT_READ_NAME }     from './modules/bam_processing/sort_read_name'
include { FIXMATE }            from './modules/bam_processing/fixmate'
include { SORT_COORDINATE }    from './modules/bam_processing/sort_coordinate'
include { MARK_DUPLICATES }    from './modules/bam_processing/mark_duplicates'
include { INDEX_BAM }          from './modules/bam_processing/index_bam'
include { ADD_READ_GROUPS }    from './modules/bam_processing/read_groups'

include { DEEPVARIANT }        from './modules/variant_callers/deepvariant'

// include { OCTOPUS }         from './modules/variant_callers/octopus'

include { SNPSIFT_GATK_HC }        from './modules/annotation/snpsift_gatk_hc'
include { SNPSIFT_DEEPVARIANT }    from './modules/annotation/snpsift_deepvariant'
include { SNPSIFT_FREEBAYES }      from './modules/annotation/snpsift_freebayes'
include { SNPSIFT_PLATYPUS }       from './modules/annotation/snpsift_platypus'

workflow {

    // STEP 1: Get sample FASTQ data from CSV
    Channel
        .fromPath("sample/sample.csv")
        .splitCsv(header: true)
        .map { row -> tuple(row.sample_id, file(row.sra_path)) }
        .set { sra_channel }

    // STEP 2: Preprocessing
    FASTQ_SPLITTER(sra_channel)
    TRIMMING(FASTQ_SPLITTER.out)

    // STEP 3: Prepare for Mapping
    reads_ch = TRIMMING.out.map { sample_id, read1, read2 -> 
        tuple(sample_id, read1, read2) 
    }

    // STEP 4: Mapping
    MAPPING(file(params.index_dir), "hg38.fa", reads_ch)

    // STEP 5: BAM processing
    SAM_TO_BAM(MAPPING.out)
    SORT(SAM_TO_BAM.out)
    SORT_READ_NAME(SORT.out)
    FIXMATE(SORT_READ_NAME.out)
    SORT_COORDINATE(FIXMATE.out)
    MARK_DUPLICATES(SORT_COORDINATE.out)
    ADD_READ_GROUPS(MARK_DUPLICATES.out)
    INDEX_BAM(ADD_READ_GROUPS.out)

    // STEP 6: Reference files and SnpSift DB
    reference_channel = Channel.of(
        tuple(file(params.ref), file(params.ref_fai), file(params.ref_dict))
    )

    snpsift_db_channel = Channel.of(file(params.clinvar_vcf))

    // STEP 7: Prepare input for DeepVariant
    vcf_input = INDEX_BAM.out
        .combine(reference_channel)
        .map { sample_id, bam, bai, ref_tuple ->
            def (ref, fai, dict) = ref_tuple
            tuple(sample_id, bam, bai, ref, fai, dict)
        }

    // STEP 8: Variant Calling (DeepVariant)
    DEEPVARIANT(vcf_input)
    deepvariant_vcf = DEEPVARIANT.out.map { sample_id, vcf -> tuple(sample_id, vcf) }

    // STEP 9: Annotation using SnpSift for DeepVariant
    deepvariant_vcf
        .combine(snpsift_db_channel)
        .map { sample_id, vcf, clinvar_vcf -> 
            tuple(sample_id, vcf, clinvar_vcf.toString()) 
        }
        .set { snpsift_input_deepvariant }

    SNPSIFT_DEEPVARIANT(snpsift_input_deepvariant)
}
