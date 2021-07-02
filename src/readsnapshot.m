function r=readsnapshot(filename,r,snaplastsnaptime)
r.time_vector=[];
%disp(['Reading trajectories from folders till time ',num2str(snaplastsnaptime));
for i =1:numel(filename)
    if(exist(filename{i}, 'file') == 2)
        disp(['Opening ',filename{i}]);
        f1=fopen(filename{i},'r');
        time_step=str2num(fgetl(f1));
        frame_curr = time_step(1);
        frame_prev = frame_curr - 1;
        r.time_vector=[ r.time_vector,time_step(2)];
        line=fgetl(f1);
        Coord_cell={};
        IDvec=[];
        Coord_myosin_cell=[];
        myosin_id_cell={};
        Coord_linker_cell=[];
        Coord_brancher_cell=[];
        linker_id_cell={};
        Coord_plusend_cell =[];
        myosin_id=[];
        linker_id=[];
        brancher_id=[];
        s_no=1;
        Coord=[];
        filament_numbeads=[];
        recordsnap = true;
        if(i>1) %Ignore first snapshot of the restarted file
            recordsnap = false;
        end
        while(~feof(f1) && time_step(2)<snaplastsnaptime(i))
            if(length(line)==0)
                time_step=str2num(fgetl(f1));
                frame_prev = frame_curr;
                frame_curr = time_step(1);
                if(frame_curr - frame_prev ~= 1)
                    disp('TRAJECTORY ISSUE! Snapshot Trajectory frame numbers should increase monotonically');
                    disp(['Current frame number is ',num2str(frame_curr),' and previous frame number is ',num2str(frame_prev)]);
                    disp('Terminating read of this trajectory');
                    return;
                end
                if(recordsnap)
                    r.time_vector=[r.time_vector,time_step(2)];
                    s_=snapshot;
                    s_.serial=s_no; % frame number;
                    s_no=s_no+1;
                    %       [coord_cell1,coord_cell2]=cluster_filaments(Coord_cell,Coord,filament_numbeads);
                    s_.f.coord_cell1=Coord_cell;
                    s_.f.coord_cell2={};
                    s_.f.ID = IDvec;
                    s_.m.coord_cell=Coord_myosin_cell;
                    s_.m.id=myosin_id;
                    s_.l.id=linker_id;
                    s_.l.coord_cell=Coord_linker_cell;
                    s_.b.id =brancher_id;
                    s_.b.coord_cell=Coord_brancher_cell;
                    s_.e.coord_cell =  Coord_plusend_cell;
                    r=appendsnapshot(r,s_);
                else
                    recordsnap = true;
                end
                clear s_;
                Coord=[];
                Coord_cell={};
                IDvec=[];
                Coord_myosin_cell=[];
                Coord_linker_cell=[];
                Coord_brancher_cell = [];
                Coord_plusend_cell = [];
                myosin_id=[];
                linker_id=[];
                brancher_id = [];
                filament_numbeads=[];
            elseif(strcmp(line(1),'F')==1)
                % fragment line
                % get the second entry. store it in filament ID vec.
                % check max fil ID.
                linefrag = strsplit(line);
                IDvec=[IDvec,str2num(linefrag{2})];
                r.maxFilId = max(r.maxFilId, IDvec(end));
                dummy=str2num(fgetl(f1));
                Coord_cell=[Coord_cell;{dummy}];
                Coord=[Coord;reshape(dummy,3,[])'];
                filament_numbeads=[filament_numbeads,size(Coord,1)];
                Coord_plusend_cell = [Coord_plusend_cell;Coord(end,:)];
                clear dummy;
            elseif(strcmp(line(1),'M')==1)
                temp = str2num(fgetl(f1));
                if(numel(temp)==6)
                    Coord_myosin_cell=[Coord_myosin_cell;temp];
                    dummy=strsplit(line,' ');
                    myosin_id=[myosin_id,str2double(dummy(2))];
                else
                    recordsnap = false;
                end
            elseif(strcmp(line(1),'L')==1)
                temp = str2num(fgetl(f1));
                if(numel(temp)==6)
                    Coord_linker_cell=[Coord_linker_cell;temp];
                else
                    recordsnap = false;
                end
            elseif(strcmp(line(1),'B')==1)
                temp = str2num(fgetl(f1));
                if(numel(temp)==3)
                    Coord_brancher_cell=[Coord_brancher_cell;temp];
                    dummy=strsplit(line,' ');
                    brancher_id=[brancher_id,str2double(dummy(2))];
                else
                    recordsnap = false;
                end
            end
            line=fgetl(f1);
        end
        if(feof(f1))
            if(recordsnap)
                s_=snapshot;
                s_.serial=s_no; % frame number;
                s_no=s_no+1;
                %       [coord_cell1,coord_cell2]=cluster_filaments(Coord_cell,Coord,filament_numbeads);
                s_.f.coord_cell1=Coord_cell;
                s_.f.coord_cell2={};
                s_.f.ID = IDvec;
                s_.m.coord_cell=Coord_myosin_cell;
                s_.m.id=myosin_id;
                s_.l.id=linker_id;
                s_.l.coord_cell=Coord_linker_cell;
                s_.b.id =brancher_id;
                s_.b.coord_cell=Coord_brancher_cell;
                s_.e.coord_cell =  Coord_plusend_cell;
                r=appendsnapshot(r,s_);
            end
            disp(['Total snapshots read ',num2str(size(r.s,2))]);
        else
            r.time_vector=[r.time_vector(1:end-1)];
        end
        fclose(f1);
    else
        disp(['not found ',filename{i}]);
    end
end
clear s_ Coord_cell Coord_myosin_cell myosin_id filament_numbeads;
end
