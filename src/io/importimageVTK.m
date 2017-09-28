function img = importimageVTK( filename )
%IMPORTIMAGEVTK Summary of this function goes here
%   Detailed explanation goes here

fid = fopen(filename);
assert(fid ~= -1);

dim = zeros(1,3);
while ~feof(fid)
    aline = strtrim(fgetl(fid));
    strcell = strsplit(aline, ' ');
    if(strcmp(strcell{1}, 'DIMENSIONS'))
        dim(1) = str2num(strcell{2});
        dim(2) = str2num(strcell{3});
        dim(3) = str2num(strcell{4});
        break;
    end
end

dim = dim(dim~=1);
assert(length(dim) == 2);
img = zeros(dim(1), dim(2));

while ~feof(fid)
    aline = strtrim(fgetl(fid));
    strcell = strsplit(aline, ' ');
    if(strcmp(strcell{2}, 'default'))
        img = fscanf(fid, ' %d', [dim(1),dim(2)]);
        break;
    end
end

fclose(fid);
end

