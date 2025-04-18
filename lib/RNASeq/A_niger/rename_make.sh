#!/usr/bin/bash -l
#SBATCH -p short -c 48 --mem 24gb 

CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi

STEM=$(basename `pwd`)

if [ -f ../${STEM}_R2.fastq.gz ]; then
	echo "${STEM}_R2.fastq.gz already exists"
	exit
fi

dorename() {
	in=$(basename $1 _1.fastq.gz)
	if [ ! -f ${in}_R1.fastq ]; then
		pigz -dc ${in}_1.fastq.gz | perl -p -e 's/^(\@SRR\S+\.\d+).+/$1\/1/; s/^\+\S+\.\d+.+/+/' > ${in}_R1.fastq
	fi
	if [ ! -f ${in}_R2.fastq ]; then
		pigz -dc ${in}_2.fastq.gz | perl -p -e 's/^(\@SRR\S+\.\d+).+/$1\/2/; s/^\+\S+\.\d+.+/+/' > ${in}_R2.fastq
	fi
}
export -f dorename

parallel dorename ::: $(ls *_1.fastq.gz)
cat *_R1.fastq | pigz -c > ../${STEM}_R1.fastq.gz
cat *_R2.fastq | pigz -c > ../${STEM}_R2.fastq.gz
