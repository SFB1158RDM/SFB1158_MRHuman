function dicomsens(dicdir,IMAdir, fullfilename,vpid1,indcm,outdcm)
% created by JA, 27.07.2022
% usage: dicomsens(dicdir, IMAdir,fullfilename,vpid1,indcm,outdcm) 
% read and edit dicom IMA for anonymisation and removes DOB, weight and height
dictroot='/serverdir/projectdir/scripts/matlabscripts/1_data_orga/callscripts/dicomdico';

mydict=fullfile(dictroot,'dicom-dictupdate.txt'); %edited siemens dictionary for dwi for example

dicomdict('set',mydict) %set up new siemens dictionary 

info = dicominfo(sprintf([IMAdir fullfilename])) ; %get information of dicoms. dicominfo is matlab function
info.PatientID=vpid1; %get patient ID
info.PatientWeight =''; %get patient weight
info.PatientSize=''; %get patient height
info.PatientBirthDate=''; %get  date of birth

dicomwrite(indcm, outdcm, info,'WritePrivate',true) % rewrite the data "info" into outdcm. the data "info" is removed from sensitive information.


             
           
