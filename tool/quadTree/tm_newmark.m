function [step] = tm_newmark(TIMEPara,forceHistory, ndn, bc_force, bc_disp, K, M, F)
%time domain analysis
ns = TIMEPara(1);
dt = TIMEPara(2);
gamma = TIMEPara(3);
beta =  TIMEPara(4);

nd = size(K,1);

step(ns+1) = struct('tm',[],'disp',[]);

%% external forces
%adding boundary forces to force vector
if ~isempty(bc_force)
    fdof = (bc_force(:,1)-1)*ndn + bc_force(:,2);
    F(fdof) = F(fdof) + bc_force(:,3);
end
% displacement boundary condition
%Compute fixed DOF and free DOFs
FixedDofs = [];
if ~isempty(bc_disp)
    FixedDofs = (bc_disp(:,1)-1)*ndn + bc_disp(:,2);
end
FreeDofs   = (1:nd);
FreeDofs(FixedDofs) = [];

%% initial time step (t = 0)
%Note: in dynamic analysis, the bc_disp now is the boundary acceleration
%not displacement
ft = interp1(forceHistory(:,1), forceHistory(:,2),0,'linear');
an = zeros(nd,1);
if abs(ft) > 1.d-20
    % balance initial forces with inertial forces
    f = ft*F;
    bc_an = ft*bc_disp(:,3);
    if ~isempty(FixedDofs)
        f = f - M(:,FixedDofs)*bc_an;
    end
    an(FreeDofs) = (M(FreeDofs,FreeDofs)\f(FreeDofs));
    an(FixedDofs) = bc_an;
end
vn = zeros(nd,1);
dn = zeros(nd,1);

step(1).tm = 0;
step(1).disp = reshape(dn, ndn,[]);
step(1).accl = reshape(an, ndn,[]);
% step(1).disp = dn;
% step(1).accl = an;

%% Using new-mark method to solve for acceleration and displacement at time step t
fg1 = gamma*dt;
fg2 = (1.d0-gamma)*dt;
fb1 = beta*dt*dt;
fb2 = (0.5d0-beta)*dt*dt;

% dynamic-stiffness matrix
dstf = M(FreeDofs,FreeDofs) + fb1*K(FreeDofs,FreeDofs);
%        LLTdstf =  chol(dstf,'lower');
%        [Ldstf  Udstf] = lu(dstf);
[Ldstf, p, s] = chol(dstf,'lower','vector');

t = 0;
tmp = zeros(length(FreeDofs),1);
tm = [1:ns]*dt;
ftm = interp1(forceHistory(:,1), forceHistory(:,2), tm,'linear');
for it = 1:ns
%    t = t + dt;
    t = tm(it);
    dp = dn + dt*vn + fb2*an;      %displacement predictor
    vp = vn + fg2*an;              %velocity predictor
%    ft = interp1(forceHistory(:,1), forceHistory(:,2),t,'linear');
    ft = ftm(it);
    f = ft*F;
    dptmp = dp; vptmp = vp;
    if ~isempty(FixedDofs)
        bc_an = ft*bc_disp(:,3);
        an(FixedDofs) = bc_an;
        vptmp(FixedDofs) = vptmp(FixedDofs) + fg1*an(FixedDofs);        %velocity corrector
        dptmp(FixedDofs) = dptmp(FixedDofs) + fb1*an(FixedDofs);        %displacement corrector
        f = f - M(:,FixedDofs)*bc_an;
    else
        bc_an = [];
    end
    f = f - K*dptmp;
    f = f(FreeDofs);
    %            an = LLTdstf'\(LLTdstf\an); %Time consuming, Matlab does
    %recognize the structure of LLTdstf
    %            an = Udstf\(Ldstf\an);
    %            an = dstf\an;
    tmp(s) = Ldstf'\(Ldstf\(f(s)));
   
    an(FreeDofs) = tmp;
    an(FixedDofs) = bc_an;
    
    vn = vp + fg1*an;        %displacement corrector
    dn = dp + fb1*an;        %velocity corrector
    
    step(it+1).tm = t;
     step(it+1).disp = reshape(dn, ndn,[]);
     step(it+1).accl = reshape(an, ndn,[]);
%     step(it+1).disp = dn;
%     step(it+1).accl = an;
    
end

end
