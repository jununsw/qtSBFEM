function [handle,val] = PlotResult(coord, U, ele, eleResult,eleStrsNode,  eleMat, eleCentre, varargin)
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

ii = ii + 1; % 3
if Lia(ii);
    cMap = varargin{2*Locb(ii)};
else
    cMap = jet;
end

pele = 1:length(ele);
ii = ii + 1; % 4
if Lia(ii) && isnumeric(varargin{2*Locb(ii)})
        pele = reshape(varargin{2*Locb(ii)},1,[]);
end

ii = ii + 1;
if Lia(ii) && isnumeric(varargin{2*Locb(ii)})
    matNum = varargin{2*Locb(ii)};
    pele = pele(ismember(eleMat(pele),matNum));
end

matAvg = 1;
ii = ii + 1; % 6
if Lia(ii) && strcmpi(varargin{2*Locb(ii)},'NO')
    matAvg = 0;
end

deformFactor = 0;
ii = ii + 1; 
if Lia(ii) 
    if isnumeric(varargin{2*Locb(ii)})
        deformFactor = varargin{2*Locb(ii)};
    end
end
maxU = max(max(abs(U(:,pele)), [], 2));
maxD = max(max(coord)-min(coord));
coord = deformFactor*maxD/maxU*U' + coord;


if cidx < 4
    nodes =  NaN(length(pele),17);
    for ii = 1:length(pele)
        eNode = ele{pele(ii)};
        nNode = length(eNode);
        nodes(ii,1:nNode) = eNode;
    end
    if cidx <3
        val = U(cidx,:);
    else
        val = sqrt(sum(U.^2));
    end
        handle = patch('Faces',nodes,'Vertices', coord,...
            'FaceVertexCData',val','FaceColor','interp','EdgeColor','none');
        axis equal; axis off; axis tight; colormap(cMap);
    return
elseif cidx < 10
    cidx = cidx -3;
end

if matAvg == 0;
    
    ne = length(pele);
    elePoint = NaN(ne,17);
    ip = 1;
    for ii = 1:ne
        eNode = ele{pele(ii)};
        nNode = length(eNode);
        elePoint(ii,1:nNode) = [ip:ip+nNode-1];
        ip = ip+nNode;
    end
    
    eleXY = coord([ele{pele}],:);
    eleVal = vertcat(eleStrsNode{pele});
    handle = patch('Faces',elePoint,'Vertices', eleXY,...
        'FaceVertexCData',eleVal(:,cidx),'FaceColor','interp','EdgeColor','none');
    axis equal; axis off; axis tight; colormap(cMap);
    
else
    
    nn = size(coord,1);
    for im = matNum
        nodalStrs = zeros(nn,1);
        eleCnt = zeros(nn,1);
        
        mpele = pele(eleMat(pele)==im);
        if isempty(mpele)
            continue;
        end
        
        nodes =  NaN(length(mpele),17);
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
        
        handle = patch('Faces',nodes,'Vertices', coord,...
            'FaceVertexCData',nodalStrs,'FaceColor','interp','EdgeColor','none');
        axis equal; axis off; axis tight; colormap(cMap);
        
    end
end
%
