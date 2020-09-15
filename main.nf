nextflow.enable.dsl=2

reads = Channel
                .fromPath(params.reads)
                .map { file -> tuple(file.baseName, file) }


process jellyfish {
    container = "$HOME/genokmer_0.1.sif"

    input:
      tuple val(sample), path(reads)
    output:
      tuple val(sample), path("${sample}.histo")
    script:
      """
      if [ -f *.gz ]; then
            jellyfish count -C -m 21 -s 100M \
            -t ${task.cpus} \
            <(zcat $reads)
        else
            jellyfish count -C -m 21 -s 100M \
            -t ${task.cpus} \
            $reads
        fi
      jellyfish histo -t ${task.cpus} mer_counts.jf > ${sample}.histo
      rm mer_counts.jf
      """
}

process genomescope {
    container = "$HOME/genokmer_0.1.sif"

    input:
      tuple val(sample), path(histo)
    output:
      path("${sample}_gmodel.txt")
    script:
      """
      Rscript /kmer_wd/genomescope.R $histo 21 150 ${sample} \
      | tail -n +2 \
      | sed \'s/Model converged //; s/ /\\n/g\' > ${sample}_gmodel.txt
      """
}


workflow {
    genomescope(jellyfish(reads))
    genomescope.out.view()
}
