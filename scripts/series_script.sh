#/bin/bash!
qsub -q consort -l walltime=04:00:00,nodes=1:ppn=12 EPG_1.sh
