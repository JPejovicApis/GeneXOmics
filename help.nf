nextflow.preview.dsl=2


def printHeader() {
    log.info """\

    SINGLE CELL R N A   S E Q    -   N F   P I P E L I N E
    ===============================================
    """
 }


def helpMessage() {

    yellow = "\033[0;37m"
    blue = "\033[0;35m"
    white = "\033[0m"
    red = "\033[0;31m"

//    log.info printHeader()
    log.info"""
    Usage:
    The typical command for running the pipeline is as follows:
    ${blue} nextflow run main.nf -profile test_local

    ${yellow}

    Mandatory arguments:
        --readsfile                         [csv]           Path to the csv file containing list of fastq files

    References
        --star_index                        [folder]        Specific star index folder that is not among the genomes.
        --whitelist                         [file]          File containing a list of valid cell barcodes


    OTHER
        --output_dir                        [folder]        Path to the output folder


    Important information:
    ${red}
   

    """.stripIndent()
}


workflow {

printHeader()
helpMessage()

}
