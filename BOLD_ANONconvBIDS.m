function ANONconvBIDS(subdic)
% Adapted by J.A, 27.07.2022
%step1: anaonymise source dicom data (remove participant idenfier: DOB, weight, height)
%step2: convert to nifti following BIDS stucture 
%step3: read and extract physiological recordings 
%step4: removal n=4 first volumes

wdir='/serverdir/project/scripts/matlabscripts/'%defines working directory
cd(wdir) %changes directory to wdir
addpath(genpath(wdir)) %adds directory & generates path that includes wdir and subdirectories 

[bids_root_dir, sourcedir, rawdir, derivdir, isolondir,qcdir, scriptsdir, dicdir,tasks, proj] = BIDSDIR_dir;
%define path to be used across all matlab scripts
addpath('/ropt/spm12_r6906') %choose spm version

SUB_DIR=dir(fullfile(isolondir, 'SU*')); %defines SUB_DIR as directory with source data of mentioned subject
      
for subnum = 1: length(SUB_DIR) %creates a loop: for all subjects in SUB_DIR, do the following:
    subdic=SUB_DIR(subnum).name %defines subdic as currently processed subject data
    %Name returns the name that identifies the subject data

IMAdir= [isolondir, subdic '/Tasks/'] %defines source directory (with original dicom files) 

    if (~exist(IMAdir)) %if "Tasks" does not exist, output:
        disp('subject and session not acquired yet')     
    else %if "Tasks" exists do the following:
       bids_ses='ses-01' %defines session you want to work with
        ses={'01'}; %creates variable
       subbids1= extractBetween(subdic,'_',size(subdic,2)) %extracts substring from subdic between "_" and the second dimension of subdic 
       %this provides  ID subject without "sub-"
       subject=append('sub-',proj,char(subbids1)) %combines the mentioned strings, thus creates sub-SUPRNJEBW for BIDS ID
    end
      
  outbidsdir=append(rawdir, subject,'/', bids_ses, '/func/') %define output raw directory 
  derivbidsdir=append(derivdir, 'spm/',subject,'/', bids_ses, '/')% define derivatives directory for analysed data in spm
% 
if ~exist(outbidsdir)
%read IMA format and check if data are not physio
    SERIES_DIR=dir(fullfile(IMAdir, '/*.IMA')) 
    str=SERIES_DIR(end) %get the last serie number so that it loops through serie number and not files (reduce calculation time)
    vpid1=char(append(proj,subbids1)) %get subject ID

    c = strsplit(str.name,'.') %split file name to get the serie number
    d=str2num(char(c(4)))  %get the serie number which is the number 4
 
    ANONIMAdir= [sourcedir 'ANONIMA/anon',proj,'_',char(subbids1), '/']; %defines the location of the anonymised source directory for the participant 
        if (~exist(ANONIMAdir))  %if the directory does not exist, create it:
            mkdir(ANONIMAdir)
        end
            ANONIMAsub=append(ANONIMAdir, bids_ses,'/') %defines the session for the anonymised source directory 
             mkdir (ANONIMAsub)

    %% organise data depending on if they are physio or dicoms images or log files
    for i=1:d %length(SERIES_DIR) %skips localizer
        charserie=num2str(i)                
        if i<10
        b1 = dir([IMAdir,  '/*' '.MR._.000' charserie '*IMA']) %define variable by serie number
        elseif i>=10
         b1 = dir([IMAdir,  '/*' '.MR._.00' charserie '*IMA'])
        end
                     
        if isempty(b1)
            disp(['serie not exist ' charserie ])      %check is serie exists
        else
            
            imafile = strcat(IMAdir, b1(1).name); %extract name of serie
            a=dicominfo(imafile);  %get all the ima info (e.g. type fo MR protocol)
            b=a.SeriesDescription;  %get serie type e.g. T1w
            disp(['serie is ' b])      

            if contains(b, 'PhysioLog') %if data are physio data (example for multiband EPI from CMRR)
               disp(['serie is physio ' b])
               disp('running physio extraction!')
               readCMRRPhysio(imafile);   %https://github.com/CMRR-C2P/MB/blob/master/readCMRRPhysio.m         
               outphysiodir=[ANONIMAsub '/tmp/' b] %define and create temporary directory for intermediate steps
               outphysiodir2=[ANONIMAsub 'tmp2/'] %define and ccreate temporary directory for intermediate steps:

               mkdir (outphysiodir)
               mkdir (outphysiodir2)
               extractCMRRPhysio(imafile,outphysiodir)        %https://github.com/CMRR-C2P/MB/blob/master/extractCMRRPhysio.m    
                 % fprintf('extracting physio \n', b);
               disp(['extracting physio ' b])
               phystypes={'EXT';'Info';'PULS';'RESP'}

                  
        %%%rename physio logs for bids in rawdata
        
                 for k=1:length(tasks) %looping through various tasks
                    if strfind(b, tasks{k}) %Info %PULS %RESP
                    task=tasks{k}
                    for pp=1: length (phystypes) %looping through the physio variables
                        physio=append(outphysiodir, '/*', phystypes(pp), '*.log')
                        inputA=dir(char(physio))
                        inputAsize=length(dir(char(physio)))
                         if (inputAsize==0) 
                            disp(['physio ' char(phystypes(pp)) ,  ' not exists'])
                         else
                             if length(dir(char(physio))) > 1
                                input=inputA(2)
                             else 
                                input=inputA
                             end
                             inphyspath=append(outphysiodir,'/',input.name) %input name
                             outphyspath=append(outphysiodir2,subject,'_', bids_ses, '_task-',task,'_recording-',  char(phystypes(pp)), '_physio.tsv.gz') %output name
                             copyfile(inphyspath, outphyspath)  %rename physio to BIDS physio
                         end
                     end
                    end
                 end
            
                 %%end physio
                                  
            elseif contains(b, 'localizer') %check if data not physio and not localizer then data to be anonymized
                     disp(['IMA localizer ignore is ' b])
                     
            else
              disp(['runing data anonymisation ' b])
               
             
           for p = 1:numel(b1)  %loops through the IMA in each protocol
             fullfilename=b1(p).name ; %get IMA name
             ANONIMAdata=sprintf([ANONIMAsub '/anon' fullfilename]); %IMA name with path
             indcm=dicomread(sprintf([IMAdir fullfilename])); %dicomread is matlab function
             if isempty(indcm)
                disp(['dcm is empty'])      
             else
             
             [~, f] = fileparts(fullfilename)
             newname=append(ANONIMAsub,'anon', vpid1,f(11:end), '.IMA')
                if isfile(newname)  %to avoid to run anonym twice  
                      disp(['anonymisation already done serie ' b]);
                   else
                      % the new name, e.g.
                   disp(['running anonymisation ' newname]);
                   outdcm=char(newname)
                   dicomsens(dicdir,IMAdir, fullfilename,vpid1,indcm,outdcm) %anonymisation, dicomsens is another script available in this location
                end
             end
                    
           end
           
            end
            
        end
    end
    %copy and rename physio to BIDS dir
    mkdir (outbidsdir)
    %mkdir(outbidsdir,'/func')
       outphysiodir2=[ANONIMAsub 'tmp2/']
       mkdir(derivbidsdir)
     cd(outphysiodir2)
     copyfile('*', outbidsdir) %copy the physio files to BIDS directory
     
     %copy and rename logs files to BIDS dir (can be from presentation or other experiment program files)
    LOGDIR=append(IMAdir, '/logfiles/')
                %copy logs to ANONIMA directory. some can have format .log or .xlsx
    origlog1 = dir([LOGDIR,'*.*x*']);
    origlog2 = dir([LOGDIR,'*.*log*']);
    jointlogdir = [origlog1;origlog2];
   
 if isempty(jointlogdir)
    disp(['logs cannot be found in IMA'])     
 else
    disp(['copying logs to ANONIMA'])     
    for lognum= 1:length(jointlogdir)
     logname=(append(jointlogdir(lognum).folder,'/',jointlogdir(lognum).name))
     copyfile(logname,ANONIMAsub) %copy the logfile name to the anonymised directory
    end
 end
     

%nback %example for nback task
inlogN=dir(fullfile(ANONIMAsub,'/*nback*perf.*')) %extract performance logs
inlogN2=dir(fullfile(ANONIMAsub,'/*nback.*')) %extract time logs

inNlog=append(inlogN.folder,'/',inlogN.name)
inN2log=append(inlogN2.folder,'/',inlogN2.name)
copyfile(inNlog,(append(outbidsdir,subject,'_',bids_ses,'_task-nbackperf_events.tsv'))) %copy logs to bids dir
copyfile(inN2log,(append(outbidsdir,subject,'_',bids_ses,'_task-nback_events.tsv'))) %copy logs to bids dir
   
%now dcm2nii
disp(['running dicm2bids  ' b])               
dicm2nii(ANONIMAsub,rawdir,'BIDSNII',ses,subject)  %https://github.com/xiangruili/dicm2nii/blob/master/dicm2nii.m 
%after anonymisation, convert to nifti and follows structure to BIDS
%               
else               
      disp(['dicm2bids   already done !' ])  %conversion already done
end


  end
  
end
       
