classdef monomers
    properties
        %% array containing following data for each filament in a snapshot.
        deltacylplusend = NaN;
        deltacylminusend = NaN;
        polyplusend = NaN;
        polyminusend = NaN;
        depolyplusend = NaN;
        depolyminusend = NaN;
        filID = NaN;
        filType = NaN;
        filcyls = NaN;
        nummonomers = NaN;
        nucleation = NaN;%% filament is newly generated.
	cap = NaN;
    mcap = NaN;
    end
    methods
    end
end
