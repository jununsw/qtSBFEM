function [ Kb, lambda, v11, v11inv, Mb] = getSBFEMStiffMat_2NodeEle_1D( xy, eConn, G, density, g)
    nn = size(eConn,2); nd = nn; id = 1:nd; 
    E0 = zeros(nd, nd);  E1 = zeros(nd, nd);  E2 = zeros(nd, nd); M0 = zeros(nd, nd);
    n1 = eConn(1,:); n2 = eConn(2,:); dof = eConn;
    %x = xy(:,1)' - mean(xy(:,1)); y = xy(:,2)' - mean(xy(:,2));
    x = xy(:,1)'; dx = (x(n2)-x(n1))/2; ax = (x(n2)+x(n1))/2;
    y = xy(:,2)'; dy = (y(n2)-y(n1))/2; ay = (y(n2)+y(n1))/2;
    J2 = 2*(ax.*dy-ay.*dx);
for ie = 1:nn
    E0_l=G*((2*dx(ie))^2+(2*dy(ie))^2)/(6*J2(ie)) * [2 1;1 2];
    E1_l=G*((2*dx(ie))^2+(2*dy(ie))^2)/(12*J2(ie)) * [-1 1;1 -1] -G*(ax(ie)*dx(ie)*2+ay(ie)*dy(ie)*2)/(2*J2(ie)) * [-1 -1;1 1];
    E2_l=G*((2*dx(ie))^2+(2*dy(ie))^2+12*(ax(ie)^2+ay(ie)^2))/(12*J2(ie))*[1 -1;-1 1];
    M0_l=density*J2(ie)/6 * [2 1;1 2];

    d = dof(:,ie);
    E0(d,d)=E0(d,d)+E0_l;
    E1(d,d)=E1(d,d)+E1_l;
    E2(d,d)=E2(d,d)+E2_l;
    M0(d,d)=M0(d,d)+M0_l;
end
%% stiffness matrix
%m = E0\[E1' -eye(nd)]; Z = [m; E1*m(:,id)-E2 -m(:,id)'];
Z=[E0^-1*E1' -E0^-1;-E2+E1*E0^-1*E1' -E1*E0^-1];
[v, d] = eig(Z);  lambda = diag(d);
[~, idx] = sort(real(lambda),'ascend'); %sort eignvalues in ascending order
lambda = lambda(idx(id))';  v = v(:, idx(id)); %rearrange eigenvalues and eigenvectors
lambda(end) = 0;  v(:,end) = 0;%rigid body translational modes
v(1:nd,end)=ones(nd,1);
v11 = v(id, :); v11inv = inv(v11);
Kb  = real(v(nd+id, :)*v11inv);%stiffness matrix
%% mass matrix; 
M0 = v11'*M0*v11;
am = lambda(ones(1,nd),:); 
M0 = M0./(2-am-am'); 
Mb = real(v11inv'*M0*v11inv);
%% self-weight
p = real(g*Mb*v11(:,end));

end
