nextflow.enable.dsl=2


include { FASTQC_WF }                          from './modules/fastqc'
include { STARSOLO_WF }                        from './modules/starsolo'



workflow {

  Channel.fromPath("${params.readsfile}")
   .ifEmpty { exit 1, "File not foud: ${params.readsfile}" }
   .set { sampleInfoChannel }

  samples_channel = sampleInfoChannel
    .splitCsv(header:true)
    .map { row -> tuple (row.SampleID,
                         tuple(file(row.R1.trim()),
                               file(row.R2.trim())))}

if (!params.skip_fastqc) {
FASTQC_WF(samples_channel, params.output_dir)
}


// Run STARSolo pipeline
if (params.aligner == "star") {

STARSOLO_WF(samples_channel, params.starindex, params.whitelist, params.output_dir)

}


}


// OnComplete
workflow.onComplete{
    println( "\nPipeline completed successfully.\n\n" )
}

// OnError
workflow.onError{
    println( "\nPipeline failed.\n\n" )
}
