#!/bin/bash -l



#$ -S /bin/bash
#$ -l h_rt=4:0:0
#$ -l mem=1G
#$ -l tmpfs=15G
#$ -N test1
#$ -wd /home/ucqbpsy/Scratch/Simulations/test/

WORK_DIR=/home/ucqbpsy/Scratch/Simulations/test/
OUT_DIR=Output/
array=(eso audit bnd svg eio mtd dxf mdd [9]=shd)

cd $TMPDIR
module unload compilers/gnu/4.6.3
module load compilers/gnu/4.9.2

for i in $(ls $WORK_DIR*.idf); do
	runenergyplus $i cntr_Islington_DSY
	for exten in ${array[*]}; do
		rm $WORK_DIR$OUT_DIR*$exten
	done
done
