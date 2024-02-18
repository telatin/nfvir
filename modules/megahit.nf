process MEGAHIT {
    tag "$sample_id"
    label 'process_high'

    conda "${moduleDir}/megahit.yaml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-0f92c152b180c7cd39d9b0e6822f8c89ccb59c99:8ec213d21e5d03f9db54898a2baeaf8ec729b447-0' :
        'biocontainers/mulled-v2-0f92c152b180c7cd39d9b0e6822f8c89ccb59c99:8ec213d21e5d03f9db54898a2baeaf8ec729b447-0' }"

    input:
    tuple val(sample_id), path(reads) 

    output:
    tuple val(sample_id), path("megahit_out/*.contigs.fa.gz")                            , emit: contigs
    path "versions.yml"                                                             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    megahit \\
            -1 ${reads[0]} \\
            -2 ${reads[1]} \\
            -t $task.cpus \\
            --out-prefix $sample_id

    pigz \\
            --no-name \\
            -p $task.cpus \\
            megahit_out/*.fa \\
        
    rm -rf megahit_out/intermediate_files

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        megahit: \$(echo \$(megahit -v 2>&1) | sed 's/MEGAHIT v//')
    END_VERSIONS
    """
    
    stub:
    """
    mkdir -p megahit_out
    touch megahit_out/${sample_id}.contigs.fa.gz 
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        megahit: \$(echo \$(megahit -v 2>&1) | sed 's/MEGAHIT v//')
    END_VERSIONS
    """
}