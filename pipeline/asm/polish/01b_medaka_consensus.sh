#!/usr/bin/bash -l
#SBATCH -N 1 -p gpu -n 1 -c 2 --mem 64gb --out logs/medaka_cons.%a.log  --gres=gpu:1 --time 2:00:00 -a 1

module load medaka/1.6-gpu
module load workspace/scratch

MODEL=r941_min_high_g360
OUTDIR=asm/medaka

CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi

N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
	echo "no value for SLURM ARRAY - specify with -a or cmdline"
    fi
fi

IFS=,
SAMPLES=samples.csv

tail -n +2 $SAMPLES | sed -n ${N}p | while read BASE SPECIES STRAIN NANOPORE ILLUMINA SUBPHYLUM PHYLUM LOCUS RNASEQ
do
    for type in canu flye raven
    do
	DRAFT=$OUTDIR/$BASE/$type.fasta
	HDF=$OUTDIR/$BASE/$type.hdf
	POLISHED=$OUTDIR/$BASE/$type.polished.fasta
	BAM=$OUTDIR/$BASE/$type.calls_to_draft.bam
	if [ ! -s $HDF ]; then
	    time medaka consensus $BAM $HDF --model $MODEL --threads $CPU
	fi
	if [ ! -s $POLISHED ]; then
	    time medaka stitch --threads $CPU $HDF $DRAFT $POLISHED	   
	fi
    done
done
