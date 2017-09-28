function [U, ReFrc] = static_solver(ndn, bc_force, bc_disp, K, F)

%% external forces
if ~isempty(bc_force)
    dof = (bc_force(:,1)-1)*ndn + bc_force(:,2);
    F(dof) = F(dof) + bc_force(:,3);
end

%% displacement boundary condition
FixedDofs = [];
if ~isempty(bc_disp)
    FixedDofs = (bc_disp(:,1)-1)*ndn + bc_disp(:,2);
    F = F - K(:,FixedDofs)*bc_disp(:,3);
end

nd = size(K,1);
FreeDofs   = (1:nd);
FreeDofs(FixedDofs(:,1)) = [];

U = zeros(nd,1); ReFrc = zeros(nd,1);
U(FixedDofs) = bc_disp(:,3);
U(FreeDofs) = K(FreeDofs,FreeDofs)\F(FreeDofs);
ReFrc(FixedDofs(:,1)) = K(FixedDofs(:,1),:)*U;

%nodeDisp = reshape(U,ndn,[]);

% %% displacement boundary condition
% if ~isempty(bc_disp)
%     dof = (bc_disp(:,1)-1)*ndn + bc_disp(:,2);
%     dsp = bc_disp(:,3);
%     F = F - K(:,dof)*dsp;
%     Kdiag = diag(K(dof,dof));
%     K(dof,:) = 0;
%     K(:,dof) = 0;
%     K(dof,dof) = diag(Kdiag);
%     F(dof) = Kdiag.*dsp;
% end
% 
% %%
% sln = K\F;
% nodeDisp = reshape(sln,ndn,[]);

end
