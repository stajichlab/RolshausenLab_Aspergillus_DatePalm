#!/usr/bin/bash -l
#SBATCH -N 1 -c 32 --mem 128gb --out logs/masurca.%a.log -n 1 -a 1
module load masurca
IN=input/nanopore
IN1=input/illumina
OUT=asm/masurca
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
    if [ -z "$ILLUMINA" ]; then
	echo "cannot run masurca hybrid assembly without Illumina for $BASE"
    	exit
    fi
    INONT=$(realpath $IN/$NANOPORE)
    INFASTQ=$(realpath $IN1/$ILLUMINA)
    LEFT=${INFASTQ}_R1_001.fastq.gz
    RIGHT=${INFASTQ}_R2_001.fastq.gz

    mkdir -p $OUT/${BASE}
    if [ ! -f ${OUT}/${BASE}/config.txt ]; then
	    masurca -g ${OUT}/${BASE}/config.txt
	    perl -i -p -e 's/FLYE_ASSEMBLY=1/FLYE_ASSEMBLY=0/; s/LHE_COVERAGE=25/LHE_COVERAGE=35/;' ${OUT}/${BASE}/config.txt
	    perl -i -p -e "s!^\#NANOPORE.+!NANOPORE=$INONT!" ${OUT}/${BASE}/config.txt
	    perl -i -p -e "s!^PE=.+!PE= pe 500 50 $LEFT $RIGHT!" ${OUT}/${BASE}/config.txt
    fi
    OUTSCAFFOLDS=$(realpath $OUT)/$BASE/CA.mr.49.17.15.0.02/primary.genome.scf.fasta
    OUTALT=$(realpath $OUT)/$BASE/CA.mr.49.17.15.0.02/alternative.genome.scf.fasta

    if [[ ! -f $OUTSCAFFOLDS || $INONT -nt $OUTSCAFFOLDS ]]; then
    	pushd $OUT/$BASE
	masurca config.txt
	bash assemble.sh
	popd
    fi
done
