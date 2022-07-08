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
#$ -l tmpfs=1G

# 5. Set up the job array.  In this instance we have requested task IDs
# numbered 1 to 10000 with a stride of 10.

#$ -t 1-240:20

# 6. Set the name of the job.
#$ -N eplus

# 7. Set the working directory to somewhere in your scratch space.  This is
# a necessary step with the upgraded software stack as compute nodes cannot
# write to $HOME.
# Replace "<your_UCL_id>" with your UCL user ID :)
#$ -wd /home/ucbqc38/HeatExposure/demo

module unload -f compilers mpi gcc-libs
module load gcc-libs/4.9.2
module load compilers/gnu/4.9.2

WORK_DIR=/home/ucbqc38/HeatExposure/demo

# List all input files
cd $WORK_DIR
array=($(ls -d $WORK_DIR/220707_demo/*/*idf))

# 10. Loop through the IDs covered by this stride and run the application if 
# the input file exists. (This is because the last stride may not have that
# many inputs available). Or you can leave out the check and get an error.
set -x # echo commands
for (( i=$SGE_TASK_ID; i<$SGE_TASK_ID+20; i++ ))
do
  cd $WORK_DIR
  target=${array[$i]}
  target_dir="$(dirname "$target")"
  target_name="$(basename "$target" .idf)"
  temp_dir=$WORK_DIR/Temp_$i
  if [ ! -d $temp_dir ]; then 
	 mkdir $temp_dir
	 mkdir $temp_dir/Output
  fi 

  cp $target $temp_dir
  cd $temp_dir

  runenergyplus $target_name.idf cntr_Islington_DSY

  # Copy the results back to the target directory
  if [ ! -d '$target_dir/Output' ]; then 
	 mkdir $target_dir/Output
  fi 
  cp Output/$target_name.err $target_dir/Output
  cp Output/$target_name.csv $target_dir/Output
  cd $WORK_DIR
  rm -fr $temp_dir
done
