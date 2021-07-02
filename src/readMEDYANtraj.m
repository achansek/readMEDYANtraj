function readMEDYANtraj(N,outputfile,outputdir,x,varargin)
% Written by Aravind Chandrasekaran, Papoian Lab,
% University of Maryland, College Park.

%% Input variables
% Trajectories must be stored in folders with names run1, run2, run3, ... etc.
% N            -string- total number of runs
% outputfile   -string- name of the output trajectry files
%               (matlab file and pdb )
% outputdir    -string- directory in which the output files are stored
% x            -string- first run id eg 1, 2, 3, ... etc. This allows user
%               to read just part of the trajectories generated.
% varargin options
% 'stringtag', 'stringtagstring'  - stringtag - additional string to add to the filenames
%               run1_stringtag, run2_stringtag etc.
% 'runarray', 'true' - string- runarray - handle determines if you want to store the parsed trajectories as a
%               single file or multiple files. default multiple files
% 'taskstringtag', 'SMP-PDB' - string- taskstringtag - tasks to perform
%               SMP snapshot monomers and plus end files will be parsed
%               GCC graph chemistry and concentration data will be
%               parsed
%               PDB - pdb file will be generated. To generate PDB file,
%               SMP option should also be used.
% 'filereadpath' ,'path_to_traj' -string- path to the trajectry files.

stringtag = '';
runarray = false;
taskstringtag='SMP-GCC-PDB';
filereadpath='';
N=str2num(N);
x=str2num(x);
timevectorcell={};
skipappendread = false;
if(~isempty(varargin))
    [~, b] = ismember('stringtag',varargin);
    if(b) stringtag = varargin{b+1}; disp(['Using stringtag ',stringtag]);end
    [~, b] = ismember('runarray',varargin);
    if(b) runarray = str2num(varargin{b+1}); end
    [~, b] = ismember('taskstringtag',varargin);
    if(b) taskstringtag = varargin{b+1}; end
    [~, b] = ismember('filereadpath',varargin);
    if(b) filereadpath = varargin{b+1}; end
    [~, b] = ismember('skipappendread',varargin);
    if(b) skipappendread = str2num(varargin{b+1});end
end
if(runarray)
    runvec = runs(N);
end
matfilename = [outputdir,'/',outputfile];
matfilenameclean = strrep(outputfile,':','-');
matfilenameclean = strrep(matfilenameclean,'.','-');
%% READ TRAJECTORIES
if(x>0)
    A= x:x+(N-1);
else
    A =1:N;
end
%%  Step1 - determine how many restarts to go through
snaplastsnaptimecell={};
for i=1:N
    disp([filereadpath,'/run',num2str(A(i)),stringtag]);
    if(exist([filereadpath,'/run',num2str(A(i)),stringtag],'dir'))
        testpath = [filereadpath,'/run',num2str(A(i)),stringtag];
        if(~skipappendread)
            snaplastsnaptime = getappendtimes(testpath);
        else
            snaplastsnaptime = [5000,5000,5000,5000,5000,5000,5000,5000,5000,5000];
        end
        snaplastsnaptimecell=[snaplastsnaptimecell;snaplastsnaptime];
    end
end
%% Step2 - Read snapshot, monomer and plusend trajectories
if(contains(taskstringtag,'SMP'))
    for i=1:N
        snapfilepath = cell(1,11);
        monomerfilepath = cell(1,11);
        plusendfilepath = cell(1,11);
        disp(['Does path ',filereadpath,'/run',num2str(A(i)),stringtag ...
            ' Exist? ', num2str(exist([filereadpath,'/run',num2str(A(i)),stringtag],'dir'))]);
        disp(['Starting read of run ',num2str(A(i)),stringtag]);
        snaplastsnaptime = snaplastsnaptimecell{i};
        r = runs(1);
        r(1).number = A(i);
        rms = runs(1);
        if(exist([filereadpath,'/run',num2str(A(i)),stringtag],'dir'))
            for trajpart = 0:10
                if(trajpart==0)
                    additionaltag = '';
                elseif(trajpart==1)
                    additionaltag = '_R';
                else
                    additionaltag = ['_R',num2str(trajpart)];
                end
                snapfilepath{trajpart+1} = [filereadpath,'/run',num2str(A(i)),additionaltag,stringtag,'/snapshot.traj'];
                monomerfilepath{trajpart+1} = [filereadpath,'/run',num2str(A(i)),additionaltag,stringtag,'/monomers.traj'];
                plusendfilepath{trajpart+1} = [filereadpath,'/run',num2str(A(i)),additionaltag,stringtag,'/plusend.traj'];
            end
            r=readsnapshot(snapfilepath,r,snaplastsnaptime);
            rms=readmonomersnapshot(monomerfilepath,rms,snaplastsnaptime);
            rms=readplusendtraj(plusendfilepath,rms,snaplastsnaptime);
        else
            r=readsnapshotQin([filereadpath,'/snapshot.traj'],r);
            rms=readmonomersnapshot([filereadpath,'/monomers.traj'],rms);
            rms=readplusendtraj([filereadpath,'/plusend.traj'],rms);
        end
        disp('SNAPSHOT READ');
        if(i==1)
            rvis = r;
            rvis(1).ms = rms(1).ms;
        end
        if(runarray)
            runvec(i) = r;
            runvec(i).ms = rms(1).ms;
        else
            save([matfilename,'_S',num2str(A(i))],'r','snaplastsnaptime','-v7.3');
            %rms(1).time_vector = r(1).time_vector;
            r = rms;
            save([matfilename,'_MS',num2str(A(i))],'r','snaplastsnaptime','-v7.3');
            disp('mat file saved');
        end
        timevectorcell=[timevectorcell, r(1).time_vector];
        %%save a run for the visualization code
        clear rms r;
    end
end
%% Step 3 read graph, chemistry and concentration trajectories
if(contains(taskstringtag,'GCC'))
    if(runarray)
        r = runvec;
        clear runvec;
    else
        clear r;
        r = runs(N);
        for i = 1:N
            r(i).number = i;
        end
    end
    [r, framecountcell]=readchemistry(filereadpath,outputfile,r,A,...
        stringtag,snaplastsnaptimecell);
    r=readconcentration(filereadpath,r,A,stringtag, ...
        snaplastsnaptimecell);
    r=readgraph(filereadpath,matfilename,r,A,stringtag,snaplastsnaptimecell,framecountcell);
    if(runarray)
        save([matfilename,stringtag],'r','snaplastsnaptime','-v7.3');
    else
        save([matfilename,'_CG',stringtag],'r','snaplastsnaptime','-v7.3');
    end
    disp('Chem Graph Conc mat file saved');
end
%% Step 4 write PDB files
if(contains(taskstringtag,'PDB'))
    VMDstylesnap(rvis, [outputdir,'/'] ,[matfilenameclean,stringtag], 1);
    disp('pdb file written');
end
end
