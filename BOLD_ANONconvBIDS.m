function ANONconvBIDS(subdic)
% Adapted by Jamila Andoh, 20.06.2021, added physio and remove first volumes
% step2: convert to nifti and BIS stucture : for anonymisation 
%step3: extract physio
%step4: removal n=4 volumes
% created this to solve issues resulting from bugs with data anonymisation and physio data (lose their size and corrupt them)

wdir='/pandora/data/Template4Bids/SUPER/scripts/matlabscripts/'%defines wdir
cd(wdir) %changes directory to wdir
addpath(genpath(wdir)) %adds directory & generates path that includes wdir and directories below it?

[bids_root_dir, sourcedir, rawdir, derivdir, isolondir,qcdir, scriptsdir, dicdir,tasks, proj] = BIDSDIR_dir;
addpath('/ropt/spm12_r6906')

tic


SUB_DIR=dir(fullfile(isolondir, 'SU*')); %defines SUB_DIR as directory with source data of mentioned subject
      
for subnum = 1: length(SUB_DIR) %creates a loop: for all subjects in SUB_DIR (in this case 1), do the following:
    subdic=SUB_DIR(subnum).name %defines subdic as currently processed subject data? 
    %(Name returns the name that identifies the profiled code section)
%     subdic=char(SUB_DIR(subnum))


IMAdir= [isolondir, subdic '/Tasks/'] %defines IMAdir as directory "Tasks" (contains DWI)       

    if (~exist(IMAdir)) %if "Tasks" does not exist, output:
        disp('subject and session not acquired yet')     
    else %if "Tasks" exists do the following:
       bids_ses='ses-01' %creates string-variable
        ses={'01'}; %creates variable
       subbids1= extractBetween(subdic,'_',size(subdic,2)) %extracts substring from subdic between "_" and the second dimension of subdic 
       %(which does not exist, thus between "_" and the end of subdic; in this case NJEBW)
       subject=append('sub-',proj,char(subbids1)) %combines the mentioned strings, thus creates sub-SUPRNJEBW
    end
      
 % rawdir_check = strcat(rawdir, subject, '/',bids_ses);
  outbidsdir=append(rawdir, subject,'/', bids_ses, '/func/')
  derivbidsdir=append(derivdir, 'spm/',subject,'/', bids_ses, '/')% end
% 
if ~exist(outbidsdir)
%read dcm and check if not physio
    SERIES_DIR=dir(fullfile(IMAdir, '/*.IMA')) 
    str=SERIES_DIR(end) %get the last serie number so that it loops through serie number and not files (reduce calculation time)
    vpid1=char(append(proj,subbids1))

    c = strsplit(str.name,'.') %split file name to get the serie number
    d=str2num(char(c(4)))  %get the serie number
 
    %ANONIMAdir= [sourceanondir '/anon',proj,'_',char(subbids1), '/']%
    ANONIMAdir= [sourcedir 'ANONIMA/anon',proj,'_',char(subbids1), '/'];
%ANONIMAdir= [sourcedir 'ANONIMA/', sub '/']%
        if (~exist(ANONIMAdir)) 
            mkdir(ANONIMAdir)
        end
            ANONIMAsub=append(ANONIMAdir, bids_ses,'/')
             mkdir (ANONIMAsub)

    %% organise data depending on if they are physio or dicoms images or log files
    for i=1:d %length(SERIES_DIR) %skips localizer
  %  for i=15:22   %length(SERIES_DIR)
        charserie=num2str(i)                
        if i<10
        b1 = dir([IMAdir,  '/*' '.MR._.000' charserie '*IMA'])
        elseif i>=10
         b1 = dir([IMAdir,  '/*' '.MR._.00' charserie '*IMA'])
        end
                     
        if isempty(b1)
            disp(['serie not exist ' charserie ])      
%         elseif size(b1,1)< 2
%             disp(['serie physio corrupted.. ignoring ' charserie ])      

        else
            
            imafile = strcat(IMAdir, b1(1).name);
            a=dicominfo(imafile);  %get all the ima info (e.g. type fo MR protocol)
            b=a.SeriesDescription;  %serie type e.g. T1w
            disp(['serie is ' b])      

            if contains(b, 'PhysioLog')
               disp(['serie is physio ' b])
               disp('running physio extraction!')
               readCMRRPhysio(imafile);            
               outphysiodir=[ANONIMAsub '/tmp/' b]
               outphysiodir2=[ANONIMAsub 'tmp2/']

               mkdir (outphysiodir)
               mkdir (outphysiodir2)
               extractCMRRPhysio(imafile,outphysiodir)           
                 % fprintf('extracting physio \n', b);
               disp(['extracting physio ' b])
               phystypes={'EXT';'Info';'PULS';'RESP'}

                  
        %%%rename physio logs as bids in rawdata
        
                 for k=1:length(tasks)
                    if strfind(b, tasks{k}) %Info %PULS %RESP
                    task=tasks{k}
                    for pp=1: length (phystypes)
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
                             inphyspath=append(outphysiodir,'/',input.name)
                             outphyspath=append(outphysiodir2,subject,'_', bids_ses, '_task-',task,'_recording-',  char(phystypes(pp)), '_physio.tsv.gz')
                             copyfile(inphyspath, outphyspath) 
                         end
                     end
                    end
                 end
            
                 %%end physio
                                  
            elseif contains(b, 'localizer') %check if data not physio and not loc then anynymise them
                     disp(['IMA localizer ignore is ' b])
                     
            elseif contains(b, 'diff') %check if data not physio and not loc then anynymise them
                     disp(['not looking at it ' b])        
            else
              disp(['runing data anonymisation ' b])
               
               
%            else
%                disp(['serie is nt diff or anat ' b])
              
           for p = 1:numel(b1)  %loops through the IMA in each protocol
             fullfilename=b1(p).name ; %get IMA name
             ANONIMAdata=sprintf([ANONIMAsub '/anon' fullfilename]);
             indcm=dicomread(sprintf([IMAdir fullfilename]));
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
                   dicomsens(dicdir,IMAdir, fullfilename,vpid1,indcm,outdcm) %anonymisation
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

     %  outphyspath=append(outbidsdir,'/func/',subject,'_', bids_ses, '_task-',task,'_recording-',  char(phystypes(pp)), '_physio.tsv.gz')
     cd(outphysiodir2)
     copyfile('*', outbidsdir) 
     
     
     %copy and rename logs files to BIDS dir
    LOGDIR=append(IMAdir, '/logfiles/')
                %copy logs to ANONIMA directory
   origlog1 = dir([LOGDIR,'*.*x*']);
   origlog2 = dir([LOGDIR,'*.*log*']);
   jointlogdir = [origlog1;origlog2];
   
 if isempty(jointlogdir)
    disp(['logs cannot be found in IMA'])     
 else
    disp(['copying logs to ANONIMA'])     
    for lognum= 1:length(jointlogdir)
     logname=(append(jointlogdir(lognum).folder,'/',jointlogdir(lognum).name))
     copyfile(logname,ANONIMAsub)
    end
 end
     

% faces
inlogF=dir(fullfile(ANONIMAsub,'*faces*'))
% % outlogF=fullfile(outputFolder, outputBaseFileName)
inFlog=append(inlogF.folder,'/',inlogF.name)
copyfile(inFlog,(append(outbidsdir,subject,'_',bids_ses,'_task-faces_events.tsv')))

%nback
inlogN=dir(fullfile(ANONIMAsub,'/*nback*perf.*'))
inlogN2=dir(fullfile(ANONIMAsub,'/*nback.*'))

inNlog=append(inlogN.folder,'/',inlogN.name)
inN2log=append(inlogN2.folder,'/',inlogN2.name)
copyfile(inNlog,(append(outbidsdir,subject,'_',bids_ses,'_task-nbackperf_events.tsv')))
copyfile(inN2log,(append(outbidsdir,subject,'_',bids_ses,'_task-nback_events.tsv')))

%mid
inlogM=dir(fullfile(ANONIMAsub,'/*mid_readout.*'))
inlogM2=dir(fullfile(ANONIMAsub,'/*mid.*'))

inMlog=append(inlogM.folder,'/',inlogM.name)
inM2log=append(inlogM2.folder,'/',inlogM2.name)
copyfile(inMlog,(append(outbidsdir,subject,'_',bids_ses,'_task-midreadout_events.tsv')))
copyfile(inM2log,(append(outbidsdir,subject,'_',bids_ses,'_task-mid_events.tsv')))        

     
    %now dcm2nii
    disp(['running dicm2bids  ' b])               

    dicm2nii_bold(ANONIMAsub,rawdir,'BIDSNII',ses,subject)  %after anonymisation, structure to BIDS
%               
else
                       
    
       disp(['dicm2bids   already done !' ]) 
end

%% rename ĺogs to BIDS events


  end
  
  toc
end
    

%% NOTES: For short TRs (e.g., around 1 second or less), slice-timing correction doesn’t appear to lead to any significant gains in statistical power; 
   