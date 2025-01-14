// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process PRUNE_DOWN_TREE {

    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? "conda-forge::python=3.8.3" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/mulled-v2-c31f862d526d0a07196020b22083c45f8ddb4f0d:5d34a7705065087f5129c939eea53217c22e38df-0"
    } else {
        container "quay.io/biocontainers/mulled-v2-c31f862d526d0a07196020b22083c45f8ddb4f0d:5d34a7705065087f5129c939eea53217c22e38df-0"
    }

    input:
    path (newick)
    path (lineage_report)
    path (metadata)

    output:
    path "leaflist"       , emit: leaflist
    path "*.tsv"          , emit: metadata

    script:  // This script is bundled with the pipeline, in /bin folder
    leaflist          = "leaflist"
    interest_metadata = "interest_metadata.tsv"
    """
    prune_down_tree.py -i $newick -M $metadata -r $lineage_report -l $leaflist -m $interest_metadata -mt ${params.max_taxa}
    """
}