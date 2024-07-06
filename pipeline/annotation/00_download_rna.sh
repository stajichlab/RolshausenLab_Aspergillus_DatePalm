#!/usr/bin/bash -l
#SBATCH -p short -N 1 -c 96 --mem 128gb --out logs/download_sra.%a.log

module load parallel-fastq-dump
#module load sratoolkit
module load workspace/scratch
MEM=16G
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
SRAFILE=lib/RNASeq/sra.txt
FOLDER=lib/RNASeq

MAX=$(wc -l $SRAFILE | awk '{print $1}')
if [ $N -gt $MAX ]; then
  echo "$N is too big, only $MAX lines in $SRAFILE"
  exit
fi
if [ ! -s $SRAFILE ]; then
	echo "No SRA file $SRAFILE"
	exit
fi
IFS=,
SPECIES=A_tubingensis
sed -n ${N}p $SRAFILE | while read SRA 
do
  mkdir -p $FOLDER/$SPECIES
  if [ ! -s $FOLDER/$SPECIES/${SRA}_1.fastq.gz ]; then
	time parallel-fastq-dump -T $SCRATCH -O $FOLDER/$SPECIES  --threads $CPU --split-files --gzip --sra-id $SRA
  fi
done
