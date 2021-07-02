function snaplastsnaptime = getappendtimes(datadumppath)
  snaplastsnaptime = [];
for i = 0:9
	  if(i==0)
	    datadumpfile = [datadumppath,'/datadump.traj'];
elseif(i==1)
datadumpfile = [datadumppath,'_R/datadump.traj'];
 else
   datadumpfile = [datadumppath,'_R',num2str(i),'/datadump.traj'];
    end
    if exist(datadumpfile, 'file') == 2
      f1 = fopen(datadumpfile,'r');
line = fgetl(f1);
fclose(f1);
line = str2num(line);
if(numel(snaplastsnaptime)>=1)
  if(line(2)>snaplastsnaptime(end))
    snaplastsnaptime=[snaplastsnaptime,line(2)];
  else
    disp(datadumppath);
disp('Trajectory bug! Returning. Restarted trajectory time point does not match previous trajectory time');
disp(['Restart #',num2str(i),' trajectory ends at time ',num2str(line(2)),' while Restart #',num2str(i-1),' ends at time ',num2str(snaplastsnaptime(end))]);
snaplastsnaptime = [snaplastsnaptime,repmat(5000,1,10-numel(snaplastsnaptime),1)];
return;
            end
 else
   snaplastsnaptime=[snaplastsnaptime,line(2)];
        end
 else
   snaplastsnaptime=[snaplastsnaptime,5000];
    end
end
    %% if there are no restart files, then neglect the datadump timestamp.
      if(snaplastsnaptime(2) == 5000)
	snaplastsnaptime(1) = 5000;
end
end
