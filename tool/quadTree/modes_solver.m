 function [freqAngular, modalShapes] = modes_solver(nmodes, ndn, bc_disp, K, M)
        
nd = size(K,1);
realdof = 1:size(K,1); %% retain unconstrained DOFs to restore modal shape
        
%% displacement boundary condition
if ~isempty(bc_disp)
    dof = (bc_disp(:,1)-1)*ndn + bc_disp(:,2);
    realdof(dof(:,1)) = []; % retain unconstrained DOFs
    %eliminate rows and columns corresponding to constrained DOFs
    K(dof(:,1), :) = [];
    K(:, dof(:,1)) = [];
    M(dof(:,1), :) = [];
    M(:, dof(:,1)) = [];
end
        
if size(K,1) > 7*nmodes
    [modalShapes, freqAngular] = eigs(K, M, nmodes, 'sm');
else
    [modalShapes, freqAngular] = eig(full(K), full(M));
end
[freqAngular, idx] = sort(sqrt(diag(freqAngular)),'ascend');
mtmp = modalShapes(:,idx(1:nmodes));
modalShapes = zeros(nd,nmodes);
modalShapes(realdof,:) = mtmp;
freqAngular = freqAngular(1:nmodes);
        
end