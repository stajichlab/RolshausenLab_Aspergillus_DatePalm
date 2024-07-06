#!/usr/bin/bash -l
#SBATCH -N 1 -n 1 -c 32 --mem 24G -J readcount --out logs/bbcount.%a.log --time 48:00:00 -a 1
module load BBMap
hostname
MEM=24
CPU=$SLURM_CPUS_ON_NODE
N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
    N=$1
    if [ ! $N ]; then
        echo "Need an array id or cmdline val for the job"
        exit
    fi
fi

INDIR=input
SAMPLES=samples.csv
EXT=fasta
GENOMEFOLDER=genomes
OUTDIR=$(realpath mapping_report)
SAMPLES=samples.csv
mkdir -p $OUTDIR

IFS=, # set the delimiter to be ,
IFS=, # set the delimiter to be ,

tail -n +2 $SAMPLES | sed -n ${N}p | while read NAME SPECIES STRAIN NANOPORE ILLUMINA SUBPHYLUM PHYLUM LOCUS RNASEQ
do    
    LEFT=$(realpath $INDIR/illumina/${ILLUMINA}_R1_001.fastq.gz)
    RIGHT=$(realpath $INDIR/illumina/${ILLUMINA}_R2_001.fastq.gz)
    
    echo "$LEFT $RIGHT"
    for polish in pilon medaka.sorted
    do
	for type in flye raven
	do
	    GENOMEFILE=$GENOMEFOLDER/$NAME.$type.$polish.$EXT
	    echo "GENOMEFILE is $GENOMEFILE"
	    if [ -f $GENOMEFILE ]; then
		GENOMEFILE=$(realpath $GENOMEFILE)
                REPORTOUT=${NAME}.${type}.$polish                
                if [ ! -s $OUTDIR/${REPORTOUT}.bbmap_covstats.txt ]; then
                    pushd $SCRATCH
		    bbmap.sh -Xmx${MEM}g ref=$GENOMEFILE in=$LEFT in2=$RIGHT \
			     covstats=$OUTDIR/${REPORTOUT}.bbmap_covstats.txt  statsfile=$OUTDIR/${REPORTOUT}.bbmap_summary.txt
                    popd
	        fi
	    fi
	done
    done
done
