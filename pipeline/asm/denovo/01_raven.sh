#!/usr/bin/bash -l
#SBATCH -p epyc -N 1 -c 24 --mem 96gb --out logs/raven.%a.log 
module load raven
IN=input/nanopore
OUT=asm/raven
hostname
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=2
fi
N=${SLURM_ARRAY_TASK_ID}

if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
        echo "Need an array id or cmdline val for the job"
        exit
    fi
fi


mkdir -p $OUT
IFS=,
SAMPLES=samples.csv

tail -n +2 $SAMPLES | sed -n ${N}p | while read BASE SPECIES STRAIN NANOPORE ILLUMINA SUBPHYLUM PHYLUM LOCUS RNASEQ
do
    INFASTQ=$(realpath $IN/$NANOPORE)
    OUTSCAFFOLDS=$(realpath $OUT)/$BASE.scaffolds.fasta
    if [[ ! -f $OUTSCAFFOLDS || $INFASTQ -nt $OUTSCAFFOLDS ]]; then
    	pushd $SCRATCH
    	raven -t $CPU $INFASTQ > $OUTSCAFFOLDS
    fi
done
