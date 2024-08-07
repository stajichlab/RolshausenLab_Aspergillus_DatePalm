#!/usr/bin/bash -l 
#SBATCH -p short --mem 2gb --out logs/00_index.log
module load samtools
module load bwa-mem2
if [ -f config.txt ]; then
	source config.txt
fi

PREF=Aspergillus_tubingensis_DFA
FASTAFILE=Aspergillus_tubingensis_DFA.scaffolds.fa
pushd $GENOMEFOLDER
if [[ ! -f $FASTAFILE.fai || $FASTAFILE -nt $FASTAFILE.fai ]]; then
	samtools faidx $FASTAFILE
fi
if [[ ! -f $FASTAFILE.bwt || $FASTAFILE -nt $FASTAFILE.bwt ]]; then
	bwa-mem2 index $FASTAFILE
fi

DICT=$(basename $FASTAFILE .fasta)".dict"

if [[ ! -f $DICT || $FASTAFILE -nt $DICT ]]; then
	rm -f $DICT
	samtools dict $FASTAFILE > $DICT
	ln -s $DICT $FASTAFILE.dict 
fi
grep ">" $FASTAFILE | perl -p -e 's/>(scaffold(\d+|mito)_(\S+))\s+.+/$1,$3/; s/,9$/,MT/' > chrom_nums.csv
popd
