#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 1 -c 2 --mem 24gb  --out logs/find_telomeres.log

module load parallel

mkdir -p telomere_reports
for a in $(ls genomes/*.fasta)
do
	python scripts_Hiltunen/find_telomeres.py -m 'TA[A]+[C]+' $a > telomere_reports/$(basename $a .fasta).telomere_report.txt
done
