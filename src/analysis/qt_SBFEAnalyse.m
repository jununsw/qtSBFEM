function [sdSln, U, varargout] = qt_SBFEAnalyse(cntrl, QTEle, coord, ele, eleCentre, eleQT, eleSize,  ...
    eleMat, mat, g, bc_force, bc_disp, Ndof)
%  part 1: assemable global stiffness and mass matrices
%  part 2: analysis can be statics, time domain or modal analysis
if strncmpi(cntrl.prbtdm.type, 'STATICS', 3)

    [ sdSln, K, rhs] = qt_assemble(QTEle, coord, ele, ...
                           eleCentre, eleQT, eleSize, eleMat, mat, g, Ndof);
    
    [U, varargout{1}] = static_solver(Ndof, bc_force, bc_disp, K, rhs);
    % elseif strncmpi(cntrl.prbtdm.type, 'modal', 3)
    %     [varargout{1} varargout{2}] = modes_solver(cntrl.prbtdm.modalPara(1), ndn, bc_disp, K, M);
% elseif strncmpi(cntrl.prbtdm.type, 'TIME', 3)
%     [ K, rhs, M] = AssembleQuadtreeMesh(QTEle,...
%     coord, ele,  eleQT, eleSize, eleDof, eleMat, mat,Ndof ,cutele);                   %moved here CB 08.01.2014 - low-order mass matrix
%     
%     if strncmpi(cntrl.phyprb, 'ELASTICITY', 3)
%     [varargout{1}] = tm_newmark(cntrl.prbtdm.TIMEPara,cntrl.prbtdm.forceHistory ...
%         , Ndof, bc_force, bc_disp, K, M, rhs);
%     elseif strncmpi(cntrl.phyprb, 'DIFFUSION', 3)
%     [varargout{1}] = tm_TimeInt(cntrl.prbtdm.TIMEPara,cntrl.prbtdm.forceHistory ...
%         , Ndof, bc_force, bc_disp, K, M, rhs);
%     end
%     U=0;
% elseif strncmpi(cntrl.prbtdm.type, 'MODAL', 3)
%     [ K, ~, M ] = AssembleQuadtreeMesh(QTEle,...                              
%     coord, ele,  eleQT, eleSize, eleDof, eleMat, mat,Ndof ,cutele);
%     [varargout{1}.Freq, varargout{1}.Shape] = modes_solver(cntrl.prbtdm.modalPara(1), Ndof, bc_disp, K, M);
%     U=0;
else
    assert(0);
end



end


