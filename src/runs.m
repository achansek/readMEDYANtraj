classdef runs
    properties
        number
        s=snapshot
        time_vector=[];
        mtime_vector=[];
        gtime_vector=[];
        chem;
        b=birthtime
        ms = monomersnapshot;
        cs = concsnapshot;
        rxnvol;
        maxFilId = 0;
    end
    methods
        function obj=runs(N,varargin)
            if(nargin==2)
                obj(N)=run;
                M=varargin{2};
                for idx=1:N
                    obj(idx).s(M)=snapshot;
                end
            elseif(nargin==1)
                for idx=1:N
                    obj(idx).number=idx;
                end
            end
        end
        function obj=appendsnapshot(obj,s1)
            if(nargin>0)
                if(~isempty(obj.s(numel(obj.s)).serial))
                    obj.s(numel(obj.s)+1)=s1;
                else
                    obj.s(numel(obj.s))=s1;
                end
            end
        end
        
        function obj=appendmonomersnapshot(obj,ms1)
            if(nargin>0)
                if(~isempty(obj.ms(numel(obj.ms)).serial))
                    obj.ms(numel(obj.ms)+1)=ms1;
                else
                    obj.ms(numel(obj.ms))=ms1;
                end
            end
        end
        
        function obj=appendbirthtime(obj,b1)
            if(nargin>0)
                if(~isempty(obj.b(numel(obj.b)).serial))
                    obj.b(numel(obj.b)+1)=b1;
                else
                    obj.b(numel(obj.b))=b1;
                end
            end
        end
        function s1=getsnapshot(obj,serial)
            s1=obj.s(find([obj.s(:).serial]==serial));
        end
        function obj=appendconcsnapshot(obj,cs1)
            if(nargin>0)
                if(~isempty(obj.cs(numel(obj.cs)).serial))
                    cs1.serial = numel(obj.cs)+1;
                    obj.cs(numel(obj.cs)+1)=cs1;
                else
                    cs1.serial = 1;
                    obj.cs(numel(obj.cs))=cs1;
                end
            end
        end
    end
end
