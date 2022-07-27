function dicomsens(dicdir,IMAdir, fullfilename,vpid1,indcm,outdcm)

%     dicomsens(dicdir, IMAdir,fullfilename,vpid1,indcm,outdcm) %dicomsens is a function 

% created by Jamila Andoh, 07.06.2021, SNiP for BIDS template 
% read and edit dicom IMA for anonymisation and removes DOB, weight and height
dictroot='/pandora/data/Template4Bids/SUPER/scripts/matlabscripts/1_data_orga/callscripts/dicomdico';
%scriptsdir='/zi-flstorage/group_snip/Template4Bids/scripts/matlabscripts/'
%addpath(genpath('/zi-flstorage/group_snip/Template4Bids/scripts/matlabscripts/'))
mydict=fullfile(dictroot,'dicom-dictupdate.txt');

dicomdict('set',mydict)

info = dicominfo(sprintf([IMAdir fullfilename])) ;
info.PatientID=vpid1;
info.PatientWeight ='';
info.PatientSize='';
info.PatientBirthDate='';

dicomwrite(indcm, outdcm, info,'WritePrivate',true) 


             
           