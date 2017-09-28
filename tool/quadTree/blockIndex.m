function [ind] = blockIndex(M, dim, blocks)
% Compute block indices for a dim-by-dim block.
rows = (0:dim-1)';
cols = 0:M:(dim-1)*M;
rows = rows(:,ones(1,dim));
cols = cols(ones(dim,1),:);
ind = rows(:) + cols(:);
% Compute index matrix for block computations.
ind = bsxfun(@plus, ind, blocks);
end
