#!/bin/bash -l
#SBATCH -p short -C xeon -N 1 -c 24 -n 1 --mem 16G --out logs/antismash.%a.log -J antismash

module load antismash/7.1.0
hostname
CPU=1
if [ ! -z $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi
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

if [ "$N" -gt "$MAX" ]; then
    echo "$N is too big, only $MAX lines in $SAMPLES"
    exit
fi

IFS=,
INPUTFOLDER=predict_results

IFS=, # set the delimiter to be ,
tail -n +2 $SAMPLES | sed -n ${N}p | while read NAME SPECIES STRAIN NANOPORE ILLUMINA SUBPHYLUM PHYLUM LOCUS RNASEQ
do
    name=$NAME
    BASE=$NAME

    if [[ ! -d $OUTDIR/$BASE || ! -d $OUTDIR/$BASE/$INPUTFOLDER ]]; then
	    echo "No annotation dir for '$OUTDIR/${BASE}'"
	    exit
    fi
    if [[ ! -d $OUTDIR/$BASE/antismash_local && ! -s $OUTDIR/$BASE/antismash_local/index.html ]]; then
	    antismash --taxon fungi --output-dir $OUTDIR/$BASE/antismash_local  --genefinding-tool none \
	              --clusterhmmer --tigrfam --cb-general --pfam2go --rre --cc-mibig \
		      --cb-subclusters --cb-knownclusters -c $CPU \
	              $OUTDIR/$BASE/$INPUTFOLDER/*.gbk
    else
	echo "folder $OUTDIR/$BASE/antismash_local already exists, skipping."
    fi
done
