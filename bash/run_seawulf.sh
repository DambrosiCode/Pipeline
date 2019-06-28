#!/bin/bash

batchloc="C:/Documents/Pipeline/bash/"
fastqloc="C:/Documents/fastqs/"

if [ ! -f status.txt ]; then
  echo "POP|Split|Rewrite|Map|Restore|Merge|Ppileup" > status.txt
  ls "/gpfs/scratch/madambrosio/PoPoolation/Lake_fastqs/"|cut -d _ -f 2 >> status.txt
fi

while [ ! -d "/gpfs/scratch/madambrosio/PoPoolation/Lake_fastqs/Sample_$pop/" ]; do
  cat "/gpfs/home/madambrosio/bin/status.txt"
  #ls "/gpfs/scratch/madambrosio/PoPoolation/Lake_fastqs/"
  echo 'Which population? ' 
  read pop
done

while [ ! -f "/gpfs/home/madambrosio/bin/$script.pbs" ]; do
  cd /gpfs/home/madambrosio/bin/
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

  qsub -v I=$i,POP=$pop,fastq=$fastqloc "/$batchloc/map.pbs"

elif [ "$script" = "merge" ]
then
  qsub -v I=$i,POP=$pop,fastq=$fastqloc "/$batchloc//merge.pbs"

elif [ "$script" = "split" ]
then
  qsub -v POP=$pop,fastq=$fastqloc "/$batchloc//split.pbs

elif [ "$script" = "restore" ]
then
  qsub -v POP=$pop,fastq=$fastqloc "/$batchloc//restore.pbs"

elif
then
  qsub -v POP=$pop,fastq=$fastqloc "/$batchloc//merge_fastqs.pbs"

elif [ "$script" = "rewrite" ]
then
  qsub -v POP=$pop,fastq=$fastqloc "/$batchloc//rewrite.pbs"

elif [ "$script" = "ppileup" ]
then
  qsub -v POP=$pop,fastq=$fastqloc "/$batchloc//ppileup.pbs"
fi 