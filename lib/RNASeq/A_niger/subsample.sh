#!/usr/bin/bash -l
#SBATCH -p short -c 16 --mem 8gb 
module load BBMap
pushd all
for a in $(ls *_1.fastq.gz); do b=$(basename $a _1.fastq.gz); reformat.sh in=${b}_1.fastq.gz in2=${b}_2.fastq.gz out=../subsample/${b}_1.fastq.gz out2=../subsample/${b}_2.fastq.gz sampleseed=141 samplerate=0.25 ; done
