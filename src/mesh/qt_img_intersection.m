function [intercoord, inter2edge, edge2inter] = qt_img_intersection(I, coord, meshEdge)
%calculate intersections based on image I

I = [I,I(:,end)]; %increase one more colum
I = [I;I(end,:)]; %increase one more row

edge1     = coord(meshEdge(:,1),1:2)';
edge2     = coord(meshEdge(:,2),1:2)';
compass   = edge1~=edge2;
edgelen   = edge2(compass)-edge1(compass);

step          = zeros(size(edge1));
step(compass) = sign(edgelen);
step          = mat2cell(step',ones(1,size(step,2)));
edgelen       = abs(edgelen);

offset = arrayfun(@(a)[1:a]', edgelen, 'Un', 0);
offset = cellfun(@(a,b) bsxfun(@times,a,b), offset, step, 'Un', 0);
ebegin = mat2cell(edge1', ones(1,size(edge1,2)));
enode  = cellfun(@(a,b) bsxfun(@plus,a,b), offset, ebegin, 'Un', 0);

% calculate intersections
idxeb = cellfun(@(a) sub2ind(size(I),a(:,1),a(:,2)), ebegin, 'Un', 0);
idxen = cellfun(@(a) sub2ind(size(I),a(:,1),a(:,2)), enode, 'Un', 0);
edge2inter = cellfun(@(a,b) I(a(end))~=I(b), idxen, idxeb);

%different ways of checking intersections
% inter = cellfun(@(a,b) find(I(a)~=I(b),1,'first'), idxen(edge2inter), idxeb(edge2inter), 'Un', 0);
inter = cellfun(@(a) find(I(a)==I(a(end)),1, 'first'), idxen(edge2inter), 'Un', 0);

intercoord = cellfun(@(a,b,c) a+b*(c-0.5), ...
                     ebegin(edge2inter), step(edge2inter), inter, 'Un', 0);

% export results
intercoord             = cell2mat(intercoord);
inter2edge             = find(edge2inter);
edge2inter             = zeros(size(edge2inter));
edge2inter(inter2edge) = 1:length(inter2edge);

end

