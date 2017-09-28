function exportimageVTK(I, filename )
%Export image to VTK

%% ***** ***** ***** Writing the vtk file ***** ***** *****
fid = fopen(filename,'w');

%% Writing the header from the vtk file
fprintf(fid,'# vtk DataFile Version 3.1 \n');
fprintf(fid,'This file was created by matlab source code \n');
fprintf(fid,'ASCII \n');
fprintf(fid,'DATASET STRUCTURED_POINTS \n');
fprintf(fid,'DIMENSIONS %d %d %d\n', size(I,1), size(I,2), size(I,3));
fprintf(fid,'ORIGIN 1 1 1 \n');
fprintf(fid,'SPACING 1 1 1 \n');


fprintf(fid,'POINT_DATA %d \n', size(I,1)*size(I,2)*size(I,3));
fprintf(fid,'SCALARS voxel_value int \n');
fprintf(fid,'LOOKUP_TABLE default \n');

fprintf(fid, '%5d \n', I);

fclose(fid);
end

