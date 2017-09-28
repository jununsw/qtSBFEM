function [nodalstrs] = NodalStrs(coord, ele, eleStrsNode, eleMat, varargin)
%if nargin < 4; cMap=gray; end

argList = {'Component','CAxis','ColorMap','Element','Material','Average','DeformFactor'};
[Lia, Locb] = ismember(argList,varargin(1:2:end));

ii = 1;
if Lia(ii);
    cidx = find(strcmp(varargin{2*Locb(ii)},{'DX', 'DY', 'DA', 'SX', 'SY', 'SXY','SP1', 'SP2', 'SVM'}));
end

ii = ii + 1;
if Lia(ii) && isnumeric(varargin{2*Locb(ii)})
    caxis(varargin{2*Locb(ii)});
end

ii = ii + 1;
if Lia(ii);
    cMap = varargin{2*Locb(ii)};
else
    cMap = jet;
end

pele = 1:length(ele);
ii = ii + 1;
if Lia(ii) && isnumeric(varargin{2*Locb(ii)})
        pele = reshape(varargin{2*Locb(ii)},1,[]);
end

ii = ii + 1;
if Lia(ii) && isnumeric(varargin{2*Locb(ii)})
    matNum = varargin{2*Locb(ii)};
    pele = pele(ismember(eleMat(pele),matNum));
end

matAvg = 1;
ii = ii + 1;
if Lia(ii) && strcmpi(varargin{2*Locb(ii)},'NO')
    matAvg = 0;
end


if matAvg == 0;
        
else
    
    nn = size(coord,1);
    nodalstrs = zeros(nn,5);
    for cidx = 1:5
        for im = matNum
            nodalStrs = zeros(nn,1);
            eleCnt = zeros(nn,1);
            mpele = pele(eleMat(pele)==im);
            if isempty(mpele)
                continue;
            end
        
            nodes =  NaN(length(mpele),8);
            for ii = 1:length(mpele)
                ie = mpele(ii);
                eNode  = ele{ie};
                nNode = length(eNode);
                nodes(ii,1:nNode) = eNode;
                nodalStrs(eNode) = nodalStrs(eNode) + eleStrsNode{ie}(:,cidx);
                eleCnt(eNode) = eleCnt(eNode) + 1;
            end
        
            a = eleCnt>0;
            nodalStrs(a) = nodalStrs(a)./eleCnt(a);
            nodalstrs(a,cidx) = nodalStrs(a);
        end
    end
end
%
