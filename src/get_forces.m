function r=get_forces(path,filename,r)
% path=['/export/lustre_1/achansek/bundle/1micron_30fil/',matfilename(3:4),'/',matfilename(5:6),'/'];
for runs=1:size(r,2)
	   f1=fopen([path,'/run',num2str(runs),'/forces.traj'],'r');
%      time_step=str2num(fgetl(f1));
fgetl(f1);
       line=fgetl(f1);
       Coord_cell={};
       s_no=1;
while(~feof(f1))
    if(length(line)==0)
%        time_step=str2num(fgetl(f1));
fgetl(f1);
       r(runs).s(s_no).f.forces=Coord_cell;
       s_no=s_no+1;
%        pause;
       Coord_cell={};
       filament_numbeads=[];
    elseif(strcmp(line(1),'F')==1)
        dummy=str2num(fgetl(f1));
        %save('test.mat','Coord_cell');
%         pause;
       Coord_cell=[Coord_cell;{dummy}];
       clear dummy;
      end
   line=fgetl(f1);
end
       if(feof(f1))
            r(runs).s(s_no).f.forces=Coord_cell;
       end
       fclose(f1);
       clear s_ Coord_cell filament_numbeads;
end
end
