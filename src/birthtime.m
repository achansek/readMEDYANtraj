classdef birthtime
    properties
        serial
        f;
      l;
      m;
    end
    methods
        function obj=birthtime(M)
            if(nargin>0)
                obj(M)=birthtime;
                for idx=1:M
                    obj(idx).id=idx;
                end
            end
        end
    end
end