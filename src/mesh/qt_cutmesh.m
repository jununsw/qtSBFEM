function [newsdconn, poly2sd] =  qt_cutmesh...
         (sdconn, sdhnode, sdEdge, edge2inter, sd2inter, sdD2loc, inter2coord)
% cut mesh

sdEdgeL = cellfun(@(a)find(edge2inter(abs(a))>0), sdEdge, 'Un', 0); % broken edges
sdE2    = find(cellfun(@(a)length(a)==2, sdEdgeL));
sdG2    = find(sd2inter>0);
sdD2    = find(sdD2loc>0);

poly2sd   = find(cellfun(@isempty, sdEdgeL));
newsdconn = sdconn(poly2sd); %subdomain without any intersections
newsdpos  = length(newsdconn);
nmaxsd    = length(sdE2)*2 + length(sdG2)*8 + length(sdD2)*3;
newsdconn = [newsdconn; cell(nmaxsd, 1)];
poly2sd   = [poly2sd; zeros(nmaxsd,1)];

%%function for straight test
    function [lnode, ledge] = getline(sid)
        hnode  = sdhnode{sid};
        sdnode = sdconn{sid};  sdnode = [sdnode,sdnode(1)];
        corner = find(~hnode); corner = [corner,length(sdnode)];
        lnode  = arrayfun(@(a) sdnode(corner(a):corner(a+1)), 1:4, 'Un', 0);
        ledge  = arrayfun(@(a) abs(sdEdge{sid}(corner(a):(corner(a+1)-1))), 1:4, 'Un', 0);
    end
    function ison = isonline(cutedge, lnode, ledge)
        cutnode = inter2coord(edge2inter(cutedge));
        i1on    = cellfun(@(a,b) any(cutnode(1)==a)|any(cutedge(1)==b), lnode, ledge);
        i2on    = cellfun(@(a,b) any(cutnode(2)==a)|any(cutedge(2)==b), lnode, ledge);
        ison    = any(i1on & i2on);
    end

% deal with subdomain E2
nsd = length(sdE2);
for i = 1:nsd
    sid  = sdE2(i);
    eloc = sdEdgeL{sid};
    % straight test
    [lnode, ledge] = getline(sid);
    iedge = abs(sdEdge{sid}(eloc));
    ison = isonline(iedge, lnode, ledge);
    if(ison)
        elem = zeros(1,length(sdconn{sid})+2);
        elem(eloc+(1:2)') = inter2coord(edge2inter(iedge));
        elem(elem==0) = sdconn{sid};
        poly2sd(newsdpos + 1) = -sid;
        newsdconn{newsdpos+1} = uniquelem(elem); newsdpos = newsdpos + 1;
    else
        elem1 = [inter2coord(edge2inter(iedge(1))), ...
                 sdconn{sid}((eloc(1)+1):eloc(2)),...
                 inter2coord(edge2inter(iedge(2)))];
        elem2 = [inter2coord(edge2inter(iedge(2))), ...
                 sdconn{sid}((eloc(2)+1):end),...
                 sdconn{sid}(1:eloc(1)),...
                 inter2coord(edge2inter(iedge(1)))];
        poly2sd(newsdpos + (1:2)) = -sid;
        newsdconn{newsdpos+1} = uniquelem(elem1); newsdpos = newsdpos + 1;
        newsdconn{newsdpos+1} = uniquelem(elem2); newsdpos = newsdpos + 1;
    end
end 

% deal with subdomain D2
nsd = length(sdD2);
for i = 1:nsd
    sid   = sdD2(i);
    eloc  = sdEdgeL{sid}';
    segb  = sdD2loc(sid);
    eloc  = [eloc(segb:end), eloc(1:(segb-1))];
    eloc1 = [eloc(1), eloc(2)];
    eloc2 = [eloc(3), eloc(4)];
    % straight test
    [lnode, ledge] = getline(sid);
    iedge1 = abs(sdEdge{sid}(eloc1));
    ison1  = isonline(iedge1, lnode, ledge);
    iedge2 = abs(sdEdge{sid}(eloc2));
    ison2  = isonline(iedge2, lnode, ledge);
    
    eloc  = sdEdgeL{sid}';
    iedge = abs(sdEdge{sid}(eloc));
    elem = zeros(1,length(sdconn{sid})+4);
    eloc  = eloc+(1:4);
    elem(eloc) = inter2coord(edge2inter(iedge));
    elem(elem==0) = sdconn{sid};
    if(ison1 && ison2)
        poly2sd(newsdpos + 1) = -sid;
        newsdconn{newsdpos+1} = uniquelem(elem); newsdpos = newsdpos + 1;
    else
        eloc  = [eloc(segb:end),eloc(1:(segb-1))];
        inode1 = inter2coord(edge2inter(iedge1));
        inode2 = inter2coord(edge2inter(iedge2));
        if(inode1(2)>inode1(1)) inode1(1)=inode1(2); end
        if(inode2(2)>inode2(1)) inode2(1)=inode2(2); end
        isoverlap = all(inode1==inode2);
        if(xor(ison1, ison2) || isoverlap)
            if(ison1)
                eloc = [eloc(3),eloc(4)];
            else
                eloc = [eloc(1),eloc(2)];
            end
            if(eloc(1)>eloc(2)) eloc=[eloc(2),eloc(1)]; end
            elem1 = elem(eloc(1):eloc(2));
            elem2 = [elem(eloc(2):end),elem(1:eloc(1))];
            poly2sd(newsdpos + (1:2)) = -sid;
            newsdconn{newsdpos+1} = uniquelem(elem1); newsdpos = newsdpos + 1;
            newsdconn{newsdpos+1} = uniquelem(elem2); newsdpos = newsdpos + 1;
        else
            elem1 = getsegnodes(elem, eloc(1), eloc(2));
            elem2 = [getsegnodes(elem, eloc(2), eloc(3)), getsegnodes(elem, eloc(4), eloc(1))];
            elem3 = getsegnodes(elem, eloc(3), eloc(4));
            poly2sd(newsdpos + (1:3)) = -sid;
            newsdconn{newsdpos+1} = uniquelem(elem1); newsdpos = newsdpos + 1;
            newsdconn{newsdpos+1} = uniquelem(elem2); newsdpos = newsdpos + 1;
            newsdconn{newsdpos+1} = uniquelem(elem3); newsdpos = newsdpos + 1;
        end
    end
end 

% deal with subdomain G2
nsd = length(sdG2);
for i = 1:nsd
    sid  = sdG2(i);
    eloc = sdEdgeL{sid};
    elem = zeros(1,length(sdconn{sid})+length(eloc));
    iloc = eloc+(1:length(eloc))';
    elem(iloc)    = inter2coord(edge2inter(abs(sdEdge{sid}(eloc))));
    elem(elem==0) = sdconn{sid};
    elem = [elem(iloc(1):end), elem(1:(iloc(1)-1)), elem(iloc(1))];
    iloc = [iloc-iloc(1)+1; length(elem)];
    inode = inter2coord(sd2inter(sid));
    nnsd = length(iloc)-1;
    poly2sd(newsdpos + (1:nnsd)) = -sid;
    for j = 1:nnsd
        newsd = uniquelem([inode, elem(iloc(j):iloc(j+1))]);
        if(length(newsd) < 3)
            continue;
        end
        newsdconn{newsdpos + 1} = newsd; newsdpos = newsdpos + 1;
    end
end

newsdconn = newsdconn(1:newsdpos);
poly2sd   = poly2sd(1:newsdpos);

end % end of qt_cutmesh

function newelem = uniquelem(elem)
    emark   = [elem(end),elem];
    emark   = emark(2:end)~=emark(1:end-1);
    newelem = elem(emark);
    assert(all(newelem>0));
%     assert(length(newelem)>=3);
%     assert(length(newelem)<9);
end

function snodes = getsegnodes(nodes, sb, se)
    if(sb > se)
        snodes = [nodes(sb:end),nodes(1:se)];
    else
        snodes = nodes(sb:se);
    end
end

