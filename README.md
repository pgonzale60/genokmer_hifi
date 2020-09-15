# Reproducible genome size estimation from hifi reads 

Run jellyfish followed by genomescope from hifi reads.

## Dependendencies

- Singularity
- Nextflow
- pgonzale60/genokmer image

## Installation

You can get the dependencies via conda
```
conda install -c bioconda nextflow singularity
```

At the moment the singularity image should be found under the `$HOME` directory.
```
cd $HOME
singularity pull docker://pgonzale60/genokmer
```

## Usage

To execute the pipeline:
```
nextflow run pgonzale60/genokmer_hifi  --reads '/path/to/reads/*fasta'
```
