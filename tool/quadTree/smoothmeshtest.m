function [ele,eleMat,eleQT,eleSize] = smoothmeshtest(ele,coord,eleMat,eleQT, eleSize)
eleTrue = 1:length(ele);
eleTrue(eleMat == 3)=[];
coorda = cell2mat(ele(eleTrue(eleQT(eleTrue,1) == 1)));
coorda = unique(coorda);
coorda = coord(coorda,:);
[ QTedge, ~, ~, edge2Ele ] = findElementEdges(ele, coord );
xmin = min(coorda(:,1)); xmax = max(coorda(:,1));
ymin = min(coorda(:,2)); ymax = max(coorda(:,2));
[a,~] = find(coord(:,1) == xmin); [b,~] = find(coord(:,1) == xmax);
[c,~] = find(coord(:,2) == ymin); [d,~] = find(coord(:,2) == ymax);
corner = cell(4,1);
corner{1,1} = intersect(a,c); corner{2,1} = intersect(b,c);
corner{3,1} = intersect(b,d); corner{4,1} = intersect(a,d);

for i = 1:4
    if ~isempty(corner{i,1})
        [row,~] = find(QTedge(:,1) == corner{i,1});
        if isempty(row)
            [row,~] = find(QTedge(:,2) == corner{i,1});
            if isempty(row)
                corner{i,1} = [];continue
            end
        end
        corner{i,1} = edge2Ele{row(1),1};
    end
end
corner = cell2mat(corner); % the corner elements of the domain that won't be changed
[ ~, ~, eleEdge, edge2Ele ] = findElementEdges( ele, coord );
[ele,eleMat,eleQT,eleSize] = White(ele, coord, eleMat, eleEdge, edge2Ele, eleQT, eleSize, corner);
[ ~, ~, eleEdge, edge2Ele ] = findElementEdges(ele, coord );
[ele,eleMat,eleQT,eleSize] = Grey(ele, coord, eleMat, eleEdge, edge2Ele, eleQT, eleSize, corner);
[ ~, ~, eleEdge, edge2Ele ] = findElementEdges(ele, coord );
[ele,eleMat,eleQT,eleSize] = All(ele, coord, eleMat, eleEdge, edge2Ele, eleQT, eleSize, corner);
end