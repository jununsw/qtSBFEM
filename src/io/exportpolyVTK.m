function exportpolyVTK( xnod,elems, filename )
%Export polygon to VTK

%% ***** ***** ***** Writing the vtk file ***** ***** *****
fid = fopen(filename,'w');

%% Writing the header from the vtk file
fprintf(fid,'# vtk DataFile Version 3.1 \n');
fprintf(fid,'This file was created by matlab source code \n');
fprintf(fid,'ASCII \n');
fprintf(fid,'DATASET POLYDATA \n');
%fprintf(fid,'MESH dimension %3.0f   Elemtype %s   Nnode %2.0f \n \n', ndim, eletyp, nno_por_elem);

%% Writing the coordinates of each node
if(size(xnod,2) == 2)
    xnod = [xnod,zeros(size(xnod,1),1)];
end
totalNno = size(xnod,1);  % Total of nodes
fprintf(fid,'POINTS %3.0f  FLOAT \n', totalNno);
for i=1:totalNno
    fprintf(fid, [repmat('%12.5f ',1,3) '\n'], xnod(i,:));
end

%% Initial parameters
nef = size(elems,1);

%% Writing the cells or nodes
totalCells = sum(cellfun(@(a)length(a),elems)) + nef;
fprintf(fid, '\n');
fprintf(fid,'POLYGONS %3.0f %3.0f \n', nef, totalCells);
for i=1:nef
    LaG = elems{i} ;
    nno = length(LaG);
    LaG_ = LaG - 1;
    fprintf(fid, ['%5d ' repmat('%5d ',1,nno) '\n'], nno, LaG_);
end

fclose(fid);

end

