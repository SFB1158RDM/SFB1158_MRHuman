#!/bin/bash

#SBATCH --job-name=fmriprep
#SBATCH --cpus-per-task=16
#SBATCH --output=~/fmripprep_%J.out
#SBATCH --output=/pandora/data/.../tmp/slurm4fmriprepNOARRAY_%J.out

#

sub=${1}

image=/pandora/opt/container/fmriprep_20.2.1.sif
bids_root_dir=/pandora/data/Template4Bids/../
LOCAL_FREESURFER_DIR=/ropt/freesurfer_7.beta/bin/freesurfer
TEMPLATEFLOW_DIR="/pandora/data/Template4Bids/templateflow"
SUBJECTS_DIR=/usr/local/freesurfer/subjects
LOCAL_FREESURFER_DIR=/ropt/freesurfer_7.beta/bin/freesurfer
#cd $bids_root_dir
SCRIPTS_DIR=/pandora/data/Template4Bids/.../scripts/fmripscripts/
PATH=$PATH:"/pandora/data/Template4Bids/.../scripts/bashscripts/callscripts/"
MODE=noarray
cd ${bids_root_dir}/rawdata

START=$(date +%s.%N)

startdate=$(date -d "today" '+%Y-%m-%d')


echo subject is: $sub

  unset PYTHONPATH; singularity run --cleanenv -B $bids_root_dir -B /pandora/data/Template4Bids/:$TEMPLATEFLOW_DIR $image \
	$bids_root_dir/rawdata $bids_root_dir/derivatives \
	participant \
	--participant-label ${sub} \
	--skip-bids-validation \
	--fs-license-file $bids_root_dir/derivatives/license.txt \
	-vv --omp-nthreads 16 --nthreads 64 --mem_mb 30000 \
	--use-syn-sdc \
	--fs-no-reconall \
	-w $HOME \
	--output-spaces MNI152NLin2009cAsym:res-2 anat fsnative fsaverage5 --use-aroma 

END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
echo end is $END 
echo DIFF START-END is $DIFF
#	--fs-no-reconall \
DIFFs=$(echo $DIFF | awk '{printf "%d:%02d:%02d", $1/3600, ($1/60)%60, $1%60}')
STARTs=$(echo $START | awk '{printf "%d:%02d:%02d", $1/3600, ($1/60)%60, $1%60}')
echo  $sub $DIFFs $MODE $startdate >> ${SCRIPTS_DIR}/processingtime/fmriprep_NOarray.txt




