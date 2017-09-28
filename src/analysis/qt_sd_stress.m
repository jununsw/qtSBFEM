function [ eleStrs, eleResult, eleStrsNode] = qt_sd_stress(sdSln, U, QTEle, ele, eleQT, eleSize, eleMat, mat)

nStrComp = 5;
eleStrs = zeros(nStrComp,length(ele));
eleStrsNode = cell(length(ele),1);
eleResult = cell(length(ele),1);
nMat = length(mat);
% nNode = size(coord,1);
% nodalStrs = zeros(nNode,nStrComp);
% eleCnt = zeros(nNode,1);
for jj = 1:6
    cEle = find(eleQT(:,1)==jj);
    strLSFit = QTEle{jj}.strLSFit;
    nENode = size(QTEle{jj}.xy,1);
    xy1 = [ones(nENode,1) QTEle{jj}.xy];
    for ii = 1:nMat
        D = mat{ii}.D;
        if mat{ii}.phantom == 1; D = 0; end;
        mcEle = cEle(eleMat(cEle)==ii);
        strnMode = QTEle{jj}.strnMode(:,:,:,ii);
        vinv = QTEle{jj}.vinv(:,:,:,ii);
%        v = QTEle{jj}.v(:,:,:,ii);
        for ie = mcEle'
            kk = eleQT(ie,2);
            eNode  = ele{ie};
            NodalDisp = U(:,eNode); NodalDisp = NodalDisp(:)/(eleSize(ie)/2);
            c = vinv(:,:,kk)*NodalDisp;
%            eleResult{ie}.centreDisp = real(c(nDof-1:nDof));
            strn = real([ strnMode(1:3,end-3:end,kk)*c(end-5:end-2); ... %stress at scaling centre
                strnMode(:,:,kk)*c(1:end-2) ]); %stress  on boundary
            strn=reshape(strn,3,[]);
            strs = D*strn;
            avgs = (strs(1,:)+strs(2,:))/2;
%             rs = sqrt(avgs.^2+0.25*strs(3,:).^2);
            rs = sqrt(strs(3,:).^2+0.25*(strs(1,:)-strs(2,:)).^2);
            strs = [strs; avgs+rs; avgs-rs];
            eleStrs(:,ie) = strs(:,1);
            eleResult{ie}.strn = strn;
            eleResult{ie}.strs = strs;
            ndstrs = xy1*(strLSFit*strs(:,2:end)');
%            eleResult{ie}.strsNode = (xy1*strsIntpCoe)';
            eleStrsNode{ie} = ndstrs;
%             nodalStrs(eNode,:) = nodalStrs(eNode,:) + ndstrs;
%             eleCnt(eNode) = eleCnt(eNode) + 1;
        end
    end
end


% deal with cut-elements
ceid = find(eleQT(:,1)==0);
for jj = 1:length(ceid)
    cid = ceid(jj);
    
    xy       = sdSln{cid}.xy; 
    strLSFit = sdSln{cid}.strLSFit;
    strnMode = sdSln{cid}.strnMode;
    vinv     = sdSln{cid}.vinv;
    D        = mat{eleMat(cid)}.D;
    nENode   = numel(ele{cid});
    
    xy1 = [ones(nENode,1) xy];
        
    eNode  = ele{cid};
    NodalDisp = U(:,eNode); 
    c = vinv*NodalDisp(:);
    strn = real([ strnMode(1:3,end-3:end)*c(end-5:end-2); ... %stress at scaling centre
                  strnMode*c(1:end-2) ]); %stress  on boundary
    strn = reshape(strn,3,[]);
    strs = D*strn;
    avgs = (strs(1,:)+strs(2,:))/2;
    rs = sqrt(strs(3,:).^2+0.25*(strs(1,:)-strs(2,:)).^2);
    strs = [strs; avgs+rs; avgs-rs];
    eleStrs(:,cid) = strs(:,1);
    eleResult{cid}.strn = strn;
    eleResult{cid}.strs = strs;
    ndstrs = xy1*(strLSFit*strs(:,2:end)');
    eleStrsNode{cid} = ndstrs;

end

end



