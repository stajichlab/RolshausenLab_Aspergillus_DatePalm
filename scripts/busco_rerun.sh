#!/usr/bin/bash -l

EXT=fasta
OUTFOLDER=BUSCO
N=1
for GENOMEFILE in $(ls genomes/*.fasta | grep -v sorted | grep -v masked)
do
	NAME=$(basename $GENOMEFILE .$EXT)
	if [ ! -d "$OUTFOLDER/${NAME}" ];  then
		echo "$N ($OUTFOLDER/$NAME)"
	fi
	N=$(expr $N + 1)
done
