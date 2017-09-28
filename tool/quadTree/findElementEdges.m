function [ QTedge, QTedgeCentre, eleEdge, edge2Ele] = findElementEdges( ele, coord )
%% edges of elements
nEle = length(ele);
QTedge = cell(nEle,1);
eleEdge = cell(nEle,1);
indx1 = 1;
%edge = cellfun(@(x) [x;x(2:end) x(1)], ele, 'UniformOutput', false);
%%takes more time than the following loop
for ii = 1:nEle
    eNode = ele{ii};
    indx2 = indx1 + length(eNode) - 1;
    QTedge{ii} = [eNode; eNode(2:end) eNode(1)];
    eleEdge{ii} = indx1:indx2;
    indx1 = indx2 + 1;
end
QTedge = sort([QTedge{:}]);
[QTedge, ~, ic] = unique(QTedge','rows');
QTedgeCentre = zeros(size(QTedge));
for ii = 1:size(QTedge,1);
     QTedgeCentre(ii,:) = (coord(QTedge(ii,1),:)+coord(QTedge(ii,2),:))/2;
end
for ii = 1:nEle
    eleEdge{ii} = ic(eleEdge{ii});
end

%% find elements connected to an edge
a = cell2mat(eleEdge);
aEle = zeros(length(a),1);
ib = 1;
for ii = 1:nEle
    ie = ib + length(eleEdge{ii}) - 1;
    aEle(ib:ie) = ii;
    ib = ie + 1;
end
[c, indx] = sort(a); aEle = aEle(indx);
ib = 1;
nQTedge = length(QTedge);
edge2Ele = cell(nQTedge,1);
for ii = 1:nQTedge-1
    if c(ib+1) == ii
        edge2Ele{ii} = aEle(ib:ib+1);
        ib = ib + 2;
    else
        edge2Ele{ii} = aEle(ib);
        ib = ib + 1;
    end 
end

edge2Ele{ii+1} = aEle(ib);

% %% find edges connected to a node
% a = reshape(edge',1,[]); %nodes on edges
% edgei = reshape([1:size(edge,1); 1:size(edge,1)],1,[]); %edge number
% [c, indx] = sort(a); edgei = edgei(indx); %sort edge number according to node number
% ib = 1;
% node2Edge = cell(nNode,1);
% for ii = 1:nNode-1
%     ie = ib-1+find(c(ib:ib+3)==ii, 1, 'last');
%     node2Edge{ii} = edgei(ib:ie);
%     ib = ie + 1;
% end
% node2Edge{nNode} = edgei(ib:end);


end