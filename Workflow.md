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
> java -jar popte2.jar ppileup --bam NAME.te.merged.bam --map-qual 15 --hier te-consensus.txt --output NAME.ppileup.gz






