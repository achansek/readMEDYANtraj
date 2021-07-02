function r=readconcentration(path,r,A,stringtag, ...
    snaplastsnaptimecell)
%path=['/export/lustre_1/achansek/bundle/1micron_30fil/',matfilename(3:4),'/',matfilename(5:6),'/'];
ld=[];md=[];ad=[];bd=[];cd=[];ed=[];
ena = [];
%disp(['size of runs ',num2str(size(r,1)),' ',num2str(size(r,2))]);
for i=1:size(r,2)
    ld=[];md=[];ad=[];bd=[];cd=[];ed=[];
    snaplastsnaptime = snaplastsnaptimecell{i};
    for count = 0:10
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
        if(exist([filedirname,'/concentration.traj'],'file'))
	    disp([filedirname,'/concentration.traj']);
            f2=fopen([filedirname,'/concentration.traj'],'r');
            line = fgetl(f2);%disp(line)
            b=strsplit(line);
            timestamp = str2num(b{2});
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
                    end
                end
                line = fgetl(f2);
                %disp(line)
                if(isempty(line))
                    if(readchem == false)
                        readchem = true;
                    end
                    line = fgetl(f2);
                    if(~feof(f2))
                    b=strsplit(line);
                    timestamp = str2num(b{2});
                    end
                    cs = concsnapshot;
                    cs.LD=ld;
                    cs.MD=md;
                    cs.AD=ad;
                    cs.BD=bd;
                    cs.CD=cd;
                    cs.ED = ed;
                    ld=[];md=[];ad=[];bd = []; cd = [];ed=[];
if(readchem)
                    r(i) = appendconcsnapshot(r(i),cs);               
end
                end
            end
            fclose(f2);
        else
            disp([filedirname,'/concentration.traj']);
            disp('Concentration file not found');
        end
    end
    
    disp(['run',num2str(i),'. Concentration read.']);
end
end
