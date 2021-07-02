function VMDstylesnap(r,path,outputfile,runid,varargin)
snapskip = 1;
finalsnap=0;
startsnap=1;
if(~isempty(varargin))
    [~, b] = ismember('snapskip',varargin);
    if(b) snapskip = str2num(varargin{b+1}); disp(['Using snapskip ',varargin{b+1}]);end
    [~, b] = ismember('startsnap',varargin);
    if(b) startsnap = str2num(varargin{b+1}); disp(['Using startsnap ',varargin{b+1}]);end
    [~, b] = ismember('finalsnap',varargin);
    if(b) finalsnap = str2num(varargin{b+1}); disp(['Using finalsnap ',varargin{b+1}]);end
end
%% Eventhough the MATLAB code that gives the class r cannot take more than one type of filament,...
%% linker or motor, we create a class to hold more than one type of those for future expansion.
disp(['PDB trajectory Ouputfile ', path,'/',outputfile,'.pdb']);
f1=fopen([path,'/',outputfile,'.pdb'],'w');
count_model=1;
speciesvec=max_copies(1,1,1,1,1,1,1);
maxfilID = r(1).maxFilId+1;
fprintf(f1,'REMARK   MAXFILID %i\n',maxfilID);
speciesvec.f_max = zeros(1,maxfilID);
for runs=runid
    disp(['Nsnaps=',num2str(size(r(runs).s,2)),' NMsnaps=',num2str(size(r(runs).ms,2)]));
    Totsnap = min(size(r(runs).s,2),size(r(runs).ms,2));
    if(finalsnap)
        Totsnap = min(finalsnap,Totsnap);
        if(startsnap<Totasnap)
            startsnap = Totsnap-20;
        end
    end
    %% STEP 1. Get the maximum number of elements per frame.
    for snap=startsnap:snapskip:Totsnap
        Filcoordcell=r(runs).s(snap).f.coord_cell1;
        FilIDvec = r(runs).s(snap).f.ID;
        for it=1:size(Filcoordcell,1)%Nfil
            Nbeadsinfil = numel(Filcoordcell{it})/3;
            FilID = FilIDvec(it);
            %Update maximum number of beads corr. to the fil ID.
            speciesvec.f_max(FilID+1) = max(speciesvec.f_max(FilID+1), Nbeadsinfil);
        end
        % Linker
        dummy2=size(r(runs).s(snap).l.coord_cell,1);
        speciesvec.l_max(1)=max(dummy2,speciesvec.l_max(1));
        %         Filcoordcell=r(runs).s(snap).m.coord_cell;
        
        % Motor
        dummy2=size(r(runs).s(snap).m.coord_cell,1);
        speciesvec.m_max(1)=max(dummy2,speciesvec.m_max(1));
        
        % Brancher
        dummy2=size(r(runs).s(snap).b.coord_cell,1);
        speciesvec.b_max(1)=max(dummy2,speciesvec.b_max(1));
        
        % PLUSEND Type 0 Refer chemistry inputfile for data. (NINDS - REG)
        dummy2=size(find(r(runs).ms(snap).m.cap  ==0),2);
        speciesvec.p_max(1) = max(dummy2,speciesvec.p_max(1));
        
        % PLUSEND Type 1 Refer chemistry inputfile for data. (NINDS - CAP)
        dummy2=size(find(r(runs).ms(snap).m.cap  ==1),2);
        speciesvec.e_max(1) = max(dummy2,speciesvec.e_max(1));
        
        % PLUSEND Type 2 Refer chemistry inputfile for data. (NINDS - ENA)
        dummy2=size(find(r(runs).ms(snap).m.cap  ==2),2);
        speciesvec.c_max(1) = max(dummy2,speciesvec.c_max(1));
    end
    clear dummy dummy2 it;
    %     speciesvec.l_max(1) = 2*speciesvec.l_max(1);
    %     speciesvec.m_max(1)=2*speciesvec.m_max(1);
    %speciesvec
    %pause;
    %% STEP 2.
    
    for snap=startsnap:snapskip:Totsnap
        %% FILAMENT
        fprintf(f1,'MODEL     %4i\n',count_model);%can only print 10k frames.
        count_f=0;
        fils=r(runs).s(snap).f.coord_cell1;
        filIDvec = r(runs).s(snap).f.ID;
        chain=['ABCDEFGHIJKbcdefghijkQRSTUVWXYZqrstuvwxyz'];
        chnum=1;
        for fID = 1:maxfilID
            % If the number of beads in this filament exceeds maximum number
            % of residues allowed in a chain, switch to the next chain.
            if(count_f+speciesvec.f_max(fID)>=9998)
                fprintf(f1,'TER   %5i      ARG %s%4i\n',count_f,chain(chnum),count_f);
                count_f=0;
                chnum=chnum+1;
            end
            %if the fID exists in this frame
            fIDvecpos = find(ismember(filIDvec,fID-1));
            if(~isempty(fIDvecpos))
                A=reshape(fils{fIDvecpos},3,[])'./10;% A model that is 10 times smaller.
                b=fID*100/maxfilID;%B-factor
                %Enter coordinates of availalbe beads.
                for i=1:size(A,1)
                    fprintf(f1,'ATOM  %5i  CA  ARG %s%4i    %8.3f%8.3f%8.3f  1.00%6.2f\n',count_f,chain(chnum),count_f,A(i,1),A(i,2),A(i,3),b);
                    count_f=count_f+1;
                end
                %Enter dummy coordinates for rest of the filament.
                for i=size(A,1)+1:speciesvec.f_max(fID)
                    fprintf(f1,'ATOM  %5i  CA  ARG %s%4i    %8.3f%8.3f%8.3f  1.00%6.2f\n',count_f,chain(chnum),count_f,A(end,1),A(end,2),A(end,3),b);
                    count_f=count_f+1;
                end
                count_f=count_f+1;
            else
                % If the number of beads in this filament exceeds maximum number
                % of residues allowed in a chain, switch to the next chain.
                if(count_f+speciesvec.f_max(fID) >=9998)
                    fprintf(f1,'TER   %5i      ARG %s%4i\n',count_f,chain(chnum),count_f);                                                                                                                                       count_f=0;
                    chnum=chnum+1;
                end
                b=fID*100/maxfilID;%B-factor
                for i=1:speciesvec.f_max(fID)
                    fprintf(f1,'ATOM  %5i  CA  ARG %s%4i    %8.3f%8.3f%8.3f  1.00%6.2f\n',count_f,chain(chnum),count_f,0.0,0.0,0.0,b);
                    count_f=count_f+1;
                end
                count_f=count_f+1;
            end
        end
        %% END FILAMENT
        fprintf(f1,'TER   %5i      ARG %s%4i\n',count_f,chain(chnum),count_f);
        %% PLUSEND
        plusendchain = '0123456789';
        chnum = 1;
        count_ends = 0;
        count_res = 0;
        count_c = 0;
        count_e = 0;
        count_p = 0;
        b = 0.0;
        beta = 0.0;
        %% Get plus end coords
        Plusendcoord = [];
        for f=1:size(fils,1)
            % A model that is 10 times smaller.
            Plusendcoord = [Plusendcoord;fils{f}(end-2:end)./10];
        end
        plusendstatusvec = r(runs).ms(snap).m.cap;
        freeplusvec = find(plusendstatusvec == 0);
        %disp(['snap ',num2str([snap, size(Plusendcoord),size(plusendstatusvec),size(freeplusvec)])]);
        %%freeplusvec = find(plusendstatusvec == 0);
        Evec = find(plusendstatusvec == 1);
        Cvec = find(plusendstatusvec == 2);
        %% Free plus ends
        freeplusvec = freeplusvec(find(freeplusvec<=size(Plusendcoord,1)));
        for count = 1:speciesvec.p_max(1)
            if(count_res+size(fils,1)>=9998)
                fprintf(f1,'TER   %5i      VAL %s%4i\n',count_res,plusendchain(chnum),count_res);
                chnum = chnum + 1;
                count_res = 0;
            end
            if(count<=numel(freeplusvec))
                %size(freeplusvec)
                %count
                %freeplusvec(count)
                %size(Plusendcoord)
                coord = Plusendcoord(freeplusvec(count),:);
                fprintf(f1,'ATOM  %5i  CA  TYR %s%4i    %8.3f%8.3f%8.3f%6.2f%6.2f\n',count_res,plusendchain(chnum),count_res,coord(1),coord(2),coord(3),beta,beta);
                count_res = count_res + 1;
            else
                fprintf(f1,'ATOM  %5i  CA  TYR %s%4i    %8.3f%8.3f%8.3f%6.2f%6.2f\n',count_res,plusendchain(chnum),count_res,0.0,0.0,0.0,b,b);
                count_res=count_res+1;
            end
        end
        %% E plus ends
        Evec = Evec(find(Evec<=size(Plusendcoord,1)));
        for count = 1:speciesvec.e_max(1)
            if(count_res+size(fils,1)>=9998)
                fprintf(f1,'TER   %5i      VAL %s%4i\n',count_res,plusendchain(chnum),count_res);
                chnum = chnum + 1;
                count_res = 0;
            end
            if(count<=numel(Evec))
                coord = Plusendcoord(Evec(count),:);
                fprintf(f1,'ATOM  %5i  CA  VAL %s%4i    %8.3f%8.3f%8.3f%6.2f%6.2f\n',count_res,plusendchain(chnum),count_res,coord(1),coord(2),coord(3),beta,beta);
                count_res = count_res + 1;
            else
                fprintf(f1,'ATOM  %5i  CA  VAL %s%4i    %8.3f%8.3f%8.3f%6.2f%6.2f\n',count_res,plusendchain(chnum),count_res,0.0,0.0,0.0,b,b);
                count_res=count_res+1;
            end
        end
        %% C plus ends
        Cvec = Cvec(find(Cvec<=size(Plusendcoord,1)));
        for count = 1:speciesvec.c_max(1)
            if(count_res+size(fils,1)>=9998)
                fprintf(f1,'TER   %5i      VAL %s%4i\n',count_res,plusendchain(chnum),count_res);
                chnum = chnum + 1;
                count_res = 0;
            end
            if(count<=numel(Cvec))
                coord = Plusendcoord(Cvec(count),:);
                fprintf(f1,'ATOM  %5i  CA  LYS %s%4i    %8.3f%8.3f%8.3f%6.2f%6.2f\n',count_res,plusendchain(chnum),count_res,coord(1),coord(2),coord(3),beta,beta);
                count_res = count_res + 1;
            else
                fprintf(f1,'ATOM  %5i  CA  LYS %s%4i    %8.3f%8.3f%8.3f%6.2f%6.2f\n',count_res,plusendchain(chnum),count_res,0.0,0.0,0.0,b,b);
                count_res=count_res+1;
            end
        end
        %% END FILAMENT
        fprintf(f1,'TER   %5i      VAL %s%4i\n',count_res,plusendchain(chnum),count_res);
        %% LINKER
        count_f=0;
        link=r(runs).s(snap).l.coord_cell./10;
        chain=['l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'];
        chnum=1;
        for i=1:speciesvec.l_max(1)
            if(count_f>=9998)
                fprintf(f1,'TER   %5i      ARG %s%4i\n',count_f,chain(chnum),count_f);
                count_f=0;
                chnum=chnum+1;
            end
            if(i<=size(link,1))
                fprintf(f1,'ATOM  %5i  CA  ARG %s%4i    %8.3f%8.3f%8.3f  1.00%6.2f\n',count_f,chain(chnum),count_f,link(i,1),link(i,2),link(i,3),b);
                count_f=count_f+1;
                fprintf(f1,'ATOM  %5i  CA  ARG %s%4i    %8.3f%8.3f%8.3f  1.00%6.2f\n',count_f,chain(chnum),count_f,link(i,4),link(i,5),link(i,6),b);
                count_f=count_f+2;
            else
                fprintf(f1,'ATOM  %5i  CA  ARG %s%4i    %8.3f%8.3f%8.3f  1.00%6.2f\n',count_f,chain(chnum),count_f,0.0,0.0,0.0,b);
                count_f=count_f+1;
                fprintf(f1,'ATOM  %5i  CA  ARG %s%4i    %8.3f%8.3f%8.3f  1.00%6.2f\n',count_f,chain(chnum),count_f,0.0,0.0,0.0,b);
                count_f=count_f+2;
            end
        end
        if(count_f<9998)
            fprintf(f1,'TER   %5i      ARG %s%4i\n',count_f,chain(chnum),count_f);
        end
        clear link;
        %% MOTOR
        count_f=0;
        motor=r(runs).s(snap).m.coord_cell./10;
        chain=['L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];
        chnum=1;
        for i=1:speciesvec.m_max(1)
            if(count_f>=9998)
                fprintf(f1,'TER   %5i      ARG %s%4i\n',count_f,count_f);
                count_f=0;
                chnum=chnum+1;
            end
            if(i<=size(motor,1))
                fprintf(f1,'ATOM  %5i  CA  ARG %s%4i    %8.3f%8.3f%8.3f  1.00%6.2f\n',count_f,chain(chnum),count_f,motor(i,1),motor(i,2),motor(i,3),b);
                count_f=count_f+1;
                fprintf(f1,'ATOM  %5i  CA  ARG %s%4i    %8.3f%8.3f%8.3f  1.00%6.2f\n',count_f,chain(chnum),count_f,motor(i,4),motor(i,5),motor(i,6),b);
                count_f=count_f+2;
            else
                fprintf(f1,'ATOM  %5i  CA  ARG %s%4i    %8.3f%8.3f%8.3f  1.00%6.2f\n',count_f,chain(chnum),count_f,0.0,0.0,0.0,b);
                count_f=count_f+1;
                fprintf(f1,'ATOM  %5i  CA  ARG %s%4i    %8.3f%8.3f%8.3f  1.00%6.2f\n',count_f,chain(chnum),count_f,0.0,0.0,0.0,b);
                count_f=count_f+2;
            end
        end
        if(count_f<9998)
            fprintf(f1,'TER   %5i      ARG %s%4i\n',count_f,chain(chnum),count_f);
        end
        %% BRANCHER
        count_f=0;
        branch=r(runs).s(snap).b.coord_cell./10;
        chain='ahijk';
        chnum=1;
        for i=1:speciesvec.b_max(1)
            if(count_f>=9998)
                fprintf(f1,'TER   %5i      ARG %s%4i\n',count_f,chain(chnum),count_f);
                count_f=0;
                chnum=chnum+1;
            end
            if(i<=size(branch,1))
                fprintf(f1,'ATOM  %5i  CA  ARG %s%4i    %8.3f%8.3f%8.3f  1.00%6.2f\n',count_f,chain(chnum),count_f,branch(i,1),branch(i,2),branch(i,3),b);
                count_f=count_f+1;
            else
                chnum;
                chain;
                count_f;
                fprintf(f1,'ATOM  %5i  CA  ARG %s%4i    %8.3f%8.3f%8.3f  1.00%6.2f\n',count_f,chain(chnum),count_f,0.0,0.0,0.0,b);
                count_f=count_f+1;
            end
        end
        if(count_f<9998)
            fprintf(f1,'TER   %5i      ARG %s%4i\n',count_f,chain(chnum),count_f);
        end
        clear branch;
        fprintf(f1,'ENDMDL\n');
        count_model=count_model+1;
    end
end
fclose(f1);
end