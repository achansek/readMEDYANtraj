function r=readgraph(path,matfilename,r,A,stringtag, snaplastsnaptimecell,framecountcell)
for i=1:size(r,2)
    snaplastsnaptime = snaplastsnaptimecell{i};
    graphmat = [];
    snapid = 1;
    for count = 0:10
        if(count==0)
            filedirname = [path,'/run',num2str(A(i)),stringtag];
        elseif(count==1)
            filedirname = [path,'/run',num2str(A(i)),'_R',stringtag];
        else
            filedirname = [path,'/run',num2str(A(i)),'_R',num2str(count),stringtag];
        end
        if(exist([filedirname,'/CMGraph.traj'],'file'))
            disp(['Opening ',filedirname,'/CMGraph.traj']);
            f2=fopen([filedirname,'/CMGraph.traj'],'r');
            line = fgetl(f2);%line with time stamp
            %disp(line);
            time_stamp = str2num(line);
            time_stamp = time_stamp(2);
            recordgraph = true;
            if(count>0)
            recordgraph = false;
            end
            framecounter = 0;
            disp(['starting time ',num2str(time_stamp),' ',num2str(snapid)]);
            while(~feof(f2)&& time_stamp < snaplastsnaptime(count+1))
                line = fgetl(f2);%line with data
                %disp(line);
                if(recordgraph)
                    %disp(['recorded ',num2str([i, snapid])])
                    temp = str2num(line);
                    if(mod(numel(temp),5)~=0)
                        r(i).s(snapid).g=[];
                        r(i).gtime_vector=[r(i).gtime_vector,-1];
                    else
                        r(i).s(snapid).g  = reshape(temp,5,[])';
                        r(i).gtime_vector=[r(i).gtime_vector,time_stamp];
                    end
                end
                %                 if(count>0)
                %                     recordgraph
                %                     [i snapid]
                %                     line(1:10)
                %                     graphmat = r(i).s(snapid).g;
                %                     graphmat(1,:)
                %                 end
                line = fgetl(f2);%empty line
                if(isempty(line) && ~feof(f2))
                    line = fgetl(f2);%line with time stamp
                    %disp(line);
                    time_stamp = str2num(line);
                    time_stamp = time_stamp(2);
                    if(recordgraph == false)
                        disp(['Starting to read graph at ',num2str(time_stamp),' ',num2str(snapid)]);
                        recordgraph = true;
                    else
                        snapid = snapid+1;
                        framecounter = framecounter + 1;
                    end
                end
            end
            framecountvec = framecountcell{i};
            framecountertarget = framecountvec(count+1);
            %disp(num2str([framecountertarget, framecounter]));
            while(framecountertarget>framecounter)
		disp(['Dummy entry at ',num2str(snapid)]);
                r(i).s(snapid).g=[];
                r(i).gtime_vector=[r(i).gtime_vector,-1];
                framecounter=framecounter+1;
                snapid = snapid+1;
            end
            %size(r(i).gtime_vector)
            %size(r(i).s,2)
        else
            disp([filedirname,'/CMGraph.traj']);
            disp('CMGraph file not found');
        end
    end
end
end
