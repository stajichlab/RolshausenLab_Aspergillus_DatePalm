#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 2 --mem 4gb --out logs/stats.log

module load AAFTF

IFS=,
SAMPLES=samples.csv
INDIR=asm
OUTDIR=genomes

mkdir -p $OUTDIR

tail -n +2 $SAMPLES | sed -n ${N}p | while read BASE ILLUMINASAMPLE SPECIES INTERNALID PROJECT DESCRIPTION ASMFOCUS STRAIN LOCUS
do
    rsync -a $INDIR/canu/$BASE/$BASE.contigs.fasta $OUTDIR/$BASE.canu.fasta
    rsync -a $INDIR/flye/$BASE/assembly.fasta $OUTDIR/$BASE.flye.fasta
    rsync -a $INDIR/raven/$BASE.scaffolds.fasta $OUTDIR/$BASE.raven.fasta
    if [ -d $INDIR/NECAT/$BASE/$BASE/6-bridge_contigs ]; then
	rsync -a $INDIR/NECAT/$BASE/$BASE/6-bridge_contigs/polished_contigs.fasta $OUTDIR/$BASE.necat.fasta
    fi

    for type in canu flye raven
    do
	if [ -f  $INDIR/pilon/$BASE/$type.pilon.fasta ];  then
		AAFTF sort -i $INDIR/pilon/$BASE/$type.pilon.fasta -o $OUTDIR/$BASE.$type.pilon.fasta
		AAFTF assess -i $OUTDIR/$BASE.$type.pilon.fasta -r $OUTDIR/$BASE.$type.pilon.stats.txt
	fi
	STATS=$OUTDIR/$BASE.$type.stats.txt
	QUERY=$OUTDIR/$BASE.$type.fasta
	if [[ -s $QUERY ]]; then
	    if [[ ! -s $STATS || $QUERY -nt $STATS ]]; then
		AAFTF assess -i $QUERY -r $STATS
	    fi
	fi
	# copy medka
	polishtype=medaka
	QUERY=$INDIR/$polishtype/$BASE/$type.polished.fasta
	SORTED=$OUTDIR/$BASE.$type.$polishtype.sorted.fasta
	STATS=$OUTDIR/$BASE.$type.$polishtype.sorted.stats.txt
	if [ -f $QUERY ]; then
		if [[ ! -s $SORTED || $QUERY -nt $SORTED ]]; then
			AAFTF sort -i $QUERY -o $SORTED
		fi
		if [[ ! -s $STATS || $SORTED -nt $STATS ]]; then
                	AAFTF assess -i $SORTED -r $STATS
		fi
	fi
    done
done
