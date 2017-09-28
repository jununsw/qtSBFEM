function [coord, sdconn, nodecolor, sd2qt, sdhnode] = qt_extractmesh(S, I)
%% get nodal coordinates and construct element connectivity

[r,c] = find(S>0);
sd2qt = sub2ind(size(S),r,c);
elemsize = S(sd2qt);
%build an image with one more pixel on each dimention
nodemap = zeros(size(S,1)+1, size(S,2)+1);
nmr = [r, r+elemsize, r,          r+elemsize];
nmc = [c, c,          c+elemsize, c+elemsize];
nodemap(sub2ind(size(nodemap),nmr,nmc)) = 1;
[x,y] = find(nodemap>0);
coord = [x,y]; %get coordinates of nodes
I = [I,I(:,end)]; %increase one more colum
I = [I;I(end,:)]; %increase one more row
nodecolor = I(sub2ind(size(I), coord(:,1), coord(:,2))); %assign node color
nodemap(sub2ind(size(nodemap),x,y)) = 1:size(coord,1); % assign indices for nodes
% nodes of a element is listed in a anti-clockwise direction.
% be careful of the coordinate system between (x,y) and (r,s)
sdE1 = S(sd2qt)==1;
sdG1 = ~sdE1;
sdconn = zeros(length(sd2qt),8);

if(any(sdG1))
    r2 = r(sdG1); c2 = c(sdG1); h = elemsize(sdG1)./2;% due to the ratio 1:2
    enoder         = [r2 r2+h r2+2*h r2+2*h r2+2*h r2+h   r2     r2];
    enodec         = [c2 c2   c2     c2+h   c2+2*h c2+2*h c2+2*h c2+h];
    sdconn(sdG1,:) = nodemap(sub2ind(size(nodemap),enoder,enodec));
end

if(any(sdE1))
    r1 = r(sdE1); c1 = c(sdE1); 
    enoder             = [r1 r1+1 r1+1 r1  ];
    enodec             = [c1 c1   c1+1 c1+1];
    sdconn(sdE1,1:2:8) = nodemap(sub2ind(size(nodemap),enoder,enodec));
end

sdconn = mat2cell(sdconn,ones(1,size(sdconn,1)));

hmap    = repmat(logical([0,1]),1,4);
sdhnode = cellfun(@ (a) hmap(a>0), sdconn, 'Un', 0); 
sdconn  = cellfun(@ (a) a(a>0), sdconn, 'Un', 0);

end

