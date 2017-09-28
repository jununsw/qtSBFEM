function [ sdSln, K, rhs, M] = qt_assemble(QTEle, coord, ele, eleCentre,...
    eleQT, eleSize, eleMat, mat, g, Ndof)
% assemble quadtree mesh
assert(Ndof == 2);
sdSln = cell(length(ele),1);

nNode = size(coord,1);
rhs = zeros(Ndof*nNode,1);  %external load vector
eNDof = Ndof*cellfun(@length,ele); % # of DOFs per element
femi = zeros(sum(eNDof.^2),1); femj=femi; femk=femi; femm = femi;
index = 0;

% deal with elements matching patters (QTEle)
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
            eDof = [ftmp-1;ftmp];

            eDof = eDof(:);
            I = eDof(:,ones(1,NDof)); J=I';
            ncoe = NDof*NDof;
            kk = eleQT(el,2);
            femi(index+1:index+ncoe) = I(:);
            femj(index+1:index+ncoe) = J(:);
            femk(index+1:index+ncoe) = mcQTEleStff(:,:,kk);
            s = (eleSize(el)/2)^2;
            femm(index+1:index+ncoe) = s*mcQTEleMass(:,:,kk);
            
            rhs(eDof) = rhs(eDof) + s*mcQTEleSelfw(:,kk);
    
            sdSln{el} = struct('xy',  QTEle{jj}.xy, ...
                         'strLSFit',  QTEle{jj}.strLSFit, ...
                         'strnMode',  QTEle{jj}.strnMode(:,:,kk,ii), ...
                             'vinv',  QTEle{jj}.vinv(:,:,kk,ii)); 

            index = index + ncoe;

        end
    end  
end

% deal with cut-elements
ceid = find(eleQT(:,1)==0);
for jj = 1:length(ceid)
    cid = ceid(jj);
    xy = bsxfun(@minus,coord(ele{cid},:), eleCentre(cid,:));
    nNode = size(xy,1);
    Conn = [1:nNode; 2:nNode 1];
    em   = mat{eleMat(cid)};
    
    [stff, lambda, v, vinv, mass, selfw, strnMode] ...
        =   getSBFEMStiffMat_2NodeEle_2D( xy, Conn, em.D, em.density, g);
    
    % assembling
    ftmp = Ndof*ele{cid};
    eDof = [ftmp-1;ftmp];
    eDof = eDof(:);
    numDof = numel(eDof);
    I = eDof(:,ones(1,numDof)); J=I';
    
    ncoe = numDof*numDof;
    femi(index+1:index+ncoe) = I(:);
    femj(index+1:index+ncoe) = J(:);
    femk(index+1:index+ncoe) = stff(:);
    femm(index+1:index+ncoe) = mass(:);
    rhs(eDof) = rhs(eDof) + selfw(:);
    
    sp = [ones(nNode,1) (xy+[xy(2:end,:); xy(1,:)])/2];
    strLSFit = (sp'*sp)\sp';
    sdSln{cid} = struct('xy',  xy,  ...
                  'strLSFit',  strLSFit, ...
                  'strnMode',  strnMode, ...
                      'vinv',  vinv); 
    
    index = index + ncoe;
end

%%
K = sparse(femi,femj, femk);
K = (K+K')/2;

if nargout >3
    M = sparse(femi,femj, femm);
    M = (M+M')/2;
end

%clear femi  femj;

end



