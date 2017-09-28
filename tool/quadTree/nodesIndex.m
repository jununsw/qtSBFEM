%------------------------------ PolyMesher -------------------------------%
% Ref: C Talischi, GH Paulino, A Pereira, IFM Menezes, "PolyMesher: A     %
%      general-purpose mesh generator for polygonal elements written in   %
%      Matlab," Struct Multidisc Optim, DOI 10.1007/s00158-011-0706-z     %
%-------------------------------------------------------------------------%
function sind = nodesIndex(P,x1,y1,x2,y2,tolerance)
% By convention, a point located at the left hand side of the line
% is inside the region and it is assigned a negative distance value.
a = [x2-x1,y2-y1]; a = a/norm(a);
b = [P(:,1)-x1,P(:,2)-y1];
d = b(:,1)*a(2) - b(:,2)*a(1);
d = abs(d);

sind_nodes = find(d < tolerance);
sind_ymin = find(P(:,1) >= min(x1,x2));
sind_ymax = find(P(:,1) <= max(x1,x2));
sind_xmin = find(P(:,2) >= min(y1,y2));
sind_xmax = find(P(:,2) <= max(y1,y2));

x = intersect(sind_nodes, sind_ymin, 'rows');
x = intersect(x, sind_ymax, 'rows');
y = intersect(sind_nodes, sind_xmin, 'rows');
y = intersect(y, sind_xmax, 'rows');
sind = intersect (x, y, 'rows');

%-----------