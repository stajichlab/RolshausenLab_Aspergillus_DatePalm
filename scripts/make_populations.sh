#!/usr/bin/bash -l
module load csvkit
echo -e "Populations:\n\n  All:" > population_sets.yaml
IFS=,
tail -n +2 popgen_samples.csv | csvcut -c 1,2 | while read POPNAME FILES
do
	echo "    - $POPNAME"
done >> population_sets.yaml
