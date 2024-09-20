nextflow.enable.dsl=2

fastqc_docker = "quay.io/biocontainers/fastqc:0.11.9--0"

process FASTQC {
    tag "$sample_id"
    publishDir "${output_dir}/fastqc", enabled: true , mode: 'copy'
    container = fastqc_docker

    input:
        tuple val(sample_id), path(reads)
        val(output_dir)

    output:
        tuple val(sample_id), path("*.html"),   emit: html
        tuple val(sample_id), path("*.zip"),    emit: zip
        path  "fastqc_version.yml",                   emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def extensions = ["fastq", "fq", "gz"]
        try {
            if (extensions.contains(reads[0].Extension)) {
            """
            fastqc ${reads}
            fastqc --version > fastqc_version.yml
            """
                }
        else {
            throw new IllegalArgumentException ("Error. Incorrect file format. Ensure file suffix is .gz, .fasta or .fq .")
            }
        } catch (Exception e) {
            "echo ${e.message}"
        }
        
}


workflow FASTQC_WF {
    take:
    samples_channel
    outdir 

    main:

    FASTQC(samples_channel, params.output_dir)

    emit:
    html = FASTQC.out.html
    fastqc_version =  FASTQC.out.versions
}
workflow   {
    Channel.fromPath("${params.readsfile}")
           .ifEmpty { exit 1, "File not found: ${params.readsfile}" }
           .set { sampleInfoChannel }

    samples_channel = sampleInfoChannel
                        .splitCsv(header:true)
                        .map { row -> tuple (row.SampleID,
                                             tuple (file(row.R1.trim()),
                                                    file(row.R2.trim())
                                                    )
                                             )
                                      }
	FASTQC_WF(samples_channel, params.output_dir)

}