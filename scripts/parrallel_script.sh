#!/bin/bash -l

# Batch script to run an array job on Legion with the upgraded
# software stack under SGE.

# 1. Force bash
#$ -S /bin/bash

# 2. Request ten minutes of wallclock time (format hours:minutes:seconds).
#$ -l h_rt=4:0:0

# 3. Request 1 gigabyte of RAM.
#$ -l mem=1G

# 4. Request 15 gigabyte of TMPDIR space (default is 10 GB)
#$ -l tmpfs=15G

# 5. Set up the job array.  In this instance we have requested task IDs
# numbered 1 to 10000 with a stride of 10.

WORK_DIR=/home/ucqbpsy/Scratch/Simulations/stride
#$ -t 1-200:20

# 6. Set the name of the job.
#$ -N hpru_test

# 7. Set the working directory to somewhere in your scratch space.  This is
# a necessary step with the upgraded software stack as compute nodes cannot
# write to $HOME.
# Replace "<your_UCL_id>" with your UCL user ID :)
#$ -wd /home/ucqbpsy/Scratch/Simulations/stride

# 9. Do your work in $TMPDIR 
cd $TMPDIR

# 10. Loop through the IDs covered by this stride and run the application if 
# the input file exists. (This is because the last stride may not have that
# many inputs available). Or you can leave out the check and get an error.

mkdir $WORK_DIR/Output

for (( i=$SGE_TASK_ID; i<$SGE_TASK_ID+20; i++ ))
do
  if [ ! -d '$WORK_DIR/Temp_$SGE_TASK_ID' ]; then 
	 mkdir $WORK_DIR/Temp_$SGE_TASK_ID 
  fi 
  cp $WORK_DIR/EPG2_$i.idf $WORK_DIR/Temp_$SGE_TASK_ID
  runenergyplus $WORK_DIR/Temp_$SGE_TASK_ID/EPG2_$i.idf cntr_Islington_DSY
  cp $WORK_DIR/Temp_$SGE_TASK_ID/Output/EPG2_$i.err $WORK_DIR/Output
  cp $WORK_DIR/Temp_$SGE_TASK_ID/Output/EPG2_$i.csv $WORK_DIR/Output
  rm -fr $WORK_DIR/Temp_$SGE_TASK_ID
done
