function exportsbfemVTK(filename, coord, ele, nodevalue, elevalue)
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
if(size(coord,2) == 2)
    coord = [coord,zeros(size(coord,1),1)];
end
totalNno = size(coord,1);  % Total of nodes
fprintf(fid,'POINTS %3.0f  FLOAT \n', totalNno);
for i=1:totalNno
    fprintf(fid, [repmat('%12.5f ',1,3) '\n'], coord(i,:));
end

%% Initial parameters
nef = size(ele,1);

%% Writing the cells or nodes
totalCells = sum(cellfun(@(a)length(a),ele)) + nef;
fprintf(fid, '\n');
fprintf(fid,'POLYGONS %5d %5d \n', nef, totalCells);
for i=1:nef
    LaG = ele{i} ;
    nno = length(LaG);
    LaG_ = LaG - 1;
    fprintf(fid, ['%5d ' repmat('%5d ',1,nno) '\n'], nno, LaG_);
end

if(~isempty(nodevalue))
    nodenum = length(coord);
    fprintf(fid, '\n');
    fprintf(fid, '\n');
    fprintf(fid,'POINT_DATA %d \n', nodenum);
    
    fprintf(fid,'FIELD FieldData 1 \n');
    fprintf(fid,'nodevalue %d %d double \n', size(nodevalue,1), size(nodevalue,2));
    fprintf(fid, [repmat('%f\t', 1, size(nodevalue,1)) '\n'], nodevalue);
end

if(~isempty(elevalue))
    elenum = length(ele);
    fprintf(fid, '\n');
    fprintf(fid, '\n');
    fprintf(fid,'CELL_DATA %d \n', elenum);
    
    fprintf(fid,'FIELD FieldData 1 \n');
    fprintf(fid,'elemvalue %d %d double \n', size(elevalue,1), size(elevalue,2));
    fprintf(fid, [repmat('%f\t', 1, size(elevalue,1)) '\n'], elevalue);
end

fclose(fid);

end

