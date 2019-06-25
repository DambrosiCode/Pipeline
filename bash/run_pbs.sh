#!/bin/bash

#replace with bash script location 
bashloc=/C:/usr/documents/bash 

#replace with location of fastq files
fastqloc=/C:/usr/documents/fastqs

while [ ! -d "$fastqloc/Sample_$pop/" ]; do
  ls "$fastqloc"
  echo 'Which population? ' 
  read pop
done

while [ ! -f "$bashloc/$script.pbs" ]; do
  cd $bashloc
  ls *.pbs
  echo 'Which script? ' 
  read script
done

module load shared 
module load torque

if [ "$script" = "map" ]
then
  echo 'Which Read? '
  read i

  qsub -v I=$i,POP=$pop,fastqloc=$fastqloc '$bashloc/map.pbs'
  
elif [ "$script" = "merge" ]
then
  qsub -v I=$i,POP=$pop,fastqloc=$fastqloc '$bashloc/merge.pbs'
  
elif [ "$script" = "split" ]
then
  qsub -v POP=$pop,fastqloc=$fastqloc '$bashloc/split.pbs'

elif [ "$script" = "restore" ]
then
  qsub -v POP=$pop,fastqloc=$fastqloc '$bashloc/restore.pbs'
  
elif [ "$script" = "gzip" ]
then
  qsub -v POP=$pop,fastqloc=$fastqloc '$bashloc/gzip.pbs'

elif [ "$script" = "merge_fastqs" ]
then
  qsub -v POP=$pop '$bashloc/merge_fastqs.pbs'

elif [ "$script" = "rewrite" ]
then
  qsub -v POP=$pop,fastqloc=$fastqloc '$bashloc/rewrite.pbs'

elif [ "$script" = "ppileup" ]
then
  qsub -v POP=$pop,fastqloc=$fastqloc '$bashloc/ppileup.pbs'
fi
