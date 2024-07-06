#!/bin/bash -l
#SBATCH --nodes 1 --ntasks 8 --mem 16G -p short --out logs/busco.%a.log -J busco -a 1

# for augustus training
# set to a local dir to avoid permission issues and pollution in global
module unload miniconda3
module load busco
#export AUGUSTUS_CONFIG_PATH=/bigdata/stajichlab/shared/pkg/augustus/3.3/config
export AUGUSTUS_CONFIG_PATH=$(realpath lib/augustus/3.5/config)

module load workspace/scratch

CPU=${SLURM_CPUS_ON_NODE}
N=${SLURM_ARRAY_TASK_ID}
if [ ! $CPU ]; then
     CPU=2
fi

if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
        echo "Need an array id or cmdline val for the job"
        exit
    fi
fi
GENOMEFOLDER=genomes
EXT=fasta
LINEAGE=ascomycota_odb10
OUTFOLDER=BUSCO
SAMPLES=samples.csv
SEED_SPECIES=aspergillus_nidulans
SAMPLES=samples.csv
mkdir -p $OUTFOLDER

IFS=, # set the delimiter to be ,
tail -n +2 $SAMPLES | sed -n ${N}p | while read BASE ILLUMINASAMPLE SPECIES INTERNALID PROJECT DESCRIPTION ASMFOCUS STRAIN LOCUS
do
    ID=$BASE
    for polish in pilon medaka.sorted
    do
		for type in canu flye raven
		do
			GENOMEFILE=$GENOMEFOLDER/$ID.$type.$polish.$EXT
			echo "GENOMEFILE is $GENOMEFILE"
			if [ -f $GENOMEFILE ]; then
				GENOMEFILE=$(realpath $GENOMEFILE)
				if [ -d "$OUTFOLDER/${ID}" ]; then
					echo "Already have run $ID in folder busco - do you need to delete it to rerun?"
					continue
				else
					echo "will run $GENOMEFILE  into -> $OUTFOLDER/${ID}.${type}.${polish}"
					busco -m genome -l $LINEAGE -c $CPU -o ${ID}.${type}.${polish} --out_path ${OUTFOLDER} \
					--offline --augustus_species $SEED_SPECIES \
					--in $GENOMEFILE --download_path $BUSCO_LINEAGES
				fi
			fi
		done
    done
done
