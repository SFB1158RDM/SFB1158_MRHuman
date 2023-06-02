# SFB1158_MRHuman

This repository contains code for the SFB1158_MRHuman project, which focuses on understanding human behavior using multimodal data acquired through magnetic resonance (MR) imaging.

## Table of Contents

- [Introduction](#introduction)
- [Code](#code)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Introduction

The SFB1158_MRHuman project aims to convert raw data into BIDS format obtained through magnetic resonance (MR) imaging techniques. This repository serves as a central location for storing code related to the project.

## Code

The code folder in this repository contains various scripts for data analysis, processing, and other related tasks. The code is organized into subfolders based on different functionalities or analyses. Each subfolder may contain multiple scripts and associated dependencies.

#### **BOLD_ANONconvBIDS.m script**

This MATLAB script performs several steps to preprocess and convert data to the Brain Imaging Data Structure (BIDS) format. It follows the BIDS structure and performs the following steps:

1. Anonymize source DICOM data: This step removes personal identifiers such as date of birth (DOB), weight, and height from the DICOM files.
2. Convert to NIfTI following BIDS structure: The script converts the anonymized DICOM files to NIfTI format while organizing them according to the BIDS directory structure.
3. Read and extract physiological recordings: The script reads and extracts physiological recordings from the DICOM files. This step is specifically designed for multiband EPI data from the CMRR (Center for Magnetic Resonance Research) sequence.
4. Removal of initial volumes: The script removes the first four volumes from the converted NIfTI files.

#### Use
To use the above script, follow these steps:
- Ensure that MATLAB is installed on your system.
- Clone or download the script from the repository.
- Open the ANONconvBIDS.m script in MATLAB.
- Modify the wdir variable to specify the working directory where the script is located.
- Modify the paths defined in the script according to your specific project structure.
- Run the script.
Note: Make sure to have the required dependencies (such as SPM) installed and added to MATLAB's path.

#### **dicomsens.m script**

This MATLAB function is used for reading and editing DICOM (Digital Imaging and Communications in Medicine) files to perform anonymization. It specifically removes sensitive information such as date of birth (DOB), weight, and height from the DICOM files.

#### Use
To use this function, follow these steps:

1. Ensure that MATLAB is installed on your system.
2. Clone or download the script from the repository.
3. Open the dicomsens.m function in MATLAB.
4. Modify the paths defined in the function according to your specific project structure.
5. Call the dicomsens function with the following input arguments:

- dicdir: Directory path for DICOM dictionary files.
- IMAdir: Directory path where the original DICOM files are located.
- fullfilename: Name of the DICOM file to be processed.
- vpid1: Patient ID.
- indcm: Input DICOM data.
- outdcm: Output DICOM file path.

The function will read the DICOM file, remove the specified sensitive information (DOB, weight, and height), and write the modified DICOM data to the output file specified by outdcm.
Note: Make sure to have the required DICOM dictionary files and dependencies set up correctly.

#### **fmriprep_NOarray_job.sbatch script**

##### fMRIPrep Preprocessing Pipeline

This script provides a preprocessing pipeline for fMRIPrep using a Singularity container. The pipeline automates the preprocessing steps required for fMRI data analysis using the fMRIPrep tool. It is designed to be run on a cluster using the Slurm job scheduler.

#### Prerequisites

- Slurm job scheduler
- Singularity container with fMRIPrep (version 20.2.1) installed

#### Use

1. Ensure that the necessary prerequisites are met, including the installation of Slurm and the fMRIPrep Singularity container.
2. Modify the script variables according to your setup:
   - `image`: Path to the fMRIPrep Singularity container.
   - `bids_root_dir`: Root directory of the BIDS dataset.
   - `LOCAL_FREESURFER_DIR`: Path to the FreeSurfer installation.
   - `TEMPLATEFLOW_DIR`: Path to the TemplateFlow directory.
   - `SUBJECTS_DIR`: Directory for FreeSurfer subjects.
   - `SCRIPTS_DIR`: Directory for fMRIPrep scripts.
3. Set the necessary Slurm directives:
   - `#SBATCH --job-name`: Specify the job name.
   - `#SBATCH --cpus-per-task`: Specify the number of CPUs per task.
   - `#SBATCH --output`: Specify the output file paths.
4. Execute the script by providing the subject ID as the command-line argument.

```bash
./preprocessing_pipeline.sh subject_id
```

#### Output

The script will generate output files and directories in the specified `bids_root_dir/derivatives` directory. The exact output will depend on the configuration and options passed to fMRIPrep.

#### Additional Notes

- Make sure to adjust the paths and variables in the script to match your specific setup.
- Consult the fMRIPrep documentation for more information on available options and customization.
- This script assumes the use of Slurm job scheduler. If you are using a different job scheduler, you may need to modify the script accordingly.
- The script may require additional modifications based on your specific preprocessing requirements.


## Repository Usage

To use the code and data in this repository, follow these steps:

1. Clone the repository:

   ```bash
   git clone https://github.com/SFB1158RDM/SFB1158_MRHuman.git
   ```

2. Install any required dependencies mentioned in the individual scripts or notebooks.

3. Explore the data in the `data` folder or run the scripts in the `code` folder for data analysis or processing.

## Contributing

We welcome contributions to the SFB1158_MRHuman project. If you would like to contribute, please follow these steps:

1. Fork the repository.

2. Create a new branch for your feature or bug fix:

   ```bash
   git checkout -b feature/your-feature-name
   ```

3. Make your changes and commit them:

   ```bash
   git commit -m "Description of your changes"
   ```

4. Push your changes to your forked repository:

   ```bash
   git push origin feature/your-feature-name
   ```

5. Open a pull request in this repository, describing your changes and the motivation behind them.

## License

The SFB1158_MRHuman project is licensed under the BSD (LICENSE). Please refer to the LICENSE file for more details.


## References

1. Esteban O, Markiewicz CJ, Blair RW, Moodie CA, Isik AI, Erramuzpe A, Kent JD, Goncalves M, DuPre E, Snyder M, Oya H, Ghosh SS, Wright J, Durnez J, Poldrack RA, Gorgolewski KJ. fMRIPrep: a robust preprocessing pipeline for functional MRI. Nat Methods. 2019 Jan;16(1):111-116. doi: 10.1038/s41592-018-0235-4. Epub 2018 Dec 10. PMID: 30532080; PMCID: PMC6319393. 
2. Li X, Morgan PS, Ashburner J, Smith J, Rorden C. The first step for neuroimaging data analysis: DICOM to NIfTI conversion. J Neurosci Methods. 2016 May 1;264:47-56. doi: 10.1016/j.jneumeth.2016.03.001. Epub 2016 Mar 2. PMID: 26945974.
3. https://bids.neuroimaging.io/ 
4. https://fmriprep.org/en/stable/outputs.html 
5. https://docs.sylabs.io/guides/3.5/user-guide/introduction.html
6. 


