#!/usr/bin/bash -l
#SBATCH -N 1 -n 24 --mem 96gb --out logs/pilon.%a.log

module load AAFTF
MEM=96
SAMPLES=samples.csv
INDIR=asm/medaka
OUTDIR=asm/pilon
READDIR=input/illumina

N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
	echo "no value for SLURM ARRAY - specify with -a or cmdline"
    fi
fi

CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi

mkdir -p $OUTDIR

IFS=,
tail -n +2 $SAMPLES | sed -n ${N}p | while read BASE SPECIES STRAIN NANOPORE ILLUMINA SUBPHYLUM PHYLUM LOCUS RNASEQ
do
    unset IFS
    for type in raven
    do
		POLISHED=$INDIR/$BASE/$type.polished.fasta
		mkdir -p $OUTDIR/$BASE
		PILON=$OUTDIR/$BASE/$type.pilon.fasta
		if [ ! -f $POLISHED ]; then
			echo "Medaka polishing did not finish for $STRAIN"
			continue
		fi
		if [[ ! -f $PILON || $POLISHED -nt $PILON ]]; then
			LEFT=$READDIR/${ILLUMINA}_R1_001.fastq.gz # check naming for this
			RIGHT=$READDIR/${ILLUMINA}_R2_001.fastq.gz
			if [ ! -s $LEFT ]; then
				echo "cannot find LEFT ($LEFT) for ILLUMINA: ${ILLUMINA}"
				exit
			fi
			AAFTF pilon -l $LEFT -r $RIGHT -it 5 -v -i $POLISHED -o $PILON -c $CPU --memory $MEM
		fi
    done
done
