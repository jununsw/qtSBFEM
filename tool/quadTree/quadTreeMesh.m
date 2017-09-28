function [coord, ele, eleQT, eleColor, eleSize, eleCentre, eleDof, maxDim, minDim] = quadTreeMesh(S,I,voidColor,Ndof)
[M,N] = size(S);
maxDim = full(max(max(S))); minDim = full(min(min(S(S>0))));
if nargin < 3; voidColor = []; end

%% enforce 2:1 ratio

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creating matrix J whose size = image size and used to indicate the
% occupation of each types of square by assigning the dimension dim to all the
% elements of the square blocks that have the same size dim --> used to
% identify the neighbour with smaller size
nSplit = 1;
% creating matrix J contains elements with value = max dimension
J = repmat(maxDim,size(S));
%start from the 2nd biggest dimension
dim = maxDim/2;
%run the loop for each square dimension
while dim >= minDim;
    % return blocks as the indices of left corner of the square's size =dim
    blocks = find(S==dim)';
    %compute number of squares
    numBlocks = length(blocks);
    if numBlocks>0
        % Compute block indices for a dim-by-dim block.
        % The indices in matrix increase from top to bottom and left to
        % right eg: indices number increase by 1 in the row direction and
        % by M( number of rows) in the column direction.
        % Output ind will be in the form ind
        % =[Square_indices_1,Square_indices_2,...].
        %each Square_indices contains a columns of indices of all the elements of that
        %square. number of columns of ind = number of blocks
        ind = blockIndex(M, dim, blocks);
        
        %replace all the values in J(element indices = ind) = dimension dim
        J(ind) = dim;
    end
    %next dimension
    dim = dim/2;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This part will split the square base on the condition of the neighbour
% hence new squares/elements will be introduced

% return row, column of left corner of the square along with corresponding
% dimension in S matrix
[sr, sc, sdim] = find(S);
sLen = length(sr);
sLenIncr = sLen;
% attach sr, sc, sdim to a column of zeros which will be replaced by new
% points after splitting
sr = [sr; zeros(sLenIncr,1)];
sc = [sc; zeros(sLenIncr,1)];
sdim = [sdim; zeros(sLenIncr,1)];
sLenMax = 2*sLen;

%loops structure contains 2 loops
%Inner loop: run through each dimension start from max to 4*minDim
%inclusively and check for neigbour and split the square if the condittion
%is met. Update sr, sc, dim as new square are introduced
%Outer loop: run the inner loop untill no further splitting is required.

%mapping equation from row,column --> indices: indices of element in matrix
%=row + M*(column-1) with M is number of rows

while nSplit>0
    dim = maxDim;
    nSplit = 0;
    while (dim > 2*minDim)
        % Find all the blocks at the current size.
        % a is the indices of elements with size = dim in S matrix
        a = find(sdim==dim);
        % take out the row and column associated with that elements
        r = sr(a); c = sc(a);
        % dim2 is the min dim of neighbour that satisfy 2:1 ratio hence no
        % splitting
        dim2 = dim/2;
        % dosplit is boolean vector (true or false) present spitting
        % criteria for each elements of size dim
        doSplit = zeros(length(r),1);
        
        % check for neighbour at the north side of each square
        bindx = find(r>1); % eliminate square at the top row 
        if ~isempty(bindx)
            Sind = r(bindx)-1+M*(c(bindx)-1);
            %ind only includes indices of elements at the north side
            ind = (0:M:(dim-1)*M)';
            ind = bsxfun(@plus, ind(:), Sind');
%            % Jblks contains all north side neighbour of each elemens with size= dim
            Jblks = J(ind);
            % dosplit of element = 1 when smallest dim of neighbour < dim2
            doSplit(bindx(min(Jblks)<dim2)) = 1;
        end
        
         % similar to above but check for south side of each square
        bindx = find((r+dim) < M);
        if ~isempty(bindx)
            Sind = r(bindx) + dim + M*(c(bindx)-1);
            ind = (0:M:(dim-1)*M)';
            ind = bsxfun(@plus, ind(:), Sind');
%            Jblks = reshape(J(ind), dim, []);
            Jblks = J(ind);
            doSplit(bindx(min(Jblks)<dim2)) = 1;
        end
        
         % check for west side of each squares
        bindx = find(c>1);
        if ~isempty(bindx)
            Sind = r(bindx) + M*(c(bindx)-2);
            ind = (0:(dim-1))';
            ind = bsxfun(@plus, ind(:), Sind');
%            Jblks = reshape(J(ind), dim, []);
            Jblks = J(ind);
            doSplit(bindx(min(Jblks)<dim2)) = 1;
        end
        
        %Check for east side of each squares
        bindx = find((c+dim) < N);
        if ~isempty(bindx)
            Sind = r(bindx) + M*(c(bindx)+dim-1);
            ind = (0:(dim-1))';
            ind = bsxfun(@plus, ind(:), Sind');
%            Jblks = reshape(J(ind), dim, []);
            Jblks = J(ind);
            doSplit(bindx(min(Jblks)<dim2)) = 1;
        end
        % Start the splitting process
        % sdosplit contains the indices of doSplit >0 which is the
        % indices of square left corner that requires
        % splittin
        sDoSplit = find(doSplit>0);
         %Check for whether the size of sr sc and sdim need to be increased
        %to store new points
        if sLen+length(sDoSplit) > sLenMax
            sr = [sr; zeros(sLenIncr,1)];
            sc = [sc; zeros(sLenIncr,1)];
            sdim = [sdim; zeros(sLenIncr,1)];
            sLenMax = sLenMax + sLenIncr;
        end
         % loop through each elements requires splitting
        for ii = sDoSplit'
            J(r(ii):r(ii)+dim-1,c(ii):c(ii)+dim-1) = dim2;%update J
            sdim( a(ii) ) = dim2; %update sdim
            
             %cause each square will be splitted into 4 squares hence
            %introduces 3 points for each splitting hence update sr, sc,
            %sdim
            
            % new point at the south side
            sLen = sLen + 1;
            sr(sLen) = r(ii)+dim2; sc(sLen) = c(ii);  sdim(sLen) = dim2;
            % new point at the east side
            sLen = sLen + 1;
            sr(sLen) = r(ii); sc(sLen) = c(ii)+dim2; sdim(sLen) = dim2;
            %new point at the south east side
            sLen = sLen + 1;
            sr(sLen) = r(ii)+dim2; sc(sLen) = c(ii)+dim2; sdim(sLen) = dim2;
        end
        dim = dim2;% update dim to dim/2
        nSplit = nSplit + length(sDoSplit);% count number of split
    end
end
% Create S matrix contain quadtree mesh information with 2:1 ratio enforced
S = sparse(sr(sr>0),sc(sr>0), sdim(sr>0), M, N);

%% get color in elements
maxDim = full(max(max(S))); minDim = full(min(min(S(S>0))));
disp(['    Maximum element size = ',num2str(maxDim)]);
disp(['    Minimum element size = ',num2str(minDim)]);

nLevel = 1+nextpow2(maxDim/minDim);% number of square dimensions
r = cell(nLevel,1);
c = cell(nLevel,1);
eleColor = cell(nLevel,1);
dim = maxDim;
ii = 1;
%run loop for each element to extract information on row, col and dimension
while dim >= minDim;
%    [eleColor{ii},r{ii},c{ii}] = qtgetblkavg(I,S,dim);
    [r{ii}, c{ii}] = find(S == dim);
    if isempty(r{ii});  continue;  end
    % compute indices for all squares of size dim then recall the values
    % from intensity matrix I at that indices to compute colour
    Sind = (r{ii} + M*(c{ii}-1))';
    ind = blockIndex(M, dim, Sind); 
    eleColor{ii} = (sum(I(ind),1))'/(dim*dim);
    ii = ii+1;
    dim = dim/2;
end
%convert to matrix form
r=cell2mat(r); c=cell2mat(c);
eleColor = cell2mat(eleColor);
% if ~isempty(voidColor) %remove elements in voids
%     if length(voidColor) == 1
%         a = eleColor~=voidColor;
%     else
%         a = (eleColor<voidColor(1) | eleColor>voidColor(2));
%     end
%     r = r(a); c = c(a);
%     eleColor = uint8(round(eleColor(a)));
% end

%% get nodal coordinates and construct element connectivity

nEle = length(r);% number of ele

Sind = r+M*(c-1);% compute indices
eleSize = J(Sind);% compute and store size of all square in eleSize
%compute nodal coordinate, x1,y1 is top left and x2,y2 is bottom right
x1 = c-0.5;  y1=r-0.5; x2=x1+eleSize; y2=y1+eleSize;
eleCentre = [(x1+x2)/2 (y1+y2)/2];

% eCd = [X(1),Y(1),X(2),Y(2).....] contains coordinates of all elements
% X=[x1;x2;x2;x1;0;0;0;0] Y=[y2;y2;y1;y1;0;0;0;0]
% in each elements nodes is numbering in the counter-clockwise direction
% starting from the bottom left points (x1,y2)

eCd = [ x1  x2  x2 x1 zeros(nEle,4) y2 y2 y1 y1 zeros(nEle,4) ]';
eCd = reshape(eCd,8,2*nEle);
% Compute size of neighbour at north,south,east, west directions in order
% to determine numbers and postions of hanging nodes
% set the values at the boundary equal to max dim
% the process is similar to the enforcing 2:1 ratio section

Jnorth = maxDim*ones(nEle,1); Jsouth = Jnorth;  Jwest = Jnorth;  Jeast = Jnorth;
%North
b = r > 1; Sind = r(b)-1 + M*(c(b)-1); 
Jnorth(b) = J(Sind);
%South
b = (r+eleSize) < M; Sind = r(b) + eleSize(b) + M*(c(b)-1);
Jsouth(b) = J(Sind);
%West
b = c > 1; Sind = r(b) + M*(c(b)-2);
Jwest(b) = J(Sind);
%East
b = (c+eleSize) < N; Sind = r(b) + M*(c(b)+eleSize(b)-1);
Jeast(b) = J(Sind);
clear J;

ele = cell(nEle,1);
eleQT = zeros(nEle,1);
eleNode = zeros(nEle,1);
eleCoord = cell(nEle,1);
a = [1:4 1:4];

% loop through each elements. Loop structure contains 2 parts

% first part look at four boundaries and introduce new hanging nodes if size
% boundaries < size elements and information of the hanging nodes is stored
% in mNode(i) i=1 for south, 2 for east and so on so for
% The checking start from south->east->north->west. Coordinates
% of new hanging nodes are stored in exy
% It is suggested to draw different types of square as the loop runnning
for ii = 1:nEle
    dim = eleSize(ii); dim2 = dim/2;
    exy = eCd(:,2*ii-1:2*ii);
    inode = 4;  mNode = zeros(1,4);
    if dim > minDim
        if Jsouth(ii) < dim
            inode = inode + 1; mNode(1) = inode;
            exy(inode,:) = [ exy(1,1)+dim2 exy(1,2)];
        end
        if Jeast(ii) < dim
            inode = inode + 1; mNode(2) = inode;
            exy(inode,:) = [exy(2,1) exy(3,2)+dim2];
        end
        if Jnorth(ii) < dim
            inode = inode + 1; mNode(3) = inode;
            exy(inode,:) = [ exy(1,1)+dim2 exy(3,2)];
        end
        if Jwest(ii) < dim
            inode = inode + 1; mNode(4) = inode;
            exy(inode,:) = [ exy(1,1) exy(3,2)+dim2];
        end
    end
    
    
    % Second part of loop: re-ordering the nodes and determine type of quadtree
% mesh There are 6 types of square and 4 types of orientations

% type 1: 4 nodes. Type 2: 5 nodes. Type 3: 6 nodes (2 hanging nodes on 2
% adjacent sides except the combination when they are at south and west side. 
% Type  4: 6 nodes ( 2 hanging nodes on opposite sides). Type 5: 7 nodes.
% Type 6: 8 nodes.

% Node ordering rule: Numbering them in counter clockwise direction.
% the first hanging node encounter in that direction becomes local node 2
    switch inode
        case 4
            qtType = 1;
        case 5
            qtType = 2; k = find(mNode>0);
            exy = exy([k mNode(k) a(k+1:k+3)],:);
        case 6
            k = find(mNode>0);
            if k(2)-k(1) == 1
                qtType = 3; k = k(1);
                exy = exy([k mNode(k) a(k+1) mNode(k+1) a(k+2) a(k+3)],:);
            elseif k(2)-k(1) == 2
                qtType = 4; k = k(1);
                exy = exy([k mNode(k) a(k+1) a(k+2) mNode(k+2) a(k+3)],:);
            else
                qtType = 3; exy = exy([4 6 1 5 2 3],:);
            end
        case 7
            qtType = 5; k = 1+find(mNode==0);
            exy = exy([a(k) mNode(a(k)) a(k+1) mNode(a(k+1)) a(k+2) mNode(a(k+2)) a(k+3)],:);
        case 8
            qtType = 6; exy = exy([ 1 5 2 6 3 7 4 8],:);
    end
    % copy values to the global vector
    ele{ii} = 1:inode;
    eleNode(ii) = inode;
    eleCoord{ii} = exy(1:inode,:);
    eleQT(ii,1) = qtType;
    % determine orientation as the second argument of qtType. 1 = South
    % side, 2 = East side, 3 = North side, 4 = West side
    dx = exy(2,1)-exy(1,1); dy = exy(2,2)-exy(1,2);
    if abs(dx) > abs(dy)
        if dx > 0; eleQT(ii,2) = 1;  else eleQT(ii,2) = 3; end
    else
        if dy > 0; eleQT(ii,2) = 4;  else eleQT(ii,2) = 2; end %note: y is positive when pointing downward
    end
end

%% merge nodes and update element connectivity
% transform y to positive when pointing upwards

% coord = cell2mat(eleCoord);
% coord(:,2) = M+1 - coord(:,2); 
% eleCentre(:,2)= M+1 - eleCentre(:,2);

coord_image = cell2mat(eleCoord);
b = [1 0; 0 -1];
c = zeros(length(coord_image),2);
d = zeros(length(eleCentre),2);
c(:,1) = -0.5; c(:,2) = M + 0.5;
d(:,1) = -0.5; d(:,2) = M+0.5;
coord = [coord_image(:,1) coord_image(:,2)] * b + c;
eleCentre = [eleCentre(:,1) eleCentre(:,2)] * b + d;
coord = round(2*coord(:,:));
% Delete the repetive nodes in coord, ic returns the indices such that 
% coord_old=coord_new(ic) hence ic store the connectivity of each nodes
% globally
[coord, ~, ic] = unique(coord,'rows');
coord = coord/2;
%ele = cellfun(@(x) ic(x)',ele,'UniformOutput',false); %slower than the
%following loop
cumNode = 0;
eleDof = cell(nEle,1);
nNode = size(coord,1);

if Ndof==2
    gDof = [1:2:2*nNode;2:2:2*nNode];
elseif Ndof==1
    gDof = 1:nNode;
end
% Compute connectivity for each elements and degree of freedom and store in
% array ele in the form ele = {Ele_1} {Ele_2} ....
% {Ele_i} = [ global_node_of_local_1 , global_node_of_local_2, .... ]
for ii = 1:nEle
    ele{ii} = ic(ele{ii}+cumNode)';
    eDof = gDof(:,ele{ii});
    eleDof{ii} = eDof(:);
    cumNode =  cumNode+eleNode(ii);
end

end

