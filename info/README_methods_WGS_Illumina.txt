README_methods_WGS_gDNA

Samples were prepared for whole genome sequencing using the Illumina DNA Prep tagmentation kit and unique dual indexes.

Sequencing was performed on the Illumina NextSeq2000 platform using a 300 cycle flow cell kit to produce 2x150bp paired reads. 1-2% PhiX control was spiked into the run to support optimal base calling.

Read demultiplexing, read trimming, and run analytics were performed using DRAGEN v3.10.12, an on-board analysis software on the NextSeq2000. We include fastqc metrics as a best practice and for examination in the case of unexpected outputs.

The fastq file naming convention is OrderNumber_SeqCoastTubeID_IlluminaSampleSheetID_Read1orRead2. The SeqCoast Tube ID will match up with the sample manifest so that you know which files belongs to which sample. The Illumina Sample Sheet ID is an internal identifier for the sequencer, and R1/R2 tells you which of the paired reads was sequenced first.

If any of your samples required a second round of sequencing, you will notice two sets of fastq files (total of four files) and two fastqc folders for that sample. The Illumina Sample Sheet ID (SXX) in the file names will match across these file sets. Common causes of not getting enough reads in the first round of sequencing are low input amount and presence of extraction contaminants such as phenol. We recommend using a Qubit to measure concentrations and column-based extraction kits. NanoDrop measurements tend to greatly overestimate DNA concentrations, especially when contaminants are present.

Raw reads are retained on the SeqCoast server for 1 year from the date of data delivery.

SeqCoast offers both standard and custom bioinformatics analyses!