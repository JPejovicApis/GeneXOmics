nextflow.enable.dsl=2

star_docker = "quay.io/biocontainers/star:2.7.10b--h9ee0642_0"

process STARsolo {
    tag "${sample_id}"
    
    publishDir "${output_dir}/STARsolo/", enabled: true , mode: 'copy'
    container = star_docker

    input:
    tuple val(sample_id), path(reads)
    path starindex
    path whitelist
    val output_dir

    output:


    tuple val(sample_id), path("${sample_id}_Solo.out"), emit: outdir_star
    tuple val(sample_id), path("${sample_id}_Aligned.out.sam"), emit: sam
    tuple val(sample_id), path("${sample_id}_Log.final.out")
    tuple val(sample_id), path("${sample_id}_Log.out")
    tuple val(sample_id), path("${sample_id}_Log.progress.out")
    tuple val(sample_id), path("${sample_id}_SJ.out.tab")
    path("star_version.yml"), emit: version

    script:

    """
     
    STAR \\
        --genomeDir ${starindex} \\
        --soloCBwhitelist  ${whitelist} \\
        --outFileNamePrefix ${sample_id}_ \\
        --readFilesIn ${reads[1]} ${reads[0]} \\
        --readFilesCommand zcat \\
        --soloType CB_UMI_Simple \\
        --soloUMIlen 12 \\
        --soloCBlen 16 \\
        --soloUMIstart 17 \\
        --soloCBstart 1 \\
        --soloFeatures Gene \\
        --soloBarcodeReadLength 0
    
 
    export STAR_VER=\$(STAR --version | sed -e "s/STAR_//g")
    echo star: \$STAR_VER > star_version.yml

    """
 
}

workflow STARSOLO_WF {
    take:
        samples_channel
        ch_starindex
        ch_whitelist
        ch_output_dir 
    main:
        STARsolo(samples_channel, 
                 ch_starindex,
                 ch_whitelist,
                 ch_output_dir)
   emit:
        version = STARsolo.out.version
        sam = STARsolo.out.sam
        outdir_star = STARsolo.out.outdir_star
}

workflow {
    Channel.fromPath("${params.readsfile}")
          .ifEmpty { exit 1, "File not foud: ${params.readsfile}" }
          .set { sampleInfoChannel }

    samples_channel = sampleInfoChannel
                        .splitCsv(header:true)
                        .map { row -> tuple (row.SampleID,
                                      tuple (file(row.R1.trim()),
                                         file(row.R2.trim())))}

                    
    ch_star_index = Channel.fromPath(params.starindex)
    ch_whitelist = Channel.fromPath(params.whitelist)
    
    STARSOLO_WF (
                        samples_channel,
                        ch_star_index.collect(),
                        ch_whitelist.collect(),
                        params.output_dir
                     )
}
