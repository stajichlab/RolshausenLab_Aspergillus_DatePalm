#!/bin/bash -l
#SBATCH --nodes 1 -c 24 -n 1 --mem 64G --out logs/update.%a.log

module load funannotate
export FUNANNOTATE_DB=/bigdata/stajichlab/shared/lib/funannotate_db

CPUS=$SLURM_CPUS_ON_NODE
module load funannotate
RNADIR=lib/RNASeq

if [ ! $CPUS ]; then
    CPUS=2
fi


#!/bin/bash -l
#SBATCH --nodes 1 --ntasks 24 --mem 128G --out logs/train.%a.log -J trainRhod --time 96:00:00


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

IFS=, # set the delimiter to be ,
tail -n +2 $SAMPLES | sed -n ${N}p | while read NAME SPECIES STRAIN NANOPORE ILLUMINA SUBPHYLUM PHYLUM LOCUS RNASEQ
do    
    name=$NAME
    BASE=$NAME
    GENOME=$INDIR/$NAME.masked.fasta
    if [ -z $RNASEQ ]; then
	echo "No RNASeq for updating, skipping $BASE"
    else
	FILES=( $(ls $RNADIR/${RNASEQ}) )
	ARGS=""
	if [ ${#FILES[@]} == 1 ]; then
            ARGS="--single ${FILES[0]}"
	elif [ ${#FILES[@]} == 1 ]; then
	    ARGS="--left ${FILES[0]} --right ${FILES[1]}"
	else
	    echo "No RNASeq files found in '$RNADIR' for '$RNASEQ' - check RNASEQ column in $SAMPLES"
	    exit
	fi
	funannotate update -i $OUTDIR/$BASE --cpus $CPUS
    fi
done
