path=['/lustre/achansek/bundle/2micron_30fil_BENDINGSCALED/turnoverrate/turnoverrate/2mUNI_BRcorrected/',outputfile(6:7),'/',outputfile(8:9),'/',outputfile(11:14),'/60x3x3'];
load(['./turnoverrate_filesBR/',outputfile,'.mat']);
for i = 1:size(r,2)
	  r(i)=readmonomersnapshot([path,'/run',num2str(A(i)),'/monomers.traj'],r(i));
end
save([pwd,'/turnoverrate_filesBR/',outputfile,'.mat']);
