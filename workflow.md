## Prepwork
### Retrieve .bed files from USCS table browser
> **genome**: stickleback  
**group**: variations and repeats  
**track**: repeat masker  

Download as .bed format

### Extract TE into seperate file
> bedtools getfasta -s -name -fi Gasterosteus_aculeatus.BROADS1du .dna.toplevel.fa  -fo NAME.teseqs.fasta -bed NAME.teannotation.bed

### Change .bed file annotation from chr to group  
This step changes the chromosome annotation so it can be read later by bedtools, 
it's optional if the headers are the same in the .bed and .fasta files
>sed -i 's/chr/group/g' NAME.bed

### Mask TE sequences 
> bedtools maskfasta -fi Gasterosteus_aculeatus.BROADS1.dna.toplevel.fa -fo NAME.masked.fasta -bed NAME.teannotation.bed

### Create Merged Ref
> cat NAME.masked.fasta NAME.teseqs.fasta > NAME.consensusTE.fasta

### create TE Hierarchy
> cat NAME.teseqs.fasta|grep '^>'|perl -pe 's/>//' > te-hierarchy.csv  

#trim .csv file to each TE and add family and order columns  
#Write out .txt file in custom script that looks for ids from the edited .csv 
file in the large .bed to trim down non TEs and family and orders 

### Index consensus.fasta
> bwa index NAME.consensusTE.fasta

## Create PPileUp File
### Split Large .fastq files
Because the raw .fastqs have to be edited directly to work with PPTE2 it's often useful to split the large .fasta files into smaller files. This can be done a number of ways as long reads aren't split. For isntance 
>pyfasta split -n 30 NAME.fastq
splits .fasta files into n smaller files to work with. 

Then split files can be worked on simultaneously using '&' in bash. 

### Reformat Headers
Because PoPoolationTE2 works with older fasta headers, newer headers need to be changed
> gunzip NAME_R*.fq.gz

>sed -i ‘s/Y/N/g’ NAME_R*.fq  
sed  -i ‘s/ 1:N:0:\(.*\)$/\#\1\/1/g’ NAME_R1.fq  
sed -i 's/ 2:N:0:\(.*\)$/\#\1\/2/g' NAME_R2.fq  

>gzip new_reform_NAME_R*.fq

### Map .fq.gz files to a .sam file
>mkdir map  
bwa bwasw -t 3 NAME.consensusTE.fasta reform_NAME_R*.fq.gz >map/Name_R*.sam

### Restore Paired End information one file at a time
> java -jar popte2.jar se2pe --fastq1 NAME_i_R1.fq.gz --fastq2 NAME_i_R2.fq.gz --bam1 NAME_i_R1.sam --bam2 NAME_i_R2.sam --sort --output NAME_i.te.bam

### Merge .sam files
> Samtools merge NAME.te.merged.bam NAME_*.te.bam

### Generate ppileup file
The ppileup file combines multiple bams to compare frequencies.
> java -jar popte2.jar ppileup --bam NAME_1.te.merged.bam --bam NAME_2.te.merged.bam --map-qual 15 --hier te-consensus.txt --output NAME.ppileup.gz

## Generate Frequency Data

### Coverage stats
TE detection is biased based on coverage, where a higher coverage gives more accurate TE detection, so it is often necessary to subsample physical coverage, however this also results in a loss of data. PoPoolationTE2 provides statistics to determine to which coverage to downsample to. 
> java -jar popte2.jar stat-coverage --ppileup NAME.ppileup.gz --output NAME.coverage.statistics

This outputs a text file format
>joint	1	3645153	0	0.00  
>joint	2	3325345	3645153	0.87  
>joint	3	3561583	6970498	1.67  
>joint	4	4010380	10532081	2.52  
>joint	5	4551360	14542461	3.47  
>joint	6	5144029	19093821	4.56  
>joint	7	5701741	24237850	5.79  
>joint	8	6258252	29939591	7.15  
>joint	9	6814709	36197843	8.65  
>joint	10	7350712	43012552	10.28 

* col1: sample ID from the ppileup file, e.g. 1 means the first sample in the ppileup; joint means the minimum over all samples
* col2: the coverage
* col3: number of bases having this coverage (for joint: number of bases having at least this coverage among all samples)
* col4: cumulative value of col3
* col5: fraction of sites in the genome having the given or a lower coverage; NOTE for joint this column can be interpreted as the fraction of sites that will be lost when subsampling the coverage to the value given in col2

### Subsample
The ppileup file can be subsampled to the desired coverage with PoPoolationTE2's subsample function
>java -jar popte2.jar subsamplePpileup --ppileup NAME.ppileup.gz" --target-coverage COV --output NAME.ssCOV.ppileup.gz

## Identify Signatures
>java -jar popte2.jar identifySignatures --ppileup NAME.ssCOV.ppileup.gz --mode joint --output NAME.ssCOV.signatures --min-count 2 --signature-window minimumSampleMedian --min-valley minimumSampleMedian

## Generate Frequency
java -jar popte2.jar pairupSignatures --signature COV.ssCOV.freqsig --ref-genome NAME.consensusTE.fasta --hier NAME.tehier.txt" --min-distance -200 --max-distance 300 --output NAME.ssCOV.teinsertions







