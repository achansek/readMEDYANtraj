classdef concsnapshot
    properties
        serial;
        LD;
        MD;
        AD;
        BD;
        CD;
        ED;
    end
    methods
        function obj=concchem(M)
            if(nargin>0)
                obj(M)=concchem;
                for idx=1:M
                    obj(idx).id=idx;
                end
            end
        end
    end
end
