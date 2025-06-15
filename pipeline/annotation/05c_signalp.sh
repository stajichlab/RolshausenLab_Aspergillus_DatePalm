#!/usr/bin/bash -l
#SBATCH -p gpu --gres=gpu:a100:1 -c 16 --mem 64gb -N 1 -n 1 --out logs/signalp.%a.log -a 1
module load signalp/6-gpu
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
OUTDIR=annotation
IFS=,
tail -n +2 $SAMPLES | sed -n ${N}p | while read BASE SPECIES STRAIN NANOPORE ILLUMINA SUBPHYLUM PHYLUM LOCUS RNASEQ
do
    signalp6 -od ${SCRATCH}/${BASE}_signalp -org euk --mode fast -format txt -fasta $OUTDIR/${BASE}/update_results/*.proteins.fa --write_procs $CPUS -bs 16
    rsync -a $SCRATCH/${BASE}_signalp/prediction_results.txt $OUTDIR/${BASE}/annotate_misc/signalp.results.txt
done
