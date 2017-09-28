function varargout = untitled(varargin)
% UNTITLED MATLAB code for untitled.fig
%      UNTITLED, by itself, creates a new UNTITLED or raises the existing
%      singleton*.
%
%      H = UNTITLED returns the handle to a new UNTITLED or the handle to
%      the existing singleton*.
%
%      UNTITLED('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNTITLED.M with the given input arguments.
%
%      UNTITLED('Property','Value',...) creates a new UNTITLED or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before untitled_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to untitled_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help untitled

% Last Modified by GUIDE v2.5 28-Mar-2014 20:23:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @untitled_OpeningFcn, ...
                   'gui_OutputFcn',  @untitled_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before untitled is made visible.
function untitled_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to untitled (see VARARGIN)


% Choose default command line output for untitled
handles.output = hObject;
global file
file = [];
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes untitled wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = untitled_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --------------------------------------------------------------------
function Open_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global file
global QuadtreeMesh
global sind
global setbc
global cntrl
global smoothmesh

setbc.displacement = 0;
setbc.pressure = 0;
setbc.flux = 0;
sind = cell(500,1);
QuadtreeMesh = 0;
smoothmesh = 0;
handles.coord = [];
cntrl.phyprb = 'ELASTICITY';
cntrl.typfunc = 'VECTOR';
cntrl.prbtdm.type = 'STATICS';
% Open an image.
[filename, pathname] = uigetfile( ...
{'*.fig;*.bmp;*.dib;*.jpg;*.jpeg;*.jpe;*.jfif;*.gif;*.png;*.ico',...
'All Figure Files';...
'*.m;*.fig;*.mat', 'MATLAB Files (*.m,*.fig,*.mat)';...
'*.m',  'Code files (*.m)'; ...
'*.fig','Figures (*.fig)'; ...
'*.mat','MAT-files (*.mat)';...
'*.bmp;*.dib','Bitmap Files (*.bmp)'; ...
'*.jpg;*.jpeg;*.jpe;*.jfif','JPEG (*.slx, *.mdl)'; ...
'*.gif','TIFF (*.tif,*.tiff)';...
'*.png','PNG (*.png)';...
'*.ico','ICO (*.ico)';...
'*.*',  'All Files (*.*)'}, ...
'Open');

filepath = fullfile(pathname, filename);
if isequal(filename,0) || isequal(pathname,0)
   disp('User selected Cancel') % Check if an image is ready to be analyzed.
   return   
else  % hide text boxes
    % Show input boxes.
    set(handles.uipanel_Apply_Boundary_Condition,'Visible','off');
    set(handles.uipanel_Quadtree_Mesh,'Visible','off');
    set(handles.uipanel_SBFEM_Analysis,'Visible','off');
   
    set(handles.E_minDim,'String',1);
    set(handles.E_QTthreshold,'String',0.01);
    set(handles.E_aggregates,'String',70e9);
    set(handles.E_cement,'String',25e9);
    set(handles.E_voids,'String',0.1);
    set(handles.E_poisson,'String',0.02);
    set(handles.E_gravity,'String',9.81);
    set(handles.E_resolution,'String',1);
    set(handles.E_Pressure_x,'String',0);
    set(handles.E_Pressure_y,'String',-1);
    set(handles.E_Displacement_x,'String',0);
    set(handles.E_Displacement_y,'String',0);
    set(handles.D_voids,'String',1.2922);
    set(handles.D_cement,'String',2.2e3);
    set(handles.D_aggregates,'String',2.5e3);
    set(handles.S_voids,'String',1);
    set(handles.S_cement,'String',1);
    set(handles.S_aggregates,'String',1);
    set(handles.E_Flux,'String',0.1);
    set(handles.K_White_xx,'String',0.0001);
    set(handles.K_White_yy,'String',0.0001);
    set(handles.K_Grey_xx,'String',1.2);
    set(handles.K_Grey_yy,'String',1.2);
    set(handles.K_Black_xx,'String',1);
    set(handles.K_Black_yy,'String',1);
    
	handles.qtmeshvisible = 0;
    handles.analysisvisible = 0;
    handles.boundaryconditionvisible = 0;
    
    if ~isempty(handles.axes1)       
        cla(handles.axes1,'reset');
        set(handles.axes1, 'visible', 'off')
    else
        return
    end
    file = filename;
%    handles.filename = filename;
%    handles.pathname = pathname;
    % Plot the image.
    ImgOrg = imread(file);
    Img = uint8(round(sum(ImgOrg,3)/size(ImgOrg,3)));
    axes(handles.axes1);
    imshow(ImgOrg);
    clear ImgOrg
    ticImage = tic;
    nImg = size(Img);
    n = min(1024*16,2^nextpow2(max(nImg)));
    set(handles.E_maxDim,'String',n/2^5);
    disp(['User selected: ', filepath])
    disp(['*** Input image completed. time = ',num2str(toc(ticImage))]);
    disp(['    Image width = ',num2str(nImg(1,2))]);
    disp(['    Image height = ',num2str(nImg(1,1))]);
end
  
guidata(hObject, handles);


% --------------------------------------------------------------------
function Saveas_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Saveas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% % Save an image.
% [filename, pathname] = uiputfile(...
% {'*.fig;*.bmp;*.dib;*.jpg;*.jpeg;*.jpe;*.jfif;*.gif;*.png;*.ico',...
% 'All Figure Files';...
% '*.m;*.fig', 'MATLAB Files (*.m,*.fig)';...
% '*.m',  'Code files (*.m)'; ...
% '*.fig','Figures (*.fig)'; ...
% '*.bmp;*.dib','Bitmap Files (*.mat)'; ...
% '*.jpg;*.jpeg;*.jpe;*.jfif','JPEG (*.slx, *.mdl)'; ...
% '*.gif','TIFF (*.tif,*.tiff)';...
% '*.png','PNG (*.png)';...
% '*.ico','ICO (*.ico)';...
% '*.*',  'All Files (*.*)'}, ...
% 'Save as');
% 
% savepath = fullfile(pathname,filename);
% if isequal(filename,0) || isequal(pathname,0)
%    disp('User selected Cancel')
%    return
% else
%    imwrite(handles.Open,savepath,filename);
%    disp(['User selected: ',fullfile(pathname,filename)])
%    
% end
% guidata(hObject, handles);
saveInput(handles)

% --------------------------------------------------------------------
function loadInput_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to loadInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
loadInput(handles)

function saveInput(handles)
global sind
global file
global setbc

input.minDim = get(handles.E_minDim,'String');
input.maxDim = get(handles.E_maxDim,'String');
input.QTthreshold = get(handles.E_QTthreshold,'String');
input.resolution = get(handles.E_resolution,'String');
input.coord = handles.coord;
if setbc.displacement >0 
    input.boundarycondition.nodes = sind.nodes;
    input.Displacement_x = get(handles.E_Displacement_x,'String');
    input.Displacement_y = get(handles.E_Displacement_y,'String');
elseif setbc.pressure >0 
    input.boundarycondition.lines = sind.edges;
    input.Pressure_x = get(handles.E_Pressure_x,'String');
    input.Pressure_y = get(handles.E_Pressure_y,'String');
end
input.YoungsModulus.Aggregates = get(handles.E_aggregates,'String');
input.YoungsModulus.cement = get(handles.E_cement,'String');
input.YoungsModulus.voids = get(handles.E_voids,'String');
input.Gravity = get(handles.E_gravity,'String');
input.file = file;


save input.mat input

function loadInput(handles)
global sind
global file
global setbc

load 'input.mat', 'input';
set(handles.E_minDim,'String', input.minDim);
set(handles.E_maxDim,'String', input.maxDim);
set(handles.E_QTthreshold,'String', input.QTthreshold);
set(handles.E_resolution,'String', input.resolution);
handles.coord = input.coord;
if setbc.displacement >0 
    sind.nodes = input.boundarycondition.nodes;
    set(handles.E_Displacement_x,'String',input.Displacement_x);
    set(handles.E_Displacement_y,'String',input.Displacement_y);
elseif setbc.pressure >0 
    sind.edges = input.boundarycondition.lines;
    set(handles.E_Pressure_x,'String',input.Pressure_x);
    set(handles.E_Pressure_y,'String',input.Pressure_y);
end
set(handles.E_aggregates,'String',input.YoungsModulus.Aggregates);
set(handles.E_cement,'String',input.YoungsModulus.cement);
set(handles.E_voids,'String',input.YoungsModulus.voids);
set(handles.E_gravity,'String',input.Gravity);

file = input.file;
ImgOrg = imread(file);
axes(handles.axes1);
imshow(ImgOrg);
clear ImgOrg


% --------------------------------------------------------------------
function QuadtreeMesh_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to QuadtreeMesh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global file


if isempty(file)
    disp('Please select an image!')
    return
end

if handles.qtmeshvisible == 0
    set(handles.uipanel_Quadtree_Mesh,'Visible','on');
    set(handles.uipanel_Apply_Boundary_Condition,'Visible','off');
    set(handles.uipanel_SBFEM_Analysis,'Visible','off');
    handles.qtmeshvisible = 1;
    handles.analysisvisible = 0;
    handles.boundaryconditionvisible = 0;
elseif handles.qtmeshvisible == 1
    set(handles.uipanel_Quadtree_Mesh,'Visible','off');
    handles.qtmeshvisible = 0;
end 

guidata(hObject, handles);



% --------------------------------------------------------------------
function DoAnalysis_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to DoAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global file
global cntrl

if isempty(file)
    disp('Please select an image!')
    return
end

if strncmpi(cntrl.typfunc, 'SCALAR', 3)
    set(handles.uipanel_Thermal_Conductivity,'Visible','on');
    set(handles.uipanel_Density,'Visible','on');
    set(handles.uipanel_Specific_Heat,'Visible','on');
    set(handles.uipanel_Youngs_Modulus,'Visible','off');
    set(handles.text_gravity,'Visible','off');
    set(handles.E_gravity,'Visible','off');
    set(handles.text_poisson,'Visible','off');
    set(handles.E_poisson,'Visible','off');
elseif strncmpi(cntrl.typfunc, 'VECTOR', 3)
    set(handles.uipanel_Thermal_Conductivity,'Visible','off');
    set(handles.uipanel_Density,'Visible','off');
    set(handles.uipanel_Specific_Heat,'Visible','off');
    set(handles.uipanel_Youngs_Modulus,'Visible','on');
    set(handles.text_gravity,'Visible','on');
    set(handles.E_gravity,'Visible','on');
    set(handles.text_poisson,'Visible','on');
    set(handles.E_poisson,'Visible','on');
end
if handles.analysisvisible == 0
    set(handles.uipanel_SBFEM_Analysis,'Visible','on');
    set(handles.uipanel_Apply_Boundary_Condition,'Visible','off');
    set(handles.uipanel_Quadtree_Mesh,'Visible','off');
    handles.analysisvisible = 1;
    handles.qtmeshvisible = 0;
    handles.boundaryconditionvisible = 0;
elseif handles.analysisvisible == 1
    set(handles.uipanel_SBFEM_Analysis,'Visible','off');
    handles.analysisvisible = 0;
end 

guidata(hObject, handles);


function E_aggregates_Callback(hObject, eventdata, handles)
% hObject    handle to E_aggregates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of E_aggregates as text
%        str2double(get(hObject,'String')) returns contents of E_aggregates as a double

handles.aggregates = str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function E_aggregates_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E_aggregates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function greycolor_Callback(hObject, eventdata, handles)
% hObject    handle to greycolor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of greycolor as text
%        str2double(get(hObject,'String')) returns contents of greycolor as a double


% --- Executes during object creation, after setting all properties.
function greycolor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to greycolor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function whitecolor_Callback(hObject, eventdata, handles)
% hObject    handle to whitecolor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of whitecolor as text
%        str2double(get(hObject,'String')) returns contents of whitecolor as a double


% --- Executes during object creation, after setting all properties.
function whitecolor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to whitecolor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function E_cement_Callback(hObject, eventdata, handles)
% hObject    handle to E_cement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of E_cement as text
%        str2double(get(hObject,'String')) returns contents of E_cement as a double

handles.cement = str2double(get(hObject,'String'));
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function E_cement_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E_cement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function E_voids_Callback(hObject, eventdata, handles)
% hObject    handle to E_voids (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of E_voids as text
%        str2double(get(hObject,'String')) returns contents of E_voids as a double

handles.voids = str2double(get(hObject,'String'));
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function E_voids_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E_voids (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function E_poisson_Callback(hObject, eventdata, handles)
% hObject    handle to E_poisson (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of E_poisson as text
%        str2double(get(hObject,'String')) returns contents of E_poisson as a double

handles.poisson = str2double(get(hObject,'String'));
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function E_poisson_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E_poisson (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function E_minDim_Callback(hObject, eventdata, handles)
% hObject    handle to E_minDim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of E_minDim as text
%        str2double(get(hObject,'String')) returns contents of E_minDim as a double
handles.minDim = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function E_minDim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E_minDim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function E_maxDim_Callback(hObject, ~, handles)
% hObject    handle to E_maxDim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of E_maxDim as text
%        str2double(get(hObject,'String')) returns contents of E_maxDim as a double
handles.minDim = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function E_maxDim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E_maxDim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function E_QTthreshold_Callback(hObject, eventdata, handles)
% hObject    handle to E_QTthreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of E_QTthreshold as text
%        str2double(get(hObject,'String')) returns contents of E_QTthreshold as a double
handles.QTthreshold = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function E_QTthreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E_QTthreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function E_gravity_Callback(hObject, eventdata, handles)
% hObject    handle to E_gravity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of E_gravity as text
%        str2double(get(hObject,'String')) returns contents of E_gravity as a double
handles.gravity = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function E_gravity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E_gravity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function E_resolution_Callback(hObject, eventdata, handles)
% hObject    handle to E_resolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of E_resolution as text
%        str2double(get(hObject,'String')) returns contents of E_resolution as a double
handles.resolution = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function E_resolution_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E_resolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function boundary_condition_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to boundary_condition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global file
global cntrl

if isempty(file)
    disp('Please select an image!')
    return
end


if strncmpi(cntrl.typfunc, 'SCALAR', 3)
    set(handles.uipanel_Flux,'Visible','on');
    set(handles.uipanel_Pressure,'Visible','off');
elseif strncmpi(cntrl.typfunc, 'VECTOR', 3)
    set(handles.uipanel_Flux,'Visible','off');
    set(handles.uipanel_Pressure,'Visible','on');
end

if handles.boundaryconditionvisible == 0
    set(handles.uipanel_Apply_Boundary_Condition,'Visible','on');
    set(handles.uipanel_Quadtree_Mesh,'Visible','off');
    set(handles.uipanel_SBFEM_Analysis,'Visible','off');
    handles.analysisvisible = 0;
    handles.qtmeshvisible = 0;
    handles.boundaryconditionvisible = 1;
elseif handles.boundaryconditionvisible == 1
    set(handles.uipanel_Apply_Boundary_Condition,'Visible','off');
    handles.boundaryconditionvisible = 0;
end 
guidata(hObject,handles)


function E_pressure_Callback(hObject, eventdata, handles)
% hObject    handle to E_pressure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of E_pressure as text
%        str2double(get(hObject,'String')) returns contents of E_pressure as a double
handles.pressure = str2double(get(hObject,'String'));
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function E_pressure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E_pressure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_QuadtreeMesh.
function pushbutton_QuadtreeMesh_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_QuadtreeMesh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global file
global QuadtreeMesh
global mat
global cntrl
global Ndof
global smoothmesh

if isempty(file)
    disp('Please select an image!')
    return
end

% matD = @(E, p) E/(1-p^2)*[1 p 0; p 1 0;0 0 (1-p)/2];
% matK = @(Kxx,Kyy) [Kxx 0;0 Kyy];
% 
% cntrl.prbtdm.modalPara = [120 200];
% %cntrl.prbtdm.frqPara = [100 0.05 0.1];  
% cntrl.prbtdm.TIMEPara = [2000 0.1 0.5 0.25 0.5];
% %cntrl.prbtdm.forceHistory = [ 0 0; 0.2d0 1.d0; 0.4d0 0.d0;  900 0.d0];
% cntrl.prbtdm.forceHistory = [ 0 1; 3d0 1.d0; 20d0 1.d0;  5000 1.d0];

if strncmpi(cntrl.typfunc, 'SCALAR', 3)
    Ndof = 1;
elseif strncmpi(cntrl.typfunc, 'VECTOR', 3)
    Ndof=2;
end;


matColor = [0 50 1; 51 220 2; 221 255 3]; voidColor = [250 255];
mat{1}.phantom = 0;
mat{2}.phantom = 0;
mat{3}.phantom = 1;


% Read the image.

% ImgOrg = imread(handles.filename);
ImgOrg = imread(file);
Img = uint8(round(sum(ImgOrg,3)/size(ImgOrg,3)));
nImg = size(Img);
n = min(1024*16,2^nextpow2(max(nImg)));


minDim = nextpow2(str2double(get(handles.E_minDim,'String')));
minDim = 2^minDim;
set(handles.E_minDim,'String',minDim)
maxDim = nextpow2(str2double(get(handles.E_maxDim,'String')));
maxDim = 2^maxDim;
set(handles.E_maxDim,'String',maxDim)
QTthreshold = str2double(get(handles.E_QTthreshold,'String'));
handles.resolution = str2double(get(handles.E_resolution,'String'));
Resolution = handles.resolution;
% In case of QTthreshold is a negative value, it will changed to be the default value 0.01.
if QTthreshold < 0
    QTthreshold = 0.01;
    set(handles.E_QTthreshold,'String',QTthreshold)
elseif QTthreshold > 1
    QTthreshold = 1;
    set (handles.E_QTthreshold,'String',QTthreshold)
end

I = repmat( feval(class(Img),0),n);
I(1:min(n,nImg(1)), 1:min(n,nImg(2))) = Img(1:min(n,nImg(1)), 1:min(n,nImg(2)));

ticMesh = tic;

% Quadtree decomposition. 
MImg = nImg(2);
NImg = nImg(1);
if NImg < n
    if MImg < n
        for i = 1:n
            I(NImg+1:n,i) = round(mean(voidColor));
        end
    else
        for i = 1:MImg
            I(NImg+1:n,i) = round(mean(voidColor));
        end
    end
end

if MImg < n
    if NImg < n
        for j = 1:NImg
            I(j,MImg+1:n) = round(mean(voidColor));
        end
    end
end

S = qtdecomp(I, QTthreshold, [minDim, maxDim]);

% Quadtree mesh.
[coord, ele, handles.eleQT, handles.eleColor, eleSize, eleCentre,...
    handles.eleDof] = quadTreeMesh(S,I,voidColor,Ndof);
QuadtreeMesh = 1;
coord(:,2) = coord(:,2) - (n - NImg);
eleCentre(:,2) = eleCentre(:,2) - (n - NImg); 
handles.Centre = eleCentre;

coord = Resolution*coord; 
handles.eleSize = Resolution*eleSize; 
handles.eleCentre = Resolution*eleCentre; 

minEleSize = min(handles.eleSize);
handles.Tolerance = 0.2 * minEleSize;

% handles.QuadtreeMesh = 1; 

disp(['*** Mesh generation completed. time = ',num2str(toc(ticMesh))]);

handles.nNode = size(coord,1);
nEle = length(ele);

disp(['    Number of nodes = ',num2str(handles.nNode)]);
disp(['    Number of elements = ',num2str(nEle)]);
disp(['    Ratio of number of elements to number of pixel = ',...
    num2str(nEle/(nImg(1)*nImg(2)))]);

phantomMat = cellfun(@(x) x.phantom, mat);
phantomMat = find(phantomMat);
eleMat = zeros(nEle,1);
eleTrue = 1:nEle;
nMat = length(mat);
eleColor = handles.eleColor;
eleColor = round(eleColor);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



for ii =  1:nMat
        eleMat(eleColor>=matColor(ii,1) & eleColor<=matColor(ii,2) ) = ii;
end

handles.eleMat = eleMat;

vele = find(eleMat==0, 1);
if ~isempty(vele)
        disp('elements without assigned material exist')
        pause;
end

if exist('phantomMat','var')
    if ~isempty(phantomMat)
        eleTrue(eleMat==phantomMat)=[];
    end
end
handles.eleTrue = eleTrue;
handles.nodeTrue = unique([ele{eleTrue}]);

[ handles.QTedge, handles.QTedgeCentre, handles.eleEdge, handles.edge2Ele ]...
    = findElementEdges( ele(eleTrue), coord );
if smoothmesh == 1
    disp('Smooth mesh process');
end

ticPlotqdmesh = tic;
axes(handles.axes1);
cla(file,'reset');
% figure(2)
%subplot(122)
axis equal; 

PolyMshr_PlotMsh(coord, ele(eleTrue));

axis on; % axis tight;

disp(['*** Plotting quadTreeMesh completed. time = ',num2str(toc(ticPlotqdmesh))]);
handles.coord = coord;
handles.ele = ele;
guidata(hObject, handles);

% --- Executes on button press in pushbutton_SBFEM_Analysis.
function pushbutton_SBFEM_Analysis_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_SBFEM_Analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global mat
global file
global QuadtreeMesh
global sind
global setbc
global Ndof
global cntrl
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   global boundary_condition 


if isempty(file)
    disp('Please select an image!')
    return
end
if ~isequal(QuadtreeMesh,1)
    disp('Please define quadtree mesh parameters before doing analysis!')
    return
end
if isempty(sind) 
    disp('Please set boundary conditions!')
    return
elseif isempty(sind.nodes) || isempty(sind.edges)
    disp('Please check boundary conditions!')
    return
end

matD = @(E, p) E/(1-p^2)*[1 p 0; p 1 0;0 0 (1-p)/2];
matK = @(Kxx,Kyy) [Kxx 0;0 Kyy];

cntrl.prbtdm.modalPara = [120 200];
%cntrl.prbtdm.frqPara = [100 0.05 0.1];  
cntrl.prbtdm.TIMEPara = [2000 0.1 0.5 0.25 0.5];
%cntrl.prbtdm.forceHistory = [ 0 0; 0.2d0 1.d0; 0.4d0 0.d0;  900 0.d0];
cntrl.prbtdm.forceHistory = [ 0 1; 3d0 1.d0; 20d0 1.d0;  5000 1.d0];

aggregates = str2double(get(handles.E_aggregates,'String'));
cement = str2double(get(handles.E_cement,'String'));
voids = str2double(get(handles.E_voids,'String'));
poisson = str2double(get(handles.E_poisson,'String'));

mat{1}.D = matD(aggregates,poisson); mat{1}.density = 0; % mat{1}.phantom = 0;
mat{2}.D = matD(cement,poisson);     mat{2}.density = 0; % mat{2}.phantom = 0;
mat{3}.D = matD(voids,poisson);      mat{3}.density = 1; % mat{3}.phantom = 1;
mat{1}.E = aggregates;               mat{1}.G = matK(1,1);
mat{2}.E = cement;                   mat{2}.G = matK(1.2,1.2);
mat{3}.E = voids;                    mat{3}.G = matK(0.0001,0.0001);
mat{1}.mu = 1;
mat{2}.mu = 1.3;
mat{3}.mu = 0.01E-7;
gravity = str2double(get(handles.E_gravity,'String'));
% pressure = str2double(get(handles.E_pressure,'String'));
g = -gravity;

eleMat = handles.eleMat;
ele = handles.ele;
coord = handles.coord;
eleTrue = handles.eleTrue;
nNode = handles.nNode;
eleSize = handles.eleSize;
eleDof = handles.eleDof;
eleQT = handles.eleQT;
QTedge = handles.QTedge;
eleCentre = handles.eleCentre;

%% Enforcing boundary condition
ticBC = tic;

% % % % % Boundary Conditions
% bottomNodes = find(abs(handles.coord(:,2)-min(handles.coord(:,2)))...
%     < handles.Tolerance);
% topNodes = find(abs(handles.coord(:,2)-max(handles.coord(:,2))) ...
%     < handles.Tolerance);
% leftNodes = find(abs(handles.coord(:,1)-min(handles.coord(:,1))) ...
%     < handles.Tolerance);
% rightNodes = find(abs(handles.coord(:,1)-max(handles.coord(:,1)))...
%     < handles.Tolerance);

% FixedNodes = bottomNodes;
% FixedNodes = sind.nodes;

FixedNodes = 0;
if setbc.displacement >0 
%     if length(sind.nodes) > 1
% %         for i = 1:length(sind.nodes)
% %             FixedNodes = FixedNodes + length(sind.nodes{i,1});
% %         end
%         FixedNodes = cell2mat(sind.nodes);
% %         Supp = zeros(FixedNodes,3);
% %         clear length
% %         Supp(:,1)= cell2mat(sind.nodes); 
% %         Supp(:,3)=2; Supp(end,2)=1;
%     else
%         FixedNodes = sind.nodes{1,1};
% %         Supp = zeros(length(FixedNodes),3);
% %         Supp(:,1)=cell2mat(sind.nodes); 
% %         Supp(:,3)=2; Supp(end,2)=1;    
%     end
    FixedNodes = cell2mat(sind.nodes);
end

if setbc.pressure >0 
    topEdges = cell2mat(sind.edges);
    topEdgeLen = abs(sum(coord(handles.QTedge(topEdges,2),:)...
        -coord(handles.QTedge(topEdges,1),:),2));
end
if Ndof ==2         % Boundary conditions for 2D case
%     dNode = length(FixedNodes) + 1; % ???????????????????????????????/////
    dNode = length(FixedNodes);
    bc_disp = zeros(dNode,3);
%     bc_disp(:,1) = [FixedNodes; FixedNodes(1)];
    bc_disp(:,1) = FixedNodes;
    bc_disp(:,3) = 1; bc_disp(1,2) = 1;
    
    bc_force = zeros(2*nNode,3);
    bc_force(:,1) = reshape([1:nNode;1:nNode],[],1);
    bc_force(:,2) = reshape([ones(1,nNode);2*ones(1,nNode)],[],1);
%     minx = min(min(coord(QTedge(topEdges,2),1)), min(coord(QTedge(topEdges,1))));
%     maxx = max(max(coord(QTedge(topEdges,2),1)), max(coord(QTedge(topEdges,1))));
%     x = QTedgeCentre(topEdges,1);
%     pressure = 2*(x-minx)/(maxx-minx)-1;
    pressure = -10000000;
    bc_force(QTedge(topEdges,1)*2,3) = bc_force(QTedge(topEdges,1)*2,3)+ pressure.*topEdgeLen/2;
    bc_force(QTedge(topEdges,2)*2,3) = bc_force(QTedge(topEdges,2)*2,3)+ pressure.*topEdgeLen/2;
    bc_force = bc_force(bc_force(:,3)~=0,:);
elseif Ndof ==1     % Boundary conditions for 1D case
    % Boundary temperature
    T0 = 0;
    dNode = FixedNodes;
    bc_disp = zeros(dNode,3);
    bc_disp(:,1) = FixedNodes;
    bc_disp(:,2) = 1;
    bc_disp(:,3) = T0;
    
    % Boundary flux
    bc_force = zeros(nNode,3);
    bc_force(:,1) = (1:nNode)';
    bc_force(:,2) = ones(nNode,1);
    
    flux = 0.1;
    % the flux is converted to nodal force
    bc_force(QTedge(topEdges,1),3) = bc_force(QTedge(topEdges,1),3)+ flux.*topEdgeLen/2;
    bc_force(QTedge(topEdges,2),3) = bc_force(QTedge(topEdges,2),3)+ flux.*topEdgeLen/2;
end

% Supp = zeros(length(FixedNodes),3);


% FixedNodes = [bottomNodes; leftNodes; rightNodes];
% Supp = zeros(length(FixedNodes),3);
% Supp(:,1)=FixedNodes; 
% n1 = length(bottomNodes); 
% Supp(1:n1,2:3)=1;
% Supp(n1+1:end,2)=1;

% topEdges = find(handles.QTedgeCentre(:,2)==max(handles.coord(:,2)));
% topEdges = sind.edges;


% Load(handles.QTedge(topEdges,1),3) = Load(handles.QTedge(topEdges,1),3) + pressure.*topEdgeLen/2;
% Load(handles.QTedge(topEdges,2),3) = Load(handles.QTedge(topEdges,2),3) + pressure.*topEdgeLen/2;
% Load = Load(Load(:,3)~=0,:);
    
disp(['*** Enforcing boundary condition completed. time = ',num2str(toc(ticBC))]);
    
figure
axis equal

if exist('bc_disp','var')
    PolyMshr_PlotMsh(coord, ele(eleTrue), bc_disp, bc_force);
else
    PolyMshr_PlotMsh(coord, ele(eleTrue));
end
%% SBFEM analysis
ticSolution = tic;
% Compute library of matrices for each square element type based on their
% local geometry
QTEle  = QuadTreeElements( mat, g,Ndof );

% Analysis
[U, solution] = SBFEAnalysis(cntrl, QTEle, coord, ele, eleQT, eleSize, eleDof, eleMat, ...
      mat, bc_force, bc_disp,Ndof);

% Return solution
if strncmpi(cntrl.prbtdm.type, 'STATICS', 3)
    ReFrc=solution;
elseif strncmpi(cntrl.prbtdm.type, 'TIME', 3)
    Uinitial=U;
    sln=solution;
elseif strncmpi(cntrl.prbtdm.type, 'MODAL', 3)
    freqAngular=solution.Freq;
    modalShapes=solution.Shape;
end  
% ReFrc = reshape(ReFrc,2,[]); 
% sum(ReFrc(2,topNodes))
disp(['*** Solution completed. time = : ',num2str(toc(ticSolution))]);
%% Post processing: 
%each type will have different post processing section

%Vector case
ticPost = tic;
if Ndof==2
    %Post processing static
    if strncmpi(cntrl.prbtdm.type, 'statics', 3)
        U = reshape(U,2,[]);
        [ eleStrs, eleResult, eleStrsNode] = ElementStress(U, QTEle, coord, ele, eleQT, eleSize, eleMat, mat );

        maxU = max(abs(U(:,[ele{eleTrue}])), [], 2);
        maxU = max(maxU);
        maxD = max(max(coord)-min(coord));
        deformed = 0.06*maxD/maxU*U' + coord;

        % figure
        % PlotElement(coord, ele(eleTrue), eleStrs(2,eleTrue)', jet);
        % colorbar
        % %axis on
        
        ticPlotmesh = tic;
        figure
        PolyMshr_PlotMsh(deformed, ele(eleTrue));
        axis on; axis equal

        disp(['*** Plotting deformed mesh completed. time = ',num2str(toc(ticPlotmesh))]);

        figure
        myjet = jet; myjet = myjet(1:4:end,:);
        PlotResult(coord, U, ele, eleResult, eleStrsNode,...
            eleMat, eleCentre, 'Component', 'SP1', 'Element',...
            eleTrue, 'Material', (1:2), 'Average', 'YES', 'ColorMap',...
            myjet, 'DeformFactor',0.05);

        colorbar

%         figure
%         myjet = jet; myjet = myjet(1:2:end,:);
%         PlotResult(coord, U, ele, eleResult, eleStrsNode,  eleMat, eleCentre, ...
%             'Component', 'DY', 'Element',eleTrue, 'Material', (2), ...
%             'Average', 'YES', 'ColorMap', myjet, 'DeformFactor',0.05);
%         %caxis([0 0.2])
%         colorbar

        % figure
        % myjet = jet; myjet = myjet(1:4:end,:);
        % PlotResult(coord, U, ele, eleResult, eleStrsNode,  eleMat, eleCentre, ...
        %     'Component', 'SP1', 'Element',eleTrue, 'Material', (2), ...
        %     'Average', 'YES', 'ColorMap', myjet, 'DeformFactor',0.05);
        % caxis([0 0.2])

        
        %Post processing time domain
    elseif strncmpi(cntrl.prbtdm.type, 'time', 3)
            %   find top right node    
        inoder = find(abs(coord(:,1)-size(S,1)-0.5)<1e-10);
        inodec = find(abs(coord(inoder,2)-size(S,1)-0.5)<1e-10);
        iA = inoder(inodec);

        time = zeros(cntrl.prbtdm.TIMEPara(1)+1,1);
        uAyr   = zeros(cntrl.prbtdm.TIMEPara(1)+1,1);
        for it=1:cntrl.prbtdm.TIMEPara(1)+1
            time(it) = sln(it).tm;
            uAyr(it) = sln(it).disp(2,iA);
        end

        figure
        plot(time,uAyr)

        inodecm = find(abs(coord(inoder,2)-size(S,1)/2-0.5)<1e-10);
        iA_center = inoder(inodecm);

        timem = zeros(cntrl.prbtdm.TIMEPara(1)+1,1);
        uAym   = zeros(cntrl.prbtdm.TIMEPara(1)+1,1);
        for it=1:cntrl.prbtdm.TIMEPara(1)+1
            timem(it) = sln(it).tm;
            uAym(it) = sln(it).disp(2,iA_center);
        end

        figure
        plot(timem,uAym)  
    %post processing modal
    elseif strncmpi(cntrl.prbtdm.type, 'MODAL', 3)
       
    end

    %Scalar case
elseif Ndof==1
    %Steady state case
    if strncmpi(cntrl.prbtdm.type, 'statics', 3)
        figure 
        PlotElement_Duc(coord,ele,eleTrue,U,jet,eleMat,1);
    %Transient case
    elseif strncmpi(cntrl.prbtdm.type, 'time', 3)
        if strncmpi(cntrl.phyprb, 'DIFFUSION', 3)
            %   find top right node  
        % compute offset distance to move the whole structure to point
        % (0,0)
        point_offset=find_nodes(coord,0,0);
        offset=coord(point_offset,:);
        off_x=offset(1);off_y=offset(2);
        
        % find the node closest to the coordinates specified
        iA_center=find_nodes(coord,10.24+off_x,5.12+off_y);
        iA_left=find_nodes(coord,0+off_x,7.68+off_y);
        Animation_Temp(coord,ele,eleTrue,sln,cntrl,jet,50,eleMat,1);
       
        %iAl = inodel(round(length(inodel)/2))+2;
        
        
        %plot exact
        
        
%         T_exact=zeros(size(time));
%         for jj=1:length(time)
%             T_exact(jj)= Exact_Transient_Rectangle(flux,1,1,coord(iA_center,2)-off_y,time(jj),200);
%         end
        
%         figure
%         plot(time,T_exact,time,uAyl);
        
        

        % use 1st frame to get dimensions
        %ANIMATE
        elseif strncmpi(cntrl.phyprb, 'ELASTICITY', 3)
            
            
            
        end
        
    end
end

disp(['*** Plotting deformed mesh completed. time = ',num2str(toc(ticPlotmesh))]);
disp(['*** Post-processing completed. time = : ',num2str(toc(ticPost))]);

h = msgbox('Calculation completed!');
guidata(hObject, handles);


% --- Executes on button press in pushbutton_boundarycondition_displacement.
function pushbutton_boundarycondition_displacement_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_boundarycondition_displacement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global file
global QuadtreeMesh
global sind
global setbc

if isempty(file)
    disp('Please select an image!')
    return
end
if ~isequal(QuadtreeMesh,1)
    disp('Please define quadtree mesh parameters before doing analysis!')
    return
end
coord = handles.coord;
Tolerance = handles.Tolerance;

setbc.displacement = setbc.displacement + 1;

axes(handles.axes1);
[x, y] = ginput;
x = round(x); y = round(y);
x_plot = dsearchn(coord(:,1), x);
y_plot = dsearchn(coord(:,2), y);
x_plot = coord(x_plot,1);
y_plot = coord(y_plot,2);
plot(x_plot, y_plot, 'LineWidth',2)
nodes = nodesIndex(coord, x_plot(1), y_plot(1), x_plot(2), y_plot(2), Tolerance);
sind.nodes{setbc.displacement,1} = nodes;
clear nodes
% handles.sind_nodes = sind.nodes;
% nodes = coord(sind.nodes, :);
% handles.FixedNodes = nodes;



guidata(hObject, handles);

% --- Executes on button press in pushbutton_boundarycondition_pressure.
function pushbutton_boundarycondition_pressure_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_boundarycondition_pressure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global file
global QuadtreeMesh
global sind
global setbc

if isempty(file)
    disp('Please select an image!')
    return
end
if ~isequal(QuadtreeMesh,1)
    disp('Please define quadtree mesh parameters before doing analysis!')
    return
end
coord = handles.coord;
QTedgeCentre = handles.QTedgeCentre;
% QTedge = handles.QTedge;
Tolerance = handles.Tolerance;

setbc.pressure = setbc.pressure + 1;

axes(handles.axes1);
[x, y] = ginput;
x = round(x); y = round(y);
x_plot = dsearchn(coord(:,1), x);
y_plot = dsearchn(coord(:,2), y);
x_plot = coord(x_plot,1);
y_plot = coord(y_plot,2);
plot(x_plot, y_plot, 'r', 'LineWidth',2)
edges = nodesIndex(QTedgeCentre, x_plot(1), y_plot(1), x_plot(2), y_plot(2), Tolerance);
sind.edges{setbc.pressure,1} = edges;
clear edges
% handles.sind_edges = sind.edges;
% edges = QTedge(sind.edges, :);
% handles.FixedEdges = edges;


guidata(hObject, handles);


% --- Executes when selected object is changed in uipanel_Discipline.
function uipanel_Discipline_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_Discipline 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global cntrl

if hObject == handles.radiobutton_Thermal
%     set(handles.uipanel_Analysis_Type_Structure,'Visible','off')
    cntrl.phyprb = 'DIFFUSION';
  	cntrl.typfunc = 'SCALAR';
elseif hObject == handles.radiobutton_Structure
%     set(handles.uipanel_Analysis_Type_Structure,'Visible', 'on');
    cntrl.phyprb = 'ELASTICITY';
    cntrl.typfunc = 'VECTOR';
end
guidata(hObject, handles);


% --- Executes when selected object is changed in uipanel_Analysis_Type_Structure.
function uipanel_Analysis_Type_Structure_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_Analysis_Type_Structure 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

if hObject == handles.radiobutton_Static1
    handles.prbtdm.type = 'STATICS';
elseif hObject == handles.radiobutton_Dynamic
    %%%%%%% transient ????
    
end
guidata(hObject, handles);


% --- Executes when selected object is changed in uipanel_Analysis_Type_Thermal.
function uipanel_Analysis_Type_Thermal_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_Analysis_Type_Thermal 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global cntrl

if hObject == handles.radiobutton_Static2
    cntrl.prbtdm.type = 'STATICS';
elseif hObject == handles.radiobutton_Time
    cntrl.prbtdm.type = 'TIME';
elseif hObject == handles.radiobutton_Modal
    cntrl.prbtdm.type = 'MODAL';
end
guidata(hObject, handles);



function E_Pressure_x_Callback(hObject, eventdata, handles)
% hObject    handle to E_Pressure_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of E_Pressure_x as text
%        str2double(get(hObject,'String')) returns contents of E_Pressure_x as a double


% --- Executes during object creation, after setting all properties.
function E_Pressure_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E_Pressure_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function E_Pressure_y_Callback(hObject, eventdata, handles)
% hObject    handle to E_Pressure_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of E_Pressure_y as text
%        str2double(get(hObject,'String')) returns contents of E_Pressure_y as a double


% --- Executes during object creation, after setting all properties.
function E_Pressure_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E_Pressure_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function E_Displacement_x_Callback(hObject, eventdata, handles)
% hObject    handle to E_Displacement_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of E_Displacement_x as text
%        str2double(get(hObject,'String')) returns contents of E_Displacement_x as a double


% --- Executes during object creation, after setting all properties.
function E_Displacement_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E_Displacement_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function E_Displacement_y_Callback(hObject, eventdata, handles)
% hObject    handle to E_Displacement_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of E_Displacement_y as text
%        str2double(get(hObject,'String')) returns contents of E_Displacement_y as a double


% --- Executes during object creation, after setting all properties.
function E_Displacement_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E_Displacement_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when uipanel_Apply_Boundary_Condition is resized.
function uipanel_Apply_Boundary_Condition_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to uipanel_Apply_Boundary_Condition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);
% --- Executes on button press in pushbutton_flux.
function pushbutton_flux_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_flux (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global file
global QuadtreeMesh
global sind
global setbc

if isempty(file)
    disp('Please select an image!')
    return
end
if ~isequal(QuadtreeMesh,1)
    disp('Please define quadtree mesh parameters before doing analysis!')
    return
end
coord = handles.coord;
QTedgeCentre = handles.QTedgeCentre;
% QTedge = handles.QTedge;
Tolerance = handles.Tolerance;

setbc.flux = setbc.flux + 1;

axes(handles.axes1);
[x, y] = ginput;
x = round(x); y = round(y);
x_plot = dsearchn(coord(:,1), x);
y_plot = dsearchn(coord(:,2), y);
x_plot = coord(x_plot,1);
y_plot = coord(y_plot,2);
plot(x_plot, y_plot, 'y', 'LineWidth',2)
edges = nodesIndex(QTedgeCentre, x_plot(1), y_plot(1), x_plot(2), y_plot(2), Tolerance);
sind.edges{setbc.flux,1} = edges;
clear edges
% handles.sind_edges = sind.edges;
% edges = QTedge(sind.edges, :);
% handles.FixedEdges = edges;


guidata(hObject, handles);

function E_Flux_Callback(hObject, eventdata, handles)
% hObject    handle to E_Flux (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of E_Flux as text
%        str2double(get(hObject,'String')) returns contents of E_Flux as a double


% --- Executes during object creation, after setting all properties.
function E_Flux_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E_Flux (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_smooth_mesh.
function checkbox_smooth_mesh_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_smooth_mesh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global smoothmesh
if hObject == handles.checkbox_smooth_mesh
   smoothmesh = 1;
end
get(hObject,'Value')

% Hint: get(hObject,'Value') returns toggle state of checkbox_smooth_mesh



function edit32_Callback(hObject, eventdata, handles)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit32 as text
%        str2double(get(hObject,'String')) returns contents of edit32 as a double


% --- Executes during object creation, after setting all properties.
function edit32_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function E_Density_Grey_Callback(hObject, eventdata, handles)
% hObject    handle to E_Density_Grey (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of E_Density_Grey as text
%        str2double(get(hObject,'String')) returns contents of E_Density_Grey as a double


% --- Executes during object creation, after setting all properties.
function E_Density_Grey_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E_Density_Grey (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function E_Density_White_Callback(hObject, eventdata, handles)
% hObject    handle to E_Density_White (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of E_Density_White as text
%        str2double(get(hObject,'String')) returns contents of E_Density_White as a double


% --- Executes during object creation, after setting all properties.
function E_Density_White_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E_Density_White (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function E_Density_Black_Callback(hObject, eventdata, handles)
% hObject    handle to E_Density_Black (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of E_Density_Black as text
%        str2double(get(hObject,'String')) returns contents of E_Density_Black as a double


% --- Executes during object creation, after setting all properties.
function E_Density_Black_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E_Density_Black (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit41_Callback(hObject, eventdata, handles)
% hObject    handle to edit41 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit41 as text
%        str2double(get(hObject,'String')) returns contents of edit41 as a double


% --- Executes during object creation, after setting all properties.
function edit41_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit41 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit42_Callback(hObject, eventdata, handles)
% hObject    handle to edit42 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit42 as text
%        str2double(get(hObject,'String')) returns contents of edit42 as a double


% --- Executes during object creation, after setting all properties.
function edit42_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit42 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit43_Callback(hObject, eventdata, handles)
% hObject    handle to edit43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit43 as text
%        str2double(get(hObject,'String')) returns contents of edit43 as a double


% --- Executes during object creation, after setting all properties.
function edit43_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function D_cement_Callback(hObject, eventdata, handles)
% hObject    handle to D_cement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of D_cement as text
%        str2double(get(hObject,'String')) returns contents of D_cement as a double


% --- Executes during object creation, after setting all properties.
function D_cement_CreateFcn(hObject, eventdata, handles)
% hObject    handle to D_cement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function D_voids_Callback(hObject, eventdata, handles)
% hObject    handle to D_voids (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of D_voids as text
%        str2double(get(hObject,'String')) returns contents of D_voids as a double


% --- Executes during object creation, after setting all properties.
function D_voids_CreateFcn(hObject, eventdata, handles)
% hObject    handle to D_voids (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function D_aggregates_Callback(hObject, eventdata, handles)
% hObject    handle to D_aggregates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of D_aggregates as text
%        str2double(get(hObject,'String')) returns contents of D_aggregates as a double


% --- Executes during object creation, after setting all properties.
function D_aggregates_CreateFcn(hObject, eventdata, handles)
% hObject    handle to D_aggregates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function S_cement_Callback(hObject, eventdata, handles)
% hObject    handle to S_cement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of S_cement as text
%        str2double(get(hObject,'String')) returns contents of S_cement as a double


% --- Executes during object creation, after setting all properties.
function S_cement_CreateFcn(hObject, eventdata, handles)
% hObject    handle to S_cement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function S_voids_Callback(hObject, eventdata, handles)
% hObject    handle to S_voids (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of S_voids as text
%        str2double(get(hObject,'String')) returns contents of S_voids as a double


% --- Executes during object creation, after setting all properties.
function S_voids_CreateFcn(hObject, eventdata, handles)
% hObject    handle to S_voids (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function S_aggregates_Callback(hObject, eventdata, handles)
% hObject    handle to S_aggregates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of S_aggregates as text
%        str2double(get(hObject,'String')) returns contents of S_aggregates as a double


% --- Executes during object creation, after setting all properties.
function S_aggregates_CreateFcn(hObject, eventdata, handles)
% hObject    handle to S_aggregates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function K_White_xx_Callback(hObject, eventdata, handles)
% hObject    handle to K_White_xx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of K_White_xx as text
%        str2double(get(hObject,'String')) returns contents of K_White_xx as a double


% --- Executes during object creation, after setting all properties.
function K_White_xx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to K_White_xx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function K_White_yy_Callback(hObject, eventdata, handles)
% hObject    handle to K_White_yy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of K_White_yy as text
%        str2double(get(hObject,'String')) returns contents of K_White_yy as a double


% --- Executes during object creation, after setting all properties.
function K_White_yy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to K_White_yy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function K_Black_xx_Callback(hObject, eventdata, handles)
% hObject    handle to K_Black_xx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of K_Black_xx as text
%        str2double(get(hObject,'String')) returns contents of K_Black_xx as a double


% --- Executes during object creation, after setting all properties.
function K_Black_xx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to K_Black_xx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function K_Black_yy_Callback(hObject, eventdata, handles)
% hObject    handle to K_Black_yy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of K_Black_yy as text
%        str2double(get(hObject,'String')) returns contents of K_Black_yy as a double


% --- Executes during object creation, after setting all properties.
function K_Black_yy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to K_Black_yy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function K_Grey_xx_Callback(hObject, eventdata, handles)
% hObject    handle to K_Grey_xx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of K_Grey_xx as text
%        str2double(get(hObject,'String')) returns contents of K_Grey_xx as a double


% --- Executes during object creation, after setting all properties.
function K_Grey_xx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to K_Grey_xx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function K_Grey_yy_Callback(hObject, eventdata, handles)
% hObject    handle to K_Grey_yy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of K_Grey_yy as text
%        str2double(get(hObject,'String')) returns contents of K_Grey_yy as a double


% --- Executes during object creation, after setting all properties.
function K_Grey_yy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to K_Grey_yy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
