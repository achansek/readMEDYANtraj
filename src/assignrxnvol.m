function r = assignrxnvol(r,runID,b4,timestamp)
  volumetimeseries = -1.*ones(1,numel(r(runID).s));
volumestamp = b4.*2000.*2000;
tsid = 1;
totalid = numel(timestamp);
iter = 1;
while(tsid<totalid)
targett= timestamp(tsid);
targetvol = volumestamp(tsid);
while(iter<targett)
  volumetimeseries(iter) = targetvol;
iter = iter + 1;
    end
    tsid = tsid + 1;
end
for i = iter:numel(volumetimeseries)
	  volumetimeseries(i) = volumestamp(end);
end
r(runID).rxnvol = volumetimeseries;
end
