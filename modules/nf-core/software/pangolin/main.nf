// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process PANGOLIN_LINEAGES {

    label 'process_high'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? 'bioconda::pangolin==3.0.5--pyhdfd78af_0' : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container 'https://depot.galaxyproject.org/singularity/pangolin:2.4.2--pyhdfd78af_0'
    } else {
        container 'quay.io/biocontainers/pangolin:3.0.5--pyhdfd78af_0'
    }

    input:
    path (fasta)

    output:
    path  "*.csv"                  , emit: report
    path  "*.version.txt"          , emit: version

    script:
    def software = getSoftwareName(task.process)
    """
    pangolin \\
        $fasta\\
        --outfile lineages_report.csv \\
        --threads $task.cpus
    pangolin --version | sed "s/pangolin //g" > ${software}.version.txt
    """
}