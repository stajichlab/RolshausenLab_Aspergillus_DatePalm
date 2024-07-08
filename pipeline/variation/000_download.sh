#!/usr/bin/bash
#SBATCH -p short -N 1 -n 1 -c 16 --mem 32gb --out logs/download_sra.%a.log

module load sratoolkit
module load parallel-fastq-dump
module load workspace/scratch

CPU=2
if [ $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi
N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
  N=$1
fi
if [ -z $N ]; then
  echo "cannot run without a number provided either cmdline or --array in sbatch"
  exit
fi
SRAFILE=lib/DNASeq/sra.txt
FOLDER=input/variation

MAX=$(wc -l $SRAFILE | awk '{print $1}')
if [ "$N" -gt "$MAX" ]; then
  echo "$N is too big, only $MAX lines in $SRAFILE"
  exit
fi
if [ ! -s $SRAFILE ]; then
	echo "No SRA file $SRAFILE"
	exit
fi
SRA=$(sed -n ${N}p $SRAFILE | cut -f1)
if [ ! -s $FOLDER/${SRA}_1.fastq.gz ]; then
	parallel-fastq-dump -T $SCRATCH -O $FOLDER  --threads $CPU --split-files --gzip --sra-id $SRA
fi
