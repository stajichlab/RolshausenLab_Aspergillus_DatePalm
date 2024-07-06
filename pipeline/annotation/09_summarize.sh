#!/usr/bin/bash -l

#SBATCH -p short -N 1 -n 2 --mem 8gb

echo "would do summary of annotation - but a lot of this is generated in .json files from funanotate - this was an attempt to aggregate all of these in a single table"
echo "still need to re-write that bit"
#perl scripts/summarize_annotation.pl > annotation_summary.tsv

