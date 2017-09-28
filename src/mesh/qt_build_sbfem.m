function [coord, ele, eleQT, eleColor, eleSize, eleCentre] = qt_build_sbfem ...
         (polycoord, polyconn, inter2coord, poly2sd, sdhnode, sd2inter, sd2qt, qtcoord, S, I)
%build variables for sbfem

% ptdist = @(a,b) sqrt(sum((a-b),2).^2);

nodemark = false(length(polycoord),1);
nodemark(inter2coord) = 1;

coord     = polycoord;
ele       = polyconn; % this variable will be updated in the following codes

polySid   = find(poly2sd>0);
polyPid   = find(poly2sd<0);
assert(length(polySid)+length(polyPid) == length(poly2sd));

%eleSize
eleSize = zeros(length(poly2sd),1);
eleSize(polySid) = S(sd2qt(poly2sd(polySid)));
% eleSize(polyPid) = cellfun(@(a)polygonsize(coord(a,:)), ele(polyPid));
%     function size = polygonsize(pts)
%         npt = length(pts);
%         esize = zeros(npt,1);
%         esize(1:(npt-1)) = arrayfun(@(a) ptdist(pts(a,:), pts(a+1,:)), 1:(npt-1));
%         esize(npt) = ptdist(pts(end,:), pts(1,:));
%         size = mean(esize,1);
%     end

%update polySid and polyPid by boundary marks
phonyS  = cellfun(@(a) any(nodemark(a)), ele(polySid));
polyPid = [polyPid;polySid(phonyS)];
polySid = polySid(~phonyS);

%eleColor
I = [I,I(:,end)]; %increase one more colum
I = [I;I(end,:)]; %increase one more row
nodecolor = -ones(length(coord),1);
nodecolor(1:length(qtcoord)) = I(sub2ind(size(I),qtcoord(:,1), qtcoord(:,2)));

nsd = length(ele);
eleColor = -ones(nsd,1);
eleColor(polySid) = cellfun(@(a) I(coord(a(1),1), coord(a(1),2)), ele(polySid));
eleColor(polyPid) = cellfun(@(a) polygoncolor(a), ele(polyPid));
    function color = polygoncolor(nds)
        inode = nds(~(nodemark(nds)));
        if(~isempty(inode))
            color = nodecolor(inode(1));
        else
            ncolor = nodecolor(nds);
            ncolor = ncolor(ncolor>=0);
            if(~isempty(ncolor))
                color = ncolor(1);
            else
                assert(0); % confirm it before running
                ncenter = floor(mean(coord(nds,:),1));
                color = I(ncenter(1), ncenter(2));
            end
        end
    end

%eleQT
% 4----3
% |    |
% 1----2
% Second part of loop: re-ordering the nodes and determine type of quadtree
% mesh There are 6 types of square and 4 types of orientations

% type 1: 4 nodes. Type 2: 5 nodes. Type 3: 6 nodes (2 hanging nodes on 2
% adjacent sides except the combination when they are at south and west side. 
% Type  4: 6 nodes ( 2 hanging nodes on opposite sides). Type 5: 7 nodes.
% Type 6: 8 nodes.

% Node ordering rule: Numbering them in counter clockwise direction.
% the first hanging node encounter in that direction becomes local node 2

% Determine orientation as the second argument of qtType. 1 = South
% side, 2 = East side, 3 = North side, 4 = West side

eleQT = mat2cell(zeros(length(ele),2), ones(length(ele),1));
cellSid = mat2cell(polySid, ones(length(polySid),1));
eleQT(polySid) = cellfun(@getype, cellSid, ele(polySid), sdhnode(poly2sd(polySid)), 'Un', 0);
    function qtype = getype(pid, nodes, hmarks)
        nn = length(nodes);
        if(nn == 4)
            qtype = [1,1];return;
        end
        if(nn == 8)
            qtype = [6,1];return;
        end
        senw = zeros(nn,1); senw(~hmarks) = 1:4;
        senw(hmarks)  = senw(find(hmarks)-1);
        senw(~hmarks) = 0;
        pos = 1;
        if(nn == 5)
            qtype = [2,senw(hmarks)]; pos = find(hmarks,1)-1;
        elseif(nn == 6)
            if(all(hmarks == [0 1 0 0 1 0]))
                qtype = [4,1]; 
            elseif(all(hmarks == [0 0 1 0 0 1]))
                qtype = [4,2]; pos = 2;
            else
                fsth = strfind([hmarks,hmarks(1:2)],[1 0 1]);
                qtype = [3,senw(fsth)]; pos = fsth-1;
            end
        else %nn==7
            fsth = strfind([hmarks,hmarks(1)],[0 0]);
            pos  = mod(fsth,7)+1;
            fsth = pos+1;
            qtype = [5,senw(fsth)]; 
        end
        ele{pid} = [nodes(pos:end),nodes(1:pos-1)];
    end
eleQT = cell2mat(eleQT);

%% calculate scaling centre for polygon subdomain
nodemark                                    = false(length(polycoord),1);
nodemark(inter2coord(sd2inter(sd2inter>0))) = 1;
eleCentre = zeros(length(ele), 2);
% polyCentre = cellfun(@(a) mean(coord(a,:),1), ele(polyPid), 'Un', 0);
for i=1:length(polyPid)
    pid = polyPid(i);
    loc = find(nodemark(ele{pid}));
    if isempty(loc)
        eleCentre(pid,:) = mean(coord(ele{pid},:),1);
        continue;
    end
    assert(length(loc)==1);
    ncoord = coord(ele{pid},:);
    nnum   = length(ncoord);
    pt1 = ncoord(mod(nnum+loc-2, nnum)+1,:);
    pt2 = ncoord(loc,:);
    pt3 = ncoord(mod(nnum+loc, nnum)+1,:);
    
    vec = cross([pt2-pt1,0], [pt3-pt2,0]);
    if(vec(3) >= 0)
        eleCentre(pid,:) = mean(ncoord,1);
        continue;
    end
    
    bis = normr(pt1-pt2) + normr(pt3-pt2);
    bis = -normr(bis);
    nodeloc = true(nnum,1);
    nodeloc(loc)                     = 0;
    nodeloc(mod(nnum+loc-2, nnum)+1) = 0;
    nodeloc(mod(nnum+loc, nnum)+1)   = 0;
    vec = bsxfun(@minus, ncoord(nodeloc,:), ncoord(loc,:));
    vec = normr(vec);
    ang = bis*vec';
    [~,mid] = max(ang);
    vcoord = ncoord(nodeloc,:);
    eleCentre(pid,:) = (vcoord(mid,:)+ncoord(loc,:))/2;
end

% eleCentre(polyPid) = cell2mat(polyCentre);

%adjust ele order and output
% ele        = [ele(polySid);ele(polyPid)];
% cutele     = ele(polyPid);
% eleQT      = [eleQT(polySid,:);eleQT(polyPid,:)];
% eleColor   = [eleColor(polySid);eleColor(polyPid)];
% eleSize    = [eleSize(polySid);eleSize(polyPid)];
% eleCentre  = [eleCentre(polySid,:);eleCentre(polyPid,:)];
% eleDof     = [eleDof(polySid);eleDof(polyPid)];

end %end of qt_build_sbfem


