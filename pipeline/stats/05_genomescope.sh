#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 1 -c 32 --mem 64gb --out logs/genomescope.%a.log -a 1

module load workspace/scratch
module load samtools
module load jellyfish
module load R

GENOMESCOPE=genomescope

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
FASTQFOLDER=input
SAMPLES=samples.csv
MAX=$(wc -l $SAMPLES | awk '{print $1}')
if [ $N -gt $MAX ]; then
  echo "$N is too big, only $MAX lines in samplefile=$SAMPLES"
  exit
fi
mkdir -p $GENOMESCOPE
JELLYFISHSIZE=1000000000
IFS=,
KMER=21
READLEN=150 # note this assumes all projects are 150bp reads which they may not be
tail -n +2 $SAMPLES | sed -n ${N}p | while read BASE SPECIES STRAIN NANOPORE ILLUMINA SUBPHYLUM PHYLUM LOCUS RNASEQ
do    
    INTERNALID=$BASE
    # for this project has only a single file base  but this needs fixing otherse
    jellyfish count -C -m $KMER -s $JELLYFISHSIZE -t $CPU -o $SCRATCH/$INTERNALID.jf <(pigz -dc $FASTQFOLDER/illumina/${ILLUMINA}_R[12]_001.fastq.gz)
    jellyfish histo -t $CPU $SCRATCH/$INTERNALID.jf > $GENOMESCOPE/$INTERNALID.histo
    Rscript scripts/genomescope.R $GENOMESCOPE/$INTERNALID.histo $KMER $READLEN $GENOMESCOPE/$INTERNALID/
done
