/* 
 *   A metaviromics pipeline

/* 
 *   Input parameters 
 */


include { validateParameters; paramsHelp; paramsSummaryLog; fromSamplesheet } from 'plugin/nf-validation'
include { make_input } from './lib/utils'
/*
  Import processes from external files
  It is common to name processes with UPPERCASE strings, to make
  the program more readable (this is of course not mandatory)
*/
include { FASTP } from './modules/fastp'
include { MEGAHIT } from './modules/megahit'
include { GENOMAD_ENDTOEND} from './modules/genomad'
include { CHECKV_ENDTOEND } from './modules/checkv'
include { SEQFU_CAT; SEQFU_RELABEL } from './modules/seqfu'

reads = make_input(params.reads)
reads.view()
// Print help message, supply typical command line usage for the pipeline
if (params.help) {
   log.info paramsHelp("Parameters: --reads input_file.csv")
   exit 0
}

// Validate input parameters
//validateParameters()

// Print summary of supplied parameters
log.info paramsSummaryLog(workflow)

workflow {
    ch_multiqc = Channel.empty()
    
    if (!params.skip_qc) {
      FASTP( reads )
      ch_fastp_reads = FASTP.out.reads
      ch_multiqc     = ch_multiqc.mix(FASTP.out.json).ifEmpty([])
    } else {
      ch_fastp_reads = reads
    }

    ch_megahit = MEGAHIT(ch_fastp_reads)
    ch_genomad = GENOMAD_ENDTOEND(ch_megahit.contigs, params.genomad_db)
    ch_checkv  = CHECKV_ENDTOEND(ch_genomad.virus_fasta, params.checkv_db)
    
    //checkv_list = FILTER_CHECKV(ch_checkv.quality_summary, "Medium-quality", params.keep_undet)
    //ch_relabeled_vir = SEQFU_LIST(ch_checkv.viruses, ch_checkv.quality_summary, "votus")
}