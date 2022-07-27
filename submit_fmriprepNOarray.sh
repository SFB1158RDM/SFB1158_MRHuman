#!/bin/bash
SCRIPTS_DIR=/pandora/data/Template4Bids/.../...scripts/fmripscripts/
#echo  SUB TIME MODE STARTDATE > ${SCRIPTS_DIR}/processingtime/fmriprep_NOarray.txt #create text  file for gettign indvidual preprocessing time 

bids_root_dir=/pandora/data/Template4Bids/.../
cd ${bids_root_dir}/rawdata
for sub in sub-SUPR*; do
	srun --nodelist=zilxhp04 /pandora/data/Template4Bids/.../scripts/fmripscripts/fmriprep_NOarray_job.sbatch  $sub
done
