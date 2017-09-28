function [ nodevalue, sdvalue ] = qt_extract_value(coord, ele, eleStrs, eleResult, eleStrsNode)

nodalStrs = zeros(size(eleStrsNode{1},2),length(coord));
eleCnt = zeros(1,length(coord));
for i=1:length(ele)
    eNode  = ele{i};
    
    nodalStrs(:,eNode) = nodalStrs(:,eNode) + eleStrsNode{i}';
    eleCnt(eNode) = eleCnt(eNode) + 1;
    
end
a = eleCnt>0;
nodalStrs(:,a) = bsxfun(@rdivide, nodalStrs(:,a),eleCnt(a));

nodevalue = nodalStrs;
sdvalue = 0;

end

