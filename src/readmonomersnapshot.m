function r=readmonomersnapshot(filename,r,snaplastsnaptime)
r.mtime_vector = [];
s_no=1;
frame_num = 0;
for i =1:numel(filename)
    if(exist(filename{i}, 'file') == 2)
        disp(['Reading file ',filename{i}]);
        f1=fopen(filename{i},'r');
        time_step=str2num(fgetl(f1));
        frame_curr = time_step(1);
        frame_prev = frame_curr - 1;
        line=fgetl(f1);
        r.mtime_vector=[r.mtime_vector,time_step(2)];
        Dp =[];Dm=[]; pp=[]; pm=[]; dp =[]; dm =[];
        nummoneachfil =[]; fID =[];nnuc =[]; fcyl =[]; fType = [];
        %
        recordms = true;
        if(i>1) %Ignore the first snap of restarted trajectory.
            recordms = false;
        end
        while(~feof(f1)&& time_step(2)<snaplastsnaptime(i))
            if(length(line)==0)
                time_step=str2num(fgetl(f1));
                frame_prev = frame_curr;
                frame_curr = time_step(1);
                if(frame_curr - frame_prev ~= 1)
                    disp('TRAJECTORY ISSUE! MonomerSnapshot Trajectory frame numbers should increase monotonically');
                    disp(['Current frame number is ',num2str(frame_curr),' and previous frame number is ',num2str(frame_prev)]);
                    disp('Terminating read of this trajectory');
                    return;
                end
                if(recordms)
                    r.mtime_vector=[r.mtime_vector,time_step(2)];
                    ms_=monomersnapshot;
                    ms_.serial=s_no; % frame number;
                    s_no=s_no+1;
                    ms_.m.deltacylplusend=Dp;
                    ms_.m.deltacylminusend=Dm;
                    ms_.m.polyplusend=pp;
                    ms_.m.polyminusend=pm;
                    ms_.m.depolyplusend=dp;
                    ms_.m.depolyminusend=dm;
                    ms_.m.nucleation = nnuc;
                    ms_.m.filID = fID;
                    ms_.m.filType = fType;
                    ms_.m.filcyls = fcyl;
                    ms_.m.nummonomers = nummoneachfil;
                    r=appendmonomersnapshot(r,ms_);
                else
                    recordms = true;
                end
                clear ms_;
                Dp =[];Dm=[]; pp=[]; pm=[]; dp =[]; dm =[];
                nummoneachfil =[]; fID =[];nnuc =[]; fcyl =[]; fType = [];
                frame_num = frame_num + 1;
                
            else
                if(strcmp(line(1),'F')==1)
                    dummy = str2num(line(9:end));
                    fID = [fID, dummy(1)];
                    fType = [fType, dummy(2)];
                    fcyl = [fcyl, dummy(3)];
                    aa = fgetl(f1);
                    dummy=str2num(aa);
                    if(numel(dummy)>=8)
                        Dm = [Dm,dummy(1)];
                        Dp = [Dp,dummy(2)];
                        pm = [pm,dummy(3)];
                        pp = [pp,dummy(4)];
                        dm = [dm,dummy(5)];
                        dp = [dp,dummy(6)];
                        nnuc = [nnuc,dummy(7)];
                        nummoneachfil=[nummoneachfil,dummy(8)];
                    else
                        disp(['Skipping line ',aa]);
                    end
                    clear dummy;
                    
                end
            end
            line=fgetl(f1);
        end
        %disp('reached end of MONOMERSNAPSHOT file');
        if(feof(f1))
            if(recordms)
                ms_=monomersnapshot;
                ms_.serial=s_no; % frame number;
                s_no=s_no+1;
                ms_.m.deltacylplusend=Dp;
                ms_.m.deltacylminusend=Dm;
                ms_.m.polyplusend=pp;
                ms_.m.polyminusend=pm;
                ms_.m.depolyplusend=dp;
                ms_.m.depolyminusend=dm;
                ms_.m.nucleation = nnuc;
                ms_.m.filID = fID;
                ms_.m.filType = fType;
                ms_.m.filcyls = fcyl;
                ms_.m.nummonomers = nummoneachfil;
                r=appendmonomersnapshot(r,ms_);
            end
            clear ms_;
        else
            r.mtime_vector=[r.mtime_vector(1:end-1)];
        end
        
        fclose(f1);
    else
        disp(['Not found ',filename{i}]);
    end
end
clear ms_;
disp('reached end of MONOMERSNAPSHOT file');
end
