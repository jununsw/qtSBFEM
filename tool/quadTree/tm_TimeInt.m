function [step] = tm_TimeInt(TIMEPara,forceHistory, ndn, bc_force, bc_disp, K, M, F)
%Similar to tm_mark program but using trapezoidal rule as the DEs is first
%order
ns = TIMEPara(1);
dt = TIMEPara(2);
beta_t =  TIMEPara(5);

nd = size(K,1);

step(ns+1) = struct('tm',[],'Temp',[]);

if ~isempty(bc_force)
    fdof = (bc_force(:,1)-1)*ndn + bc_force(:,2);
    F(fdof) = F(fdof) + bc_force(:,3);
end
% displacement boundary condition
FixedDofs = [];
if ~isempty(bc_disp)
    FixedDofs = (bc_disp(:,1)-1)*ndn + bc_disp(:,2);
end
FreeDofs   = (1:nd);
FreeDofs(FixedDofs) = [];

%% initial time step (t = 0)
% the temperature at fixed DOF is assumed to remain constant throughout the
% time
ft = interp1(forceHistory(:,1), forceHistory(:,2),0,'linear');
U_initial = zeros(nd,1);
U_initial(FixedDofs)=bc_disp(:,3);

step(1).tm=0;
step(1).Temp=U_initial;

%% time stepping
A=(1/dt*M+beta_t*K);
[L_A, p, s] = chol(A(FreeDofs,FreeDofs),'lower','vector');
B=(1/dt*M-(1-beta_t)*K);

tmp = zeros(length(FreeDofs),1);
tm = [1:ns]*dt;
ftm = interp1(forceHistory(:,1), forceHistory(:,2), tm,'linear');
ftm=[ft,ftm];
U_0=U_initial;

for it = 1:ns
    t=tm(it);
    F_0=(1-beta_t)*ftm(it)*F;
    F_1=beta_t*ftm(it+1)*F;
    RHS=B*U_0+F_0+F_1-A(:,FixedDofs)*U_0(FixedDofs);
    RHS=RHS(FreeDofs);
%   tmp=A(FreeDofs,FreeDofs)\RHS;
    tmp(s)=L_A'\(L_A\(RHS(s)));
    U_0(FreeDofs)=tmp;
    
    step(it+1).tm=t;
    step(it+1).Temp=U_0;
    Umax_temp=max(U_0);
    
end


    





end