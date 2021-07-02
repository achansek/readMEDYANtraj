function r=readplusendtraj(filename,r, snaplastsnaptime)
s_no=1;
frame_num = 0;
for i =1:numel(filename)
    if(exist(filename{i}, 'file') == 2)
        f1=fopen(filename{i},'r');
        time_step=str2num(fgetl(f1));
        frame_curr = time_step(1);
        frame_prev = frame_curr - 1;
        line=fgetl(f1);
        capstatus = [];
        mcapstatus = [];
        recordplus = true;
        if(i>1)
            recordplus = false;
        end
        disp(filename{i});
        while(~feof(f1)&& time_step(2)<snaplastsnaptime(i))
            if(length(line)==0)
                if(recordplus)
                    frame_num = find(r.mtime_vector-time_step(2)>0,1);
                    if(isempty(frame_num))
                        recordplus = false;
                    end
                    %disp(num2str([time_step, r.mtime_vector(frame_num)]));
                    %                     while(time_step(2)-r.mtime_vector(frame_num)>1)
                    %                         frame_num = frame_num + 1;
                    %                     end
                    if(recordplus)
                        r.ms(frame_num).m.cap = capstatus;
                        r.ms(frame_num).m.mcap = mcapstatus;
                    end
                end
                capstatus = [];
                mcapstatus = [];
                time_step=str2num(fgetl(f1));
                frame_prev = frame_curr;
                frame_curr = time_step(1);
                %disp([num2str(frame_prev),' ',num2str(frame_curr)]);
                if(recordplus)
                    if(frame_curr - frame_prev ~= 1)
                        disp(filename{i});
                        disp('TRAJECTORY ISSUE! Plusend Trajectory frame numbers should increase monotonically');
                        disp(['Current frame number is ',num2str(frame_curr),' and previous frame number is ',num2str(frame_prev)]);
                        disp('Terminating read of this trajectory');
                        return;
                    end
                else
                    recordplus = true;
                end
            else
                if(strcmp(line(1),'F')==1)
                    aa = fgetl(f1);
                    bb = fgetl(f1);
                    plusend={};
                    if(ischar(bb))
                        plusend = strsplit(bb,':');
                        if(strcmp(plusend{1},'PLUSEND'))
                            capstatus = [capstatus, str2num(plusend{2})];
                        elseif(strcmp(plusend{1},'MINUSEND'))
                            mcapstatus = [mcapstatus, str2num(plusend{2})];
                        end
                    else
                        temp=[];
                        for i =1 :numel(plusend)
                            temp=[temp,' ',plusend{i}];
                        end
                        disp('TRAJECTORY ISSUE! Plusend Trajectory format mistmatch');
                        disp(['Expected pattern: PLUSEND [0-9]. Current Pattern: ',temp]);
                        disp('Terminating read of this trajectory');
                        return;
                    end
                    
                end
            end
            line=fgetl(f1);
            %disp(['Time ',num2str(time_step)])
            %disp(num2str(snaplastsnaptime))
        end
        if(feof(f1) && recordplus)
            disp(['end ',num2str(frame_num)]);
            %frame_num = frame_num+1;
            if(~isempty(frame_num))
                r.ms(frame_num).m.cap = capstatus;
                r.ms(frame_num).m.mcap = mcapstatus;
            end
        end
        disp(['snaps read ',num2str(frame_num)]);
        fclose(f1);
    end
end
end
