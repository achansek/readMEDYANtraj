classdef max_copies
    properties
        f_max=0;
        l_max=0;
        m_max=0;
        b_max = 0;
        p_max = 0;
        e_max = 0;
        c_max = 0;
    end
    methods
         function obj=max_copies(nf,nl,nm,np,ne,nb,nc) %number of fil, linker, motor types
             obj.f_max=nf;
             obj.l_max=nl;
             obj.m_max=nm;
             obj.p_max =np;
             obj.e_max =ne;
             obj.b_max =nb;
             obj.c_max = nc;
         end
    end
end