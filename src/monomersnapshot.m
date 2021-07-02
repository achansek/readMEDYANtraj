classdef monomersnapshot
    properties
        serial;
        m = monomers;
    end
    methods
        function obj=monomersnapshot(M)
            if(nargin>0)
                obj(M)=monomersnapshot;
                for idx=1:M
                    obj(idx).id=idx;
                end
            end
        end
    end
end
