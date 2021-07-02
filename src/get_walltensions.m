function r=get_walltensions(path,r)
for runs=1:size(r,2)
f1=fopen([path,'/run',num2str(runs),'/walltensions.traj'],'r');
fgetl(f1);
       line=fgetl(f1);
       WT={};
       s_no=1;
while(~feof(f1))
    if(length(line)==0)
       fgetl(f1);
r(runs).s(s_no).f.walltensions=WT;
       s_no=s_no+1;
       WT={};
       filament_numbeads=[];
    elseif(strcmp(line(1),'F')==1)
       dummy=str2num(fgetl(f1));
       WT=[WT;{dummy}];
       clear dummy;
      end
   line=fgetl(f1);
end
       if(feof(f1))
            r(runs).s(s_no).f.walltensions=WT;
       end
       fclose(f1);
       clear s_ WT filament_numbeads;
end
end
