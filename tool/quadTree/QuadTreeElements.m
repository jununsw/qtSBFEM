function [ QTEle ] = QuadTreeElements( mat, g,Ndof, coord, ele,cutele)
% compute quadtree elements for all materials
QTEle{1}.xy = [-1 -1; 1 -1; 1 1; -1 1];%4-node
QTEle{2}.xy = [-1 -1; 0 -1; 1 -1; 1 1; -1 1]; %5-node
QTEle{3}.xy = [-1 -1; 0 -1; 1 -1; 1 0; 1 1; -1 1]; %6-node with adjacent mid-nodes
QTEle{4}.xy = [-1 -1; 0 -1; 1 -1; 1 1; 0 1; -1 1]; %6-node with oppositing mid-nodes
QTEle{5}.xy = [-1 -1; 0 -1; 1 -1; 1 0; 1 1; 0 1; -1 1];%7-node
QTEle{6}.xy = [-1 -1; 0 -1; 1 -1; 1 0; 1 1; 0 1; -1 1; -1  0 ];%8-node
% QTEle{7}.xy = [-2/3 -1/3; 1/3 -1/3; 1/3 2/3];%Triangle 3-node
% QTEle{8}.xy = [-2/3 -1/3; -1/6 -1/3; 1/3 -1/3; 1/3 2/3];%Triangle 4-node
% QTEle{9}.xy = [-2/3 -1/3; 1/3 -1/3; 1/3 1/6; 1/3 2/3];%Triangle 4-node
% QTEle{10}.xy = [-2/3 -1/3; -1/6 -1/3; 1/3 -1/3; 1/3 1/6; 1/3 2/3];%Triangle 5-node
%% the followings compute new element types
% etype=cell(100,1);

% ro=[0 1;-1 0];
% for i=length(ele)-length(cutele)+1:length(ele) % all elements must be cut, and hence must be new types
%     
%     xy=coord(ele{i},:);
%     cenxy=[(max(xy(:,1))+min(xy(:,1)))/2, (max(xy(:,2))+min(xy(:,2)))/2];
%     repmxy=repmat(cenxy,length(xy),1);
%     xydm=xy-repmxy;
%     if any(mod(xydm,1))~=[0 0]
%         [~,dm]=numden(sym(xydm));
%         dm=double(dm);
%         dm=unique(dm(:));
%         cm=dm(1);
%         for z=2:length(dm)
%             cm=lcm(cm,dm(z));
%         end
%         xydm=xydm*cm;
%     end
%     txy=round(xydm(:));
%     cf=txy(1);
%     for z=2:length(txy)
%         cf=gcd(cf,txy(z));
%     end
%     trt=round(xydm/cf);
%     if i==length(ele)-length(cutele)+1
%         etype{1}=trt;
%     else
%         for h=1:length(etype)
%             if isempty(etype{h})
%                 h=h-1;
%                 break
%             end
%         end
%         
%         for ii=1:h
%             typend=etype{h};
%             if length(typend)~=length(etype)
%                 oldtype=0;
%                 continue
%             else
%                 if trt==typend
%                     oldtype=1;
%                     break
%                 elseif trt*ro==typend
%                     oldtype=1;
%                     break
%                 elseif trt*ro*ro==typend
%                     oldtype=1;
%                     break
%                 elseif trt*ro*ro*ro==typend
%                     oldtype=1;
%                     break
%                 else
%                     oldtype=0;
%                 end
%             end
%         end
%         if oldtype==0
%             etype{h+1}=trt;
%         end
%     end
% end
% 
% etype=etype(~cellfun('isempty',etype));
% 
% for iii=1:length(etype)
%     QTEle{6+iii}.xy=etype{iii};
% end

%%
nMat = length(mat);
for jj = 1:6
    xy = QTEle{jj}.xy(:,1:2); 
    nNode = size(xy,1);
    Conn = [1:nNode; 2:nNode 1];
    if Ndof==2
        nDof = nNode+nNode;
        strnMode = zeros(3*size(Conn,2),nDof-2,4,nMat);
        sp = [ones(nNode,1) (xy+[xy(2:end,:); xy(1,:)])/2];
        QTEle{jj}.strLSFit = (sp'*sp)\sp';
        selfw = zeros(nDof,4,nMat);
    elseif Ndof==1
        nDof = nNode;
    end

    stff = zeros(nDof,nDof,4,nMat);
    mass = zeros(nDof,nDof,4,nMat);
    lambda = zeros(nDof,4,nMat);
    v = zeros(nDof,nDof,4,nMat);
    vinv = zeros(nDof,nDof,4,nMat);
    
   
    for kk = 1:4
        for ii = 1:nMat;
            if Ndof==2 %vector case
                [stff(:,:,kk,ii), lambda(:,kk,ii), v(:,:,kk,ii), vinv(:,:,kk,ii),...
                    mass(:,:,kk,ii), selfw(:,kk,ii), strnMode(:,:,kk,ii) ] ...
                =   getSBFEMStiffMat_2NodeEle_2D( xy, Conn, mat{ii}.D, mat{ii}.density, g);
            elseif Ndof==1 %scalar case
                [stff(:,:,kk,ii), lambda(:,kk,ii), v(:,:,kk,ii), vinv(:,:,kk,ii),...
                    mass(:,:,kk,ii)] = getSBFEMStiffMat_2NodeEle_1D( xy, Conn, mat{ii}.G, mat{ii}.mu, g);
                selfw(:,kk,ii) = 0;
            end
        end
        if mat{ii}.phantom == 1; 
            stff(:,:,kk,ii) = (1.d-12)*stff(:,:,kk,ii); 
            mass(:,:,kk,ii) = (1.d-10)*mass(:,:,kk,ii); 
            selfw(:,kk,ii) = 0;
        end;

        xy = xy*[0 1; -1 0]; %rotate the element by 90deg
    end
    QTEle{jj}.stff = stff;
    QTEle{jj}.lambda = lambda;
    QTEle{jj}.v = v;
    QTEle{jj}.vinv = vinv;
    QTEle{jj}.mass = mass;
    QTEle{jj}.selfw = selfw;
    if Ndof==2
        QTEle{jj}.strnMode = strnMode;
    end
end
%% added 17th Apr
for jj=7:(6+length(cutele))
    xy=coord(ele{length(ele)-length(cutele)+jj-6},:);
    cenxy=mean(xy);
    repmxy=repmat(cenxy,length(xy),1);
    xy=xy-repmxy;
    QTEle{jj}.xy=xy;
 
    nNode = size(xy,1);
    Conn = [1:nNode; 2:nNode 1];
    if Ndof==2
        nDof = nNode+nNode;
        strnMode = zeros(3*size(Conn,2),nDof-2,4,nMat);
        sp = [ones(nNode,1) (xy+[xy(2:end,:); xy(1,:)])/2];
        QTEle{jj}.strLSFit = (sp'*sp)\sp';
        selfw = zeros(nDof,4,nMat);
    elseif Ndof==1
        nDof = nNode;
    end

    stff = zeros(nDof,nDof,4,nMat);
    mass = zeros(nDof,nDof,4,nMat);
    lambda = zeros(nDof,4,nMat);
    v = zeros(nDof,nDof,4,nMat);
    vinv = zeros(nDof,nDof,4,nMat);
    
   
    kk=1;
        for ii = 1:nMat;
            if Ndof==2 %vector case
                [stff(:,:,kk,ii), lambda(:,kk,ii), v(:,:,kk,ii), vinv(:,:,kk,ii),...
                    mass(:,:,kk,ii), selfw(:,kk,ii), strnMode(:,:,kk,ii) ] ...
                =   getSBFEMStiffMat_2NodeEle_2D( xy, Conn, mat{ii}.D, mat{ii}.density, g); % element %%%!!!!! Yan
            elseif Ndof==1 %scalar case
                [stff(:,:,kk,ii), lambda(:,kk,ii), v(:,:,kk,ii), vinv(:,:,kk,ii),...
                    mass(:,:,kk,ii)] = getSBFEMStiffMat_2NodeEle_1D( xy, Conn, mat{ii}.G, mat{ii}.mu, g);
                selfw(:,kk,ii) = 0;
            end
        end
        if mat{ii}.phantom == 1; 
            stff(:,:,kk,ii) = (1.d-12)*stff(:,:,kk,ii); 
            mass(:,:,kk,ii) = (1.d-10)*mass(:,:,kk,ii); 
            selfw(:,kk,ii) = 0;
        end;

    
    
    QTEle{jj}.stff = stff;
    QTEle{jj}.lambda = lambda;
    QTEle{jj}.v = v;
    QTEle{jj}.vinv = vinv;
    QTEle{jj}.mass = mass;
    QTEle{jj}.selfw = selfw;
    if Ndof==2
        QTEle{jj}.strnMode = strnMode;
    end
    
   
    
end
end

