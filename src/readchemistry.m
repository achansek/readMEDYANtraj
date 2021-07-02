function [r,framecountcell]=readchemistry(path,matfilename,r,A,stringtag, ...
    snaplastsnaptimecell)
%path=['/export/lustre_1/achansek/bundle/1micron_30fil/',matfilename(3:4),'/',matfilename(5:6),'/'];
ld=[];md=[];ad=[];fa=[];la=[];moa=[];
bd=[];cd=[];af=[];pa=[];ca=[];ma=[];
ba=[];cd=[];ed=[];
ena = [];
fp=[];fm=[];foa=[];fo=[];
%disp(['size of runs ',num2str(size(r,1)),' ',num2str(size(r,2))]);
framecountcell={};
for i=1:size(r,2)
    ld=[];md=[];ad=[];fa=[];la=[];moa=[];
    snaplastsnaptime = snaplastsnaptimecell{i};
    framecountvec=[];
    for count = 0:10
        framecounter = 0;
        if(count==0)
            filedirname = [path,'/run',num2str(A(i)),stringtag];
        elseif(count==1)
            filedirname = [path,'/run',num2str(A(i)),'_R',stringtag];
        else
            filedirname = [path,'/run',num2str(A(i)),'_R',num2str(count),stringtag];
        end
        readchem = true;
        if(count > 0)
            readchem = false;
        end
        if(exist([filedirname,'/chemistry.traj'],'file'))
            disp([filedirname,'/chemistry.traj']);
            f2=fopen([filedirname,'/chemistry.traj'],'r');
            line = fgetl(f2);%disp(line)
            b=strsplit(line);
            timestamp = str2num(b{2});
            disp(['Start time ',b{2},' ',num2str(numel(ld))]);
            while(~feof(f2)&& timestamp < snaplastsnaptime(count+1))
                b=strsplit(line);
                if(readchem)
                    if(strcmp(b{1},'A:DIFFUSING'))
                        ad=[ad,str2num(b{2})];
                    elseif(strcmp(b{1},'AD:DIFFUSING'))
                        ad=[ad,str2num(b{2})];
                    elseif(strcmp(b{1},'BD:DIFFUSING'))
                        bd=[bd,str2num(b{2})];
                    elseif(strcmp(b{1},'CD:DIFFUSING'))
                        cd=[cd,str2num(b{2})];
                    elseif(strcmp(b{1},'LD:DIFFUSING'))
                        ld=[ld,str2num(b{2})];
                    elseif(strcmp(b{1},'MD:DIFFUSING'))
                        md=[md,str2num(b{2})];
                    elseif(strcmp(b{1},'ED:DIFFUSING'))
                        ed=[ed,str2num(b{2})];
                    elseif(strcmp(b{1},'FO:DIFFUSING'))
                        fo=[fo,str2num(b{2})];
                    elseif(strcmp(b{1},'FOA:DIFFUSING'))
                        foa=[foa,str2num(b{2})];
                    elseif(strcmp(b{1},'FA:FILAMENT'))
                        af=[af,str2num(b{2})];
                    elseif(strcmp(b{1},'AF:FILAMENT'))
                        af=[af,str2num(b{2})];
                    elseif(strcmp(b{1},'PA:PLUSEND'))
                        pa=[pa,str2num(b{2})];
                    elseif(strcmp(b{1},'CA:PLUSEND'))
                        ca=[ca,str2num(b{2})];
                    elseif(strcmp(b{1},'ENA:PLUSEND'))
                        ena=[ena,str2num(b{2})];
                    elseif(strcmp(b{1},'FP:PLUSEND'))
                        fp=[fp,str2num(b{2})];
                    elseif(strcmp(b{1},'MA:MINUSEND'))
                        ma=[ma,str2num(b{2})];
                    elseif(strcmp(b{1},'FM:MINUSEND'))
                        fm=[fm,str2num(b{2})];
                    elseif(strcmp(b{1},'BA:BRANCHER'))
                        ba=[ba,str2num(b{2})];
                    elseif(strcmp(b{1},'LA:LINKER'))
                        la=[la,str2num(b{2})];
                    elseif(strcmp(b{1},'MOA:MOTOR'))
                        moa=[moa,str2num(b{2})];
                    end
                end
                line = fgetl(f2);
                %disp(line)
                if(isempty(line))
                    line = fgetl(f2);
                    if(~isempty(line) && ~feof(f2))
                        b=strsplit(line);
                        timestamp = str2num(b{2});
                        if(readchem)
                            framecounter = framecounter + 1;
                        end
                    end
                    if(readchem == false)
                        disp(['Starting to read at ',num2str(timestamp)]);
                        readchem = true;
                    end
                    
                end
            end
        else
            disp([filedirname,'/chemistry.traj']);
            disp('chemistry file not found');
        end
        %disp(num2str([numel(ld),framecounter]));
        framecountvec = [framecountvec, framecounter];
    end
    framecountcell = [framecountcell,framecountvec];
    r(i).chem.LD=ld;
    r(i).chem.MD=md;
    r(i).chem.AD=ad;
    r(i).chem.BD=bd;
    r(i).chem.CD=cd;
    
    r(i).chem.FA=af;
    r(i).chem.LA=la;
    r(i).chem.MOA=moa;
    r(i).chem.BA = ba;
    r(i).chem.PA = pa;
    r(i).chem.MA = ma;
    r(i).chem.CA = ca;
    r(i).chem.ENA = ena;
    r(i).chem.ED = ed;
    r(i).chem.FOA = foa;
    r(i).chem.FO = fo;
    r(i).chem.FM = fm;
    r(i).chem.FP = fp;
    ld=[];md=[];ad=[];bd = []; cd = [];af=[];
    fa=[];la=[];moa=[];ba = [];pa = []; ma = [];ca = [];
    ena=[];ed=[];fp=[];fm=[];foa=[];fo=[];
    disp(['run',num2str(i),'. Chemistry read.']);
end
end
