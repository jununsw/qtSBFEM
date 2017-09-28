function [handle] = PlotElement(coord, ele, val, cMap)
if nargin < 4; cMap=gray; end
ne  = length(ele);
elePoint = NaN(ne,8);
for ii = 1:ne
    nodes = ele{ii};
    elePoint(ii,1:length(nodes)) = nodes;
end

handle = patch('Faces',elePoint,'Vertices',coord,'FaceVertexCData',...
    val,'FaceColor','flat','EdgeColor','none');
axis equal; axis off; axis tight; 
colormap(cMap);
end

