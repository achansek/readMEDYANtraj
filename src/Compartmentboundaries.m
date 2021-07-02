function r = Compartmentboundaries(path, name, runID,r,offset)
%% analyzes out file to get compartment length as a function of time
  [path,'/run',num2str(offset + runID),'.out']
  f1=fopen([path,'/run',num2str(offset+runID),'.out'],'r');
name=[name,'r',num2str(runID),'.tcl'];
t=[];b1=[];b2=[];
    check = 0;
while(~feof(f1))
    line=fgetl(f1);
x=strsplit(line,{' ','\'});

    if(strcmp(x{1},'Current'))
      t=[t,str2num(x{5})]; check =1;
    elseif(strcmp(x{1},'Maxbound') && check)
    a=strfind(line,'Minbound');
        b1=[b1;str2num(x{2})-250, str2num(x{4})+250];
        check = 0;
    end
end
fclose(f1);
t2=[t(1)];
b2=[b2;b1(1,:)];
dummy=b2(end,:)
for i=2:numel(t)   
    dummy=b2(end,:);    
    if(dummy(1)~=b1(i,1) || dummy(2) ~=b1(i,2))
        t2=[t2,t(i)];
        b2=[b2;b1(i,:)];
    end
end
b3=b2+repmat([250 -250],size(b2,1),1);
b3=b3./10;%%scale it to 1/10th the original size
b4=b3(:,1)-b3(:,2);
b4=[b4';(0.5*(b3(:,1)+b3(:,2)))'];
b4=[t2(2:end),0;b4]';
r = assignrxnvol(r, runID, (b3(:,1)-b3(:,2)).*10,t2);
disp(['Read tcl files. writing in file ',name]);
%%make these strings
ycenter = '100';
zcenter ='100';
yspan = '200';
zspan = '200';
%% WRITE FILE
f1=fopen([name],'w');
fprintf(f1, '%s\n', '##');
fprintf(f1, '%s\n', '## Example script showing a way to add user-drawn geometry that updates');
fprintf(f1, '%s\n', '##');
fprintf(f1, '%s\n', '## To use this script: ');
fprintf(f1, '%s\n', '##  1) load your trajectory');
fprintf(f1, '%s\n', '##  2) source frameupdate.vmd');
fprintf(f1, '%s\n', '##  3) enabletrace  ');
fprintf(f1, '%s\n', '##  4) do your thing :-) ');
fprintf(f1, '%s\n', '##  5) disabletrace');
fprintf(f1, '%s\n', 'proc enabletrace {} {');
fprintf(f1, '%s\n', '  global vmd_frame;');
fprintf(f1, '%s\n', '  color Display Background white ');
fprintf(f1, '%s\n', '  mol selection {resname NA}');
fprintf(f1, '%s\n', '  mol representation VDW 3.0');
fprintf(f1, '%s\n', '  mol addrep top');
fprintf(f1, '%s\n', '  mol modcolor 1 top ColorID 16');
fprintf(f1, '%s\n', '  trace variable vmd_frame([molinfo top]) w drawcounter');
fprintf(f1, '%s\n\n', '}');
fprintf(f1, '%s\n', 'proc disabletrace {} {');
fprintf(f1, '%s\n', '  global vmd_frame;');
fprintf(f1, '%s\n', '  trace vdelete vmd_frame([molinfo top]) w drawcounter');
fprintf(f1, '%s\n\n', '}');
fprintf(f1, '%s\n', 'proc drawcounter { name element op } {');
fprintf(f1, '%s\n',  '  global vmd_frame;');
fprintf(f1, '%s\n', '  draw delete all');
fprintf(f1, '%s\n', '  # puts "callback!"');
fprintf(f1, '%s\n', '  draw color black');
%% FRAME 1
fprintf(f1, '%s\n', '  set time [format "%8.0f s" [expr $vmd_frame([molinfo top])]]');
%% fprintf(f1, '%s\n', '  draw text {0 200 0}  "$time" size 5 thickness 5');
fprintf(f1, '%s\n', ['if { $vmd_frame([molinfo top]) < ',num2str(floor(b4(1,1))),' } {']);
fprintf(f1, '%s\n', '     mol modstyle 0 top trace 1.0 80;mol modcolor 0 top chain');
fprintf(f1, '%s\n', ['     pbc set {',num2str(b4(1,2)),' ', yspan,' ', zspan, '} -all -molid top']);
fprintf(f1, '%s\n', ['     pbc box -center origin -shiftcenter {',num2str(b4(1,3)),' ',ycenter,' ', zcenter,'}']);
%% FRAMES 2 to N-1
for i = 2:size(b4,1)-1
    fprintf(f1, '%s\n', ['} elseif { $vmd_frame([molinfo top]) < ',num2str(floor(b4(i,1))),' } {']);
    fprintf(f1, '%s\n', '     mol modstyle 0 top trace 1.0 80;mol modcolor 0 top chain');
    fprintf(f1, '%s\n', ['     pbc set {',num2str(b4(i,2)),' ', yspan,' ', zspan,'} -all -molid top']);
    fprintf(f1, '%s\n', ['     pbc box -center origin -shiftcenter {',num2str(b4(i,3)),' ',ycenter,' ', zcenter,'}']);
end
%% FRAME N
fprintf(f1, '%s\n', ' } else {');
fprintf(f1, '%s\n', '     mol modstyle 0 top trace 1.0 80;mol modcolor 0 top chain');
fprintf(f1, '%s\n', ['     pbc set {',num2str(b4(end,2)),' ',yspan,' ', zspan,'} -all -molid top']);
fprintf(f1, '%s\n', ['     pbc box -center origin -shiftcenter {',num2str(b4(end,3)),' ',ycenter,' ', zcenter,'}']);
fprintf(f1, '%s\n', ' }');
fprintf(f1, '%s\n', '}');
fclose(f1);
end


