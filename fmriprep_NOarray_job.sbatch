#!/bin/bash
# from JA 27/07/2022
# preprocessing pipeline for fmriprep  using container
#SBATCH --job-name=fmriprep
#SBATCH --cpus-per-task=16
#SBATCH --output=~/fmripprep_%J.out
#SBATCH --output=/server/project/.../tmp/slurm4fmriprepNOARRAY_%J.out


sub=${1}

image=/pandora/opt/container/fmriprep_20.2.1.sif %location fmriprep
bids_root_dir=/server/project/../
LOCAL_FREESURFER_DIR=/server/freesurfer_7.beta/bin/freesurfer %location freesurfer
TEMPLATEFLOW_DIR="/server/project/templateflow"
SUBJECTS_DIR=/server/local/freesurfer/subjects
LOCAL_FREESURFER_DIR=/server/freesurfer_7.beta/bin/freesurfer
#cd $bids_root_dir
SCRIPTS_DIR=/server/project/.../scripts/fmripscripts/
PATH=$PATH:"/server/project/.../scripts/bashscripts/callscripts/"
MODE=noarray
cd ${bids_root_dir}/rawdata

echo subject is: $sub

  unset PYTHONPATH; singularity run --cleanenv -B $bids_root_dir -B /server/project/:$TEMPLATEFLOW_DIR $image \
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





