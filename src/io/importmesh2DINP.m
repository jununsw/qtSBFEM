function [coord, ele] = importmesh2DINP( filename )
%IMPORTMESHINP Summary of this function goes here
%   Detailed explanation goes here

fid = fopen(filename);
assert(fid ~= -1);

% %% get node and element number
% en = 0;
% nn = 0;
% while ~feof(fid) && (en==0 || nn==0)
%     aline = strtrim(fgetl(fid));
%     strcell = strtrim(strsplit(aline, ','));
%     if(strcmp(strcell{1}, '*Nset') && strcmp(strcell{end}, 'generate'))
%         aline = strtrim(fgetl(fid));
%         strcell = strsplit(aline, ',');
%         nn = str2num(strcell{2});
%         continue;
%     end
%     if(strcmp(strcell{1}, '*Elset') && strcmp(strcell{end}, 'generate'))
%         aline = strtrim(fgetl(fid));
%         strcell = strsplit(aline, ',');
%         en = str2num(strcell{2});
%         continue;
%     end
% end
% 
% frewind(fid);
coord = [];
ele   = [];
while ~feof(fid) && (isempty(coord) || isempty(ele))
    aline = strtrim(fgetl(fid));
    if(strcmp(aline, '*Node'))
        coord = fscanf(fid, '%f,%f,%f\n', [3, inf]);
        coord(1,:) = [];
        coord = coord';
        continue;
    end
    
    strcell = strsplit(aline, ',');
    if(strcmp(strcell{1}, '*Element'))
        ele = fscanf(fid, '%d,%d,%d,%d,%d\n', [5,inf]);
        ele(1,:) = [];
        ele = ele';
        ele = mat2cell(ele,ones(1,size(ele,1)),size(ele,2));
        continue;
    end
end

fclose(fid);

end

