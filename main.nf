nextflow.enable.dsl=2



params.kmers = '21,31'
params.reads = 'data/*fasta'
params.outdir = 'results'


kmers = Channel.of(params.kmers.split(','))
                .toInteger()
reads = Channel
                .fromPath(params.reads, checkIfExists: true)
                .map { file -> tuple(file.baseName, file) }

kreads = reads.combine(kmers)



process jellyfish {
    tag "${sample}_${kmer}"

    input:
      tuple val(sample), path(reads), val(kmer)
    output:
      tuple val(sample), path("${sample}.histo"), val(kmer)
    script:
      """
      if [ -f *.gz ]; then
            jellyfish count -C -m $kmer -s 200M \
            -t ${task.cpus} \
            <(zcat $reads)
        else
            jellyfish count -C -m $kmer -s 200M \
            -t ${task.cpus} \
            $reads
        fi
      jellyfish histo -t ${task.cpus} mer_counts.jf > ${sample}.histo
      rm mer_counts.jf
      """
}

process genomescope {
    tag "${sample}_${kmer}"
    publishDir params.outdir

    input:
      tuple val(sample), path(histo), val(kmer)
    output:
      path("${sample}_${kmer}")
    script:
      """
      mkdir -p ${sample}_${kmer}
      Rscript /kmer_wd/genomescope.R $histo $kmer 150 ${sample}_${kmer} \
      | tail -n +2 \
      | sed \'s/Model converged //; s/ /\\n/g\' > \
      ${sample}_${kmer}/${sample}_${kmer}_gmodel.txt
      """
}


workflow {
    genomescope(jellyfish(kreads))
}
