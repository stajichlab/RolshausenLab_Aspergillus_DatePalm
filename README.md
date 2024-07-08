Genome assembly and annotation of A. tubingensis strain DFA
===

Multiple assemblers were run (canu, flye, raven) and best assembly chosen based on [asm_stats.tsv] results. This template setup
for running multiple samples is per the [Stajich lab](https://lab.stajich.org) setup for running assembly and annotation.

See the [pipeline] folder for assembly, annotation, and statistics calculations.

Notes:
* final assembly files used are called XX.pilon.fasta but the polishing step was actually POLCA used
* scaffold_10 was removed based on its identity to the subset of a match to scaffold_6
