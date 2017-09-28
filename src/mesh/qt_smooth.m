function [newcoord, inter2coord] = qt_smooth ...
         (intercoord, interface, inter2edge, edge2inter, coord, meshEdge, edge2sd, sd2qt, S, eps, opts)
% smooth interfaces, eps must less than 0.25
% opts(1) = project to the curve
% opts(2) = round to 1/(2^n) points

ptdist = @(a,b) sqrt(sum((a-b),2).^2);
    
inter2coord   = zeros(size(inter2edge));
ptsoncurve    = zeros(size(intercoord));
    
%% smooth interface
for i=1:length(interface)
    curve    = interface{i};
%     if(length(curve) < 8)
%         continue;
%     end
    
    cxy      = intercoord(curve,:);
    cxy(:,1) = smooth(cxy(:,1),7,'sgolay');
    cxy(:,2) = smooth(cxy(:,2),7,'sgolay');
    if(curve(1)==curve(end))
        if(inter2edge(curve(1)) == 0)
            cxy(1,:)     = intercoord(curve(1),:);
            cxy(end,:)   = intercoord(curve(1),:);
        else
            cxy(1,:)   = (cxy(1,:)+cxy(end,:))/2;
            cxy(end,:) = cxy(1,:); 
            cxy        = [cxy;cxy(2,:)];
            curve      = [curve;curve(2)];
        end
    else
        cxy(1,:)     = intercoord(curve(1),:);
        cxy(end,:)   = intercoord(curve(end),:);
    end
    
%     figure
%     hold on;
%     axis equal; 
%     plot(cxy(:,1),cxy(:,2),'-+');

    %update 
    newcurvecoord = intercoord(curve,:);
    for j=2:length(curve)-1
        edgenode = meshEdge(inter2edge(curve(j)),:);
        edg1 = coord(edgenode(1),:);
        edg2 = coord(edgenode(2),:);
        edge = [edg1 edg2];
        
        xy1  = cxy(j-1,:);
        xy2  = cxy(j,:);
        xy3  = cxy(j+1,:);
        curv = [xy1, xy2; xy2, xy3];
        newinter = lineSegmentIntersect(edge, curv);
        
        % get intersection point
        if(any(newinter.intAdjacencyMatrix))
            ix  = newinter.intMatrixX(newinter.intAdjacencyMatrix);
            iy  = newinter.intMatrixY(newinter.intAdjacencyMatrix);
            ixy = [ix(1),iy(1)];
        else
            %check edge ends
            imageps = 0.01;
            curv = [xy1; xy2; xy3];
            [~,edis,~] = distance2curve(curv, coord(edgenode(:),:), 'linear');
            cnode = edgenode(edis<imageps);
            if(~isempty(cnode))
                ixy = coord(cnode,:);
            else
%                 figure
%                 hold on;
%                 plot([edg1(1),edg2(1)],[edg1(2),edg2(2)],'-o');
%                 plot(cxy(j-1:j+1,1),cxy(j-1:j+1,2),'-+');
%                 assert(0) %check this before running
                ixy = intercoord(curve(j),:);
            end
        end
        
        if(opts(2))
            % round the point to 1/(2^n) points by eps
            assert(inter2edge(curve(j))>0);
            step = max(S(sd2qt(edge2sd{inter2edge(curve(j))}))) * eps;
            dist = round(ptdist(ixy,edg1)/step)*step;
            ixy  = edg1 + (edg2-edg1)/ptdist(edg1,edg2)*dist;
            edgdis = [ptdist(ixy, edg1),ptdist(ixy,edg2)];
            minode = edgenode(edgdis<0.001); %image eps
        else
            % round the point to edge ends by eps
            assert(inter2edge(curve(j))>0);
            mindis = max(S(sd2qt(edge2sd{inter2edge(curve(j))}))) * eps;
            edgdis = [ptdist(ixy, edg1),ptdist(ixy,edg2)];
            minode = edgenode(edgdis<mindis);
        end
        
        if(~isempty(minode))
            inter2coord(curve(j))    = minode;
            curv = [xy1; xy2; xy3];
            [cpt,~,~] = distance2curve(curv, coord(minode,:), 'linear');
            ptsoncurve(curve(j),:) = cpt; 
        else
            newcurvecoord(j,:)= ixy;
        end
    end
    intercoord(curve(2:end-1),:) = newcurvecoord(2:end-1,:); 
end

%% smooth border
border = arrayfun(@(a,b)length(a{1})==1 && edge2inter(b)>0, edge2sd, (1:length(edge2sd))');
bnodei = edge2inter(border);
if(~isempty(bnodei))
    edgend = meshEdge(border,:);
    bcoordi = intercoord(bnodei,:);
    bcoord1 = coord(edgend(:,1),:);
    bcoord2 = coord(edgend(:,2),:);
    if(opts(2))
        % round the point to 1/(2^n) points by eps
        edgelen = S(sd2qt([edge2sd{border}]));
        step = edgelen * eps;
        dist = round(ptdist(bcoordi,bcoord1)./step).*step;
        bnor = bsxfun(@rdivide, (bcoord2-bcoord1), edgelen);
        bcoordi = bcoord1 + bsxfun(@times, bnor, dist);
        edgdis = [ptdist(bcoordi, bcoord1),ptdist(bcoordi,bcoord2)];
        minode = bsxfun(@lt, edgdis, [0.001,0.001]); %image eps
    else
        % round the point to edge ends by eps
        mindist = S(sd2qt([edge2sd{border}])) * eps;
        edgdis = [ptdist(bcoordi, bcoord1),ptdist(bcoordi,bcoord2)];
        minode = bsxfun(@lt, edgdis, mindist);
    end
    intercoord(bnodei,:) = bcoordi;
    edgend = edgend';
    inter2coord(bnodei(any(minode,2))) = edgend(minode');
end

% fill newcoord and further update inter2coord
newcoord    = [coord;intercoord(~inter2coord,:)];
if(opts(1)>0)
    newcoord(inter2coord(inter2coord>0),:) = ptsoncurve(inter2coord>0,:);
end
inter2coord(~inter2coord) = length(coord) + [1:length(inter2coord(~inter2coord))]';

end

