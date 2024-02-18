process SEQFU_CAT {
    tag "$sample_id"
    label 'standard'

    conda "bioconda::seqfu=1.20.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/seqfu:1.20.0--h6ead514_1':
        'biocontainers/seqfu:1.20.0--h6ead514_1' }"

    input:
    tuple val(sample_id), path("*")


    output:
    path "viruses.fasta"  , emit: viruses
 

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${sample_id}"

    """
    for i in */viruses.fna.gz;
    do
        seqfu cat --prefix \$(dirname \$i). \$i | gzip -c >> viruses.fna.gz
    done

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        checkv: \$(seqfu --version')
    END_VERSIONS
    """
}



process SEQFU_RELABEL {
    tag "$sample_id"
    label 'standard'

    conda "bioconda::seqfu=1.20.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/seqfu:1.20.0--h6ead514_1':
        'biocontainers/seqfu:1.20.0--h6ead514_1' }"

    input:
    tuple val(sample_id), path(fasta) 
    val(tag)

    output:
    tuple val(sample_id), path("${sample_id}_${tag}.fasta.gz") , emit: relabeled 

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    seqfu cat --prefix ${sample_id}. ${fasta} | gzip -c >> ${sample_id}_${tag}.fasta.gz
    """

    stub:
    """
    touch ${sample_id}_${tag}.fasta.gz
    """
}



process SEQFU_LIST {
    tag "$sample_id"
    label 'standard'

    conda "bioconda::seqfu=1.20.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/seqfu:1.20.0--h6ead514_1':
        'biocontainers/seqfu:1.20.0--h6ead514_1' }"

    input:
    tuple val(sample_id), path(fasta) 
    tuple val(sample_id), path(list) 
 

    output:
    tuple val(sample_id), path("${sample_id}_${tag}.fasta.gz") , emit: relabeled 

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    seqfu list ${list} ${fasta} | gzip -c > ${sample_id}_fromlist.fa.gz
    """

    stub:
    """
    touch ${sample_id}_${tag}.fasta.gz
    """
}