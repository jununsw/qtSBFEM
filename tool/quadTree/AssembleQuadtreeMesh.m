function [ K, rhs, M] = AssembleQuadtreeMesh(QTEle, coord, ele, ...
    eleQT, eleSize, eleDof, eleMat, mat,Ndof,cutele)
% assemble quadtree mesh
nNode = size(coord,1);
rhs = zeros(Ndof*nNode,1);  %external load vector
eNDof = Ndof*cellfun(@length,ele); % # of DOFs per element
femi = zeros(sum(eNDof.^2),1); femj=femi; femk=femi; femm = femi;
index = 0;
%for el = 1:length(ele)
nMat = max(eleMat);
for jj = 1:6
    cEle = find(eleQT(:,1)==jj);
    for ii = 1:nMat
        mcEle = cEle(eleMat(cEle)==ii);
        mcQTEleStff = QTEle{jj}.stff(:,:,:,ii);
        mcQTEleMass = QTEle{jj}.mass(:,:,:,ii);
        mcQTEleSelfw = QTEle{jj}.selfw(:,:,ii);

        for el = mcEle'
%             NDof = eNDof(el);
%             eDof = eleDof{el};
            eNode = ele{el};
            NDof = eNDof(el);
            ftmp = Ndof*eNode;
            if Ndof == 1
                eDof = ftmp;
            elseif Ndof == 2
                eDof = [ftmp-1;ftmp];
            end
            eDof = eDof(:);
            I = eDof(:,ones(1,NDof)); J=I';
            ncoe = NDof*NDof;
            kk = eleQT(el,2);
            femi(index+1:index+ncoe) = I(:);
            femj(index+1:index+ncoe) = J(:);
            femk(index+1:index+ncoe) = mcQTEleStff(:,:,kk);
            s = (eleSize(el)/2)^2;
            femm(index+1:index+ncoe) = s*mcQTEleMass(:,:,kk);
            
            if Ndof ==2
                rhs(eDof) = rhs(eDof) + s*mcQTEleSelfw(:,kk);
            end

            index = index + ncoe;

        end
    end  
end
%% added 17th Apr
for jj=7:(6+length(cutele)) % all elements must be cut, and hence must be new types

        mcEle = length(ele)-length(cutele)+jj-6;
        ii=eleMat(mcEle);
        mcQTEleStff = QTEle{jj}.stff(:,:,:,ii);
        mcQTEleMass = QTEle{jj}.mass(:,:,:,ii);
        mcQTEleSelfw = QTEle{jj}.selfw(:,:,ii);

        el = mcEle;
%             NDof = eNDof(el);
%             eDof = eleDof{el};
            eNode = ele{el};
            NDof = eNDof(el);
            ftmp = Ndof*eNode;
            if Ndof == 1
                eDof = ftmp;
            elseif Ndof == 2
                eDof = [ftmp-1;ftmp];
            end
            eDof = eDof(:);
            I = eDof(:,ones(1,NDof)); J=I';
            ncoe = NDof*NDof;
            kk = 1;
            femi(index+1:index+ncoe) = I(:);
            femj(index+1:index+ncoe) = J(:);
            femk(index+1:index+ncoe) = mcQTEleStff(:,:,kk);
            s = (eleSize(el)/2)^2;
            femm(index+1:index+ncoe) = s*mcQTEleMass(:,:,kk);
            
            if Ndof ==2
                rhs(eDof) = rhs(eDof) + s*mcQTEleSelfw(:,kk);
            end

            index = index + ncoe;

        

end
    


%%
K = sparse(femi,femj, femk);
K = (K+K')/2;

if nargout >2
    M = sparse(femi,femj, femm);
    M = (M+M')/2;
end

%clear femi  femj;

end

