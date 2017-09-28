function [handle] = PlotElement_Duc(coord, ele,eleTrue, val, cMap,eleMat,matNum)
if nargin < 4; cMap=gray; end

ele_temp=ele;
if matNum~=0 
    ele = ele_temp(ismember(eleMat,matNum));
else
    ele=ele(eleTrue);
end
ne  = length(ele);
elePoint = NaN(ne,8);
for ii = 1:ne
    nodes = ele{ii};
    elePoint(ii,1:length(nodes)) = nodes;
end


handle = patch('Faces',elePoint,'Vertices',coord,'FaceVertexCData',...
    val,'FaceColor','interp','EdgeColor','none');
axis equal; axis off; axis tight; 
colormap(cMap);



end

