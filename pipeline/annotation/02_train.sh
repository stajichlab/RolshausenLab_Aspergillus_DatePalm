#!/bin/bash -l
#SBATCH --nodes 1 --ntasks 32 --mem 128G --out logs/train.%a.log
#SBATCH -J train --time 96:00:00 -a 1

MEM=128G
module load funannotate

#export PASAHOME=`dirname $(which Launch_PASA_pipeline.pl)`
RNADIR=lib/RNASeq
CPUS=$SLURM_CPUS_ON_NODE

if [ ! $CPUS ]; then
    CPUS=2
fi
SAMPLES=samples.csv
N=${SLURM_ARRAY_TASK_ID}

if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi
MAX=$(wc -l $SAMPLES | awk '{print $1}')
if [ $N -gt $MAX ]; then
    echo "$N is too big, only $MAX lines in $SAMPLES"
    exit
fi

INDIR=final_genomes
OUTDIR=annotation

IFS=,
tail -n +2 $SAMPLES | sed -n ${N}p | while read NAME SPECIES STRAIN NANOPORE ILLUMINA SUBPHYLUM PHYLUM LOCUS RNASEQ
do    
    name=$NAME
    BASE=$NAME
    GENOME=$INDIR/$NAME.masked.fasta
    if [ -z $RNASEQ ]; then
	echo "No RNASeq for training, skipping $BASE"
    else
	# this is dynamically checking for files that are paired but if not paired we use the --single option
	LEFT=$RNADIR/${RNASEQ}_R1.fastq.gz
	RIGHT=$RNADIR/${RNASEQ}_R2.fastq.gz
	if [[ ! -z $LEFT && ! -z $RIGHT ]]; then
	    # paired end data
	    funannotate train -i $GENOME --cpus $CPUS --memory $MEM  --species "$SPECIES" --strain $STRAIN  -o $OUTDIR/$BASE --jaccard_clip --max_intronlen 1000 \
			--left $LEFT --right $RIGHT
	elif [ ! -z $LEFT ]; then
	    # unpaired - single end only
	    funannotate train -i $GENOME --cpus $CPUS --memory $MEM  --species "$SPECIES" --strain $STRAIN  -o $OUTDIR/$BASE --jaccard_clip  --max_intronlen 1000 \
			--single $LEFT
	else
	    echo "No RNASeq files found in '$RNADIR' for '$RNASEQ' - check RNASEQ column in $SAMPLES"
	    exit
	fi
    fi
done
