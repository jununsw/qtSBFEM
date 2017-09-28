function [newintercoord, inter2edge, sd2inter, sdD2loc, interface] = qt_collect_interface...
         (intercoord, inter2edge, edge2inter, nodecolor, sdconn,sdEdge, sd2qt, S)
% Material interfaces are collected by this function
% If inter2edge(i) equals 0, it means the point is inserted in the domain
% center.

sdinterOrg = cellfun(@(a)edge2inter(abs(a)), sdEdge, 'Un', 0);
sdinter    = cellfun(@(a)a(a>0), sdinterOrg, 'Un', 0); %contains intersection indexes

%domain with two intersections (E2)
segmentsE2  = sdinter(cellfun(@(a)length(a)==2, sdinter)); 

%domain with more than two intersections and the number of intersections
%equals the number of node colors (G2)
sdG2 = cellfun(@(a)length(a)>2, sdinter);
sdD2 = cellfun(@(a,b)length(a)==4 & length(unique(nodecolor(b)))<4, sdinter, sdconn);
sdG2 = find(xor(sdG2,sdD2)); 
sdqidG2     = sd2qt(sdG2);
[cr, cc]    = ind2sub(size(S),sdqidG2);
sdcenter    = bsxfun(@plus,[cr,cc], (S(sdqidG2)./2)); % center for G2
centerid    = [1:length(sdG2)]'+size(intercoord,1);
segmentsG2  = arrayfun(@(a,b)[a{1}';repmat(b,1,length(a{1}))],...
                       sdinter(sdG2), centerid, 'Un', 0);

%four intersections with three or two node colors (D2)
sdD2loc = zeros(length(sdD2),1);
sdD2loc(sdD2) = cellfun(@(a,b) getD2loc(nodecolor(a),b), sdconn(sdD2), sdinterOrg(sdD2));
segmentsD2    = arrayfun(@(a,b) getD2segment(a,b{1}), sdD2loc(sdD2), sdinterOrg(sdD2), 'Un', 0);

%build map
segments    = [[segmentsE2{:}],[segmentsD2{:}],[segmentsG2{:}]]';
segmap      = cell(size(intercoord,1)+length(centerid),1);
    function buildmap(b,e)
        segmap{b} = [segmap{b},e];
        segmap{e} = [segmap{e},b];
    end
arrayfun(@buildmap, segments(:,1), segments(:,2));

%output
newintercoord = [intercoord;sdcenter];
inter2edge    = [inter2edge;zeros(size(sdcenter,1),1)];
sd2inter      = zeros(length(sdEdge),1);
sd2inter(sdG2)= length(intercoord) + (1:length(sdG2))';

%collect interfaces
visited = logical(zeros(length(newintercoord),1));
visited(centerid) = 1;

interface = cell(1024,1);
interpos  = 0;
%multiple ends
multmark = length(intercoord);
for i = 1:length(centerid)
    lines = getinterface(centerid(i),multmark);
    if(isempty(lines))
        continue;
    end
    interface(interpos + (1:length(lines))) = lines;
    interpos = interpos + length(lines);
end

%singular end
sendid = find(cellfun(@(a)length(a)==1, segmap));
for i = 1:length(sendid)
    if(visited(sendid(i)))
        continue;
    end
    lines = getinterface(sendid(i),multmark);
    if(isempty(lines))
        continue;
    end
    interface(interpos + (1:length(lines))) = lines;
    interpos = interpos + length(lines);
end

%double ends
interid = 1:length(intercoord);
interid = interid(~visited(interid));
while ~isempty(interid)
    lines = getinterface(interid(1),multmark);
    interface(interpos + (1:length(lines))) = lines;
    interpos = interpos + length(lines);
    
    interid = interid(~visited(interid));
end

interface = interface(1:interpos); %output interfaces

    function lines = getinterface(sid,multmark)
        lines   = cell(4,1);
        linepos = 0;
        for ii = 1:length(segmap{sid})
            ci = segmap{sid}(ii);
            if(visited(ci)) 
                continue; 
            end
            aninter = zeros(4096,1);
            aninter(1) = sid;
            visited(sid)  = 1;
            p          = 2;
            while ~isempty(ci)
                aninter(p) = ci;
                visited(ci)   = 1;
                p = p + 1;
                ci = segmap{ci}(~visited(segmap{ci}));
            end
            if(p>3 && any(segmap{aninter(1)}==aninter(p-1))) %check circle
                aninter(p) = aninter(1); p = p+1;
            else
                multend = segmap{aninter(p-1)}(segmap{aninter(p-1)}~=aninter(1));
                multend = multend(multend>multmark);
                assert(length(multend)==0 || length(multend)==1);
                if(~isempty(multend)) %check non-double ends
                    aninter(p) = multend;  p = p+1;
                end
            end
            aninter = aninter(1:(p-1));
            lines{linepos+1} = aninter;
            linepos = linepos + 1;
        end
        lines = lines(1:linepos);
    end

end % qt_collect_interface

%four intersections with three or two node colors
function loc = getD2loc(ncolor, inters)
    nc       = int16(ncolor(inters>0));
    [unc,ia] = unique(nc);
    if(length(unc) == 2)
        loc = 1;
%         if(ncolor(1) == unc(1))
%             loc = 1;
%         else
%             loc = 2;
%         end
    else
        assert(length(unc) == 3);
        nc(ia) = -1;
        loc = find(nc>-1); % color must be non-negtive
        assert(length(loc) == 1);
    end
end

function segment = getD2segment(loc, inters)
    ints     = inters(inters>0)';
    ints     = [ints(loc:end),ints(1:(loc-1))];
    segment  = [ints(1), ints(2); ints(3), ints(4)]';
end


