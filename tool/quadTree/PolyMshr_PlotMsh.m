function PolyMshr_PlotMsh(type, coord,ele, eleMat)
% type = 0: elements whitout color
% type = 1: fill color in elements
hold on;
ne  = length(ele);
elePoint = NaN(ne,17);
for ii = 1:ne
    nodes = ele{ii};
    elePoint(ii,1:length(nodes)) = nodes;
end
if type == 1
    a = eleMat == 1; b = eleMat == 2;
    patch('Faces',elePoint(a,:),'Vertices',coord,'FaceColor',[0.4 0.4 0.4]); 
    patch('Faces',elePoint(b,:),'Vertices',coord,'FaceColor','g'); 
else
    patch('Faces',elePoint,'Vertices',coord,'FaceColor','w','LineWidth',1.5); 
end
% if exist('Supp','var')&&~isempty(Supp)&&~isempty(Load)%Plot BC if specified
%   plot(coord(Supp(:,1),1),coord(Supp(:,1),2),'b>','MarkerSize',8);
% %   plot(Supp(:,1),Supp(:,2),'b>','MarkerSize',8);
%   plot(coord(Load(:,1),1),coord(Load(:,1),2),'m^','MarkerSize',8); hold off;
% end
% end

