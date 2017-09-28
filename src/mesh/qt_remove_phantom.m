function [ newcoord, newele, neweleCentre, neweleQT, neweleSize, neweleMat ] ...
    = qt_remove_phantom(coord, ele, eleCentre, eleQT, eleSize, eleMat, mat)

pmat = cellfun(@(a)a.phantom, mat);
truelem       = pmat(eleMat) == 0;
neweleCentre  = eleCentre(truelem,:);
neweleQT      = eleQT(truelem,:);
neweleSize    = eleSize(truelem);
neweleMat     = eleMat(truelem);

newele        = ele(truelem);
mark = zeros(1, length(coord));
for i = 1:length(newele)
    mark(newele{i}) = 1;
end
newcoord = coord(mark>0,:);
mark(mark>0) = 1:length(newcoord);
for i = 1:length(newele)
    newele{i} = mark(newele{i});
end

%% calculate phantom area
parea = 0;
pele = find(truelem == 0);
for i = 1:length(pele)
    pid = pele(i);
    pnode = coord(ele{pid},:);
    parea = parea + polyarea(pnode(:,1),pnode(:,2));
end

pradius = sqrt(parea/pi);
disp(['*** Phantom material is removed']);
disp(['    Removed area is ',num2str(parea)]);
disp(['    The equivalent radius is ',num2str(pradius)]);

end

