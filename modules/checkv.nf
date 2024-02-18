process CHECKV_ENDTOEND {
    tag "$sample_id"
    label 'process_medium' 

    conda "bioconda::checkv=1.0.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/checkv:1.0.1--pyhdfd78af_0':
        'biocontainers/checkv:1.0.1--pyhdfd78af_0' }"

    input:
    tuple val(sample_id), path(fasta)
    path(db)

    output:
    tuple val(sample_id), path ("${prefix}/quality_summary.tsv") , emit: quality_summary
    tuple val(sample_id), path ("${prefix}/completeness.tsv")    , emit: completeness
    tuple val(sample_id), path ("${prefix}/contamination.tsv")   , emit: contamination
    tuple val(sample_id), path ("${prefix}/complete_genomes.tsv"), emit: complete_genomes
    tuple val(sample_id), path ("${prefix}/proviruses.fna.gz")   , emit: proviruses
    tuple val(sample_id), path ("${prefix}/viruses.fna.gz")      , emit: viruses
    path "versions.yml"                                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${sample_id}"

    """
    checkv \\
        end_to_end \\
        $args \\
        -t $task.cpus \\
        -d $db \\
        $fasta \\
        $prefix

    gzip ${prefix}/*viruses.fna

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        checkv: \$(checkv -h 2>&1  | sed -n 's/^.*CheckV v//; s/: assessing.*//; 1p')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${sample_id}"
    """
    mkdir -p ${prefix}
    touch ${prefix}/quality_summary.tsv       
    touch ${prefix}/completeness.tsv       
    touch ${prefix}/contamination.tsv       
    touch ${prefix}/complete_genomes.tsv       
    touch ${prefix}/proviruses.fna.gz       
    touch ${prefix}/viruses.fna.gz       
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        checkv: \$(checkv -h 2>&1  | sed -n 's/^.*CheckV v//; s/: assessing.*//; 1p')
    END_VERSIONS
    """
}