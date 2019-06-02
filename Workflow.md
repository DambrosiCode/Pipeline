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

