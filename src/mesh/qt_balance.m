function bqt = qt_balance(S)
%% enforce 2:1 ratio

[M,N] = size(S);
maxDim = full(max(max(S))); minDim = full(min(min(S(S>0))));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%De%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

bqt = zeros(M,N);
bqt(sub2ind([M,N],sr(sr>0),sc(sr>0))) = sdim(sr>0);

end
