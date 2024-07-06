#!/bin/bash -l
#SBATCH --ntasks 48 --nodes 1 --mem 80G --time 48:00:00
#SBATCH --out logs/iprscan.%a.log
hostname
CPU=1
if [ ! -z "$SLURM_CPUS_ON_NODE" ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi
# let's pick this more hard-codeed based on the number of embeded workers that will run
SPLIT_CPU=16
JOBSPLIT=100
OUTDIR=annotation
SAMPLES=samples.csv
N=${SLURM_ARRAY_TASK_ID}
if [ -z "$N" ]; then
    N=$1
    if [ -z "$N" ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi
MAX=`wc -l $SAMPLES | awk '{print $1}'`

if [ $N -gt $MAX ]; then
    echo "$N is too big, only $MAX lines in $SAMPLES"
    exit
fi

IFS=, # set the delimiter to be ,
tail -n +2 $SAMPLES | sed -n ${N}p | while read NAME SPECIES STRAIN NANOPORE ILLUMINA SUBPHYLUM PHYLUM LOCUS RNASEQ
do
    name=$NAME
    BASE=$NAME
    echo "$NAME"
    if [ ! -d $OUTDIR/$BASE ]; then
	    echo "No annotation dir for $OUTDIR/${BASE}"
	    exit
    fi

    mkdir -p $OUTDIR/$BASE/annotate_misc
    XML=$OUTDIR/$BASE/annotate_misc/iprscan.xml
    echo "checking $OUTDIR/$BASE"
    if [ ! -f $XML ]; then
    	module load iprscan
        module load funannotate
	    module load workspace/scratch
	    export TMPDIR=$SCRATCH
	    export TEMP=$SCRATCH
	    export TMP=$SCRATCH
	    IPRPATH=$(which interproscan.sh)
	    echo $IPRPATH
	    time funannotate iprscan -i $OUTDIR/$BASE -o $XML -m local -c $SPLIT_CPU --iprscan_path $IPRPATH -n $JOBSPLIT
    fi
done
