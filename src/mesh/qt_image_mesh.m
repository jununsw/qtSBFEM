function [coord, ele, eleQT, eleColor, eleSize, eleCentre] = qt_image_mesh( I, meshctrl )
% image meshing based on quad-tree structure


% parameter for meshing
QTthreshold  = meshctrl.QTthreshold;
minDim       = meshctrl.minDim; 
maxDim       = meshctrl.maxDim;
opts         = [meshctrl.offsetNode, meshctrl.offsetInter];
smootheps    = meshctrl.smoothEPS; %if opts(2)==0, smootheps < 0.25; otherwise smootheps < 0.5

% parameter for debugging
UNSW_PROFILE = meshctrl.UNSW_PROFILE;
UNSW_DEBUG   = meshctrl.UNSW_DEBUG;
outputdir    = meshctrl.outputdir;

if(UNSW_PROFILE)
    profile on
end

% qtdecomp image
S = qtdecomp(I, QTthreshold, [minDim, maxDim]);
if(UNSW_DEBUG)
    [coord, sdconn, nodecolor, sd2qt, sdhnode] = qt_extractmesh(S, I);
    PolyMshr_PlotMsh(0,coord, sdconn);
    exportpolyVTK(democoord, sdconn, [outputdir,'qt.vtk']);
end

%balance the quadtree to enforce a 1:2 ratio
S = qt_balance(S);

% extract mesh from the quad-tree structure
[coord, sdconn, nodecolor, sd2qt, sdhnode] = qt_extractmesh(S, I);


%build mesh topology structure
[ meshEdge, sdEdge, edge2sd, node2Edge, node2sd] = meshConnectivity(sdconn);

%calculate intersection
[intercoord, inter2edge, edge2inter] = qt_img_intersection(I, coord, meshEdge);

%collect interfaces
[intercoord, inter2edge, sd2inter, sdD2loc, interface] = qt_collect_interface...
    (intercoord, inter2edge, edge2inter, nodecolor, sdconn,sdEdge, sd2qt, S);
if(UNSW_DEBUG)
    figure
    hold on;
    axis equal; 
    strid = num2str((1:length(intercoord))'); 
    text(intercoord(:,1),intercoord(:,2), strid);
    for xxi = 1:length(interface)
        plot(intercoord(interface{xxi},1),intercoord(interface{xxi},2), '-+');
    end
end

%smooth the interfaces
[polycoord, inter2coord] = qt_smooth(intercoord, interface, inter2edge, edge2inter, ...
                                 coord, meshEdge, edge2sd, sd2qt, S, smootheps, opts);
if(UNSW_DEBUG)
    figure
    hold on;
    axis equal; 
    PolyMshr_PlotMsh(0,polycoord, sdconn);
    strid = num2str((1:length(polycoord))'); 
    text(polycoord(:,1),polycoord(:,2), strid);
    for xxi = 1:length(interface)
        plot(polycoord(inter2coord(interface{xxi}),1),polycoord(inter2coord(interface{xxi}),2), '-+');
    end
end

%cut mesh by interfaces
[polyconn, poly2sd] = qt_cutmesh(sdconn, sdhnode, sdEdge, edge2inter, sd2inter, sdD2loc, inter2coord);
if(UNSW_DEBUG)
    figure
    hold on;
    axis equal;
    exportpolyVTK( polycoord,polyconn, [outputdir,'cut.vtk'] );
    PolyMshr_PlotMsh(0,polycoord, polyconn);
end


% build variables for sbfem
[coord, ele, eleQT, eleColor, eleSize, eleCentre] = qt_build_sbfem ...
    (polycoord, polyconn, inter2coord, poly2sd, sdhnode, sd2inter, sd2qt, coord, S, I);

end

