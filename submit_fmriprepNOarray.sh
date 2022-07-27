#!/bin/bash
# by JA 27/07/2022
SCRIPTS_DIR=/server/project/.../...scripts/fmripscripts/ #define scritps directory 
bids_root_dir=/server/project/.../  #define BIDS project directory 
cd ${bids_root_dir}/rawdata
for sub in sub-PROJ*; do %loop through all subjects
	srun --nodelist=zilxhp04 /server/project/.../scripts/fmripscripts/fmriprep_job.sbatch  $sub #runs script in bash mode usign SLURM
done
