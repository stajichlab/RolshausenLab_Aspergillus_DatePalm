#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 64 --mem 128gb --out logs/medaka.%a.log -a 1

module load medaka/1.6
module load workspace/scratch
 
READDIR=input/nanopore
INDIR=asm
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

mkdir -p $OUTDIR
IFS=,
SAMPLES=samples.csv

tail -n +2 $SAMPLES | sed -n ${N}p | while read BASE SPECIES STRAIN NANOPORE ILLUMINA SUBPHYLUM PHYLUM LOCUS RNASEQ
do
    echo "working on strain $BASE"
    mkdir -p $OUTDIR/$BASE
    if [ ! -f $OUTDIR/$BASE/canu.fasta ]; then
    	rsync -av $INDIR/canu/$BASE/${BASE}.contigs.fasta $OUTDIR/$BASE/canu.fasta
    fi
    if [ ! -f $OUTDIR/$BASE/flye.fasta ]; then
    	rsync -av $INDIR/flye/$BASE/assembly.fasta $OUTDIR/$BASE/flye.fasta
    fi
    if [ ! -f $OUTDIR/$BASE/raven.fasta ]; then
	    rsync -av $INDIR/raven/$BASE.scaffolds.fasta $OUTDIR/$BASE/raven.fasta
    fi
    READS=$READDIR/$NANOPORE
    for type in canu flye raven
    do
	DRAFT=$OUTDIR/$BASE/$type.fasta
	BAM=$OUTDIR/$BASE/$type.calls_to_draft.bam
	if [[ ! -f $BAM ]]; then
	    mini_align -i ${READS} -r $DRAFT -m -p $SCRATCH/calls_to_draft -t $CPU
	    rsync -av $SCRATCH/calls_to_draft.bam $BAM
	    rsync -av $SCRATCH/calls_to_draft.bam.bai $BAM.bai
	fi
    done
done
