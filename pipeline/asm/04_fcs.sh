#!/usr/bin/bash -l
#SBATCH --mem 512gb -N 1 -n 1 -c 64 --out logs/fcs_classify.purge.log

module load AAFTF
hostname
rsync -a --progress /srv/projects/db/ncbi-fcs/0.5.4/gxdb /dev/shm/
#Fungi
TAXID=5052
INDIR=final_genomes
OUTDIR=contam_reports
mkdir -p $OUTDIR
parallel -j 2 AAFTF fcs_gx_purge  --db /dev/shm/gxdb/all  -i {} --cpus 8 -o $OUTDIR/{/.}.fcs_purge.fasta -t ${TAXID} -w $OUTDIR/{/.}.report ::: $(ls -U $INDIR/*.sorted.fasta)

rm -rf /dev/shm/gxdb
