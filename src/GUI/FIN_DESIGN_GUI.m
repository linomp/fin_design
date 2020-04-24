function varargout = FIN_DESIGN_GUI(varargin)
% FIN_DESIGN_GUI MATLAB code for FIN_DESIGN_GUI.fig
%      FIN_DESIGN_GUI, by itself, creates a new FIN_DESIGN_GUI or raises the existing
%      singleton*.
%
%      H = FIN_DESIGN_GUI returns the handle to a new FIN_DESIGN_GUI or the handle to
%      the existing singleton*.
%
%      FIN_DESIGN_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIN_DESIGN_GUI.M with the given input arguments.
%
%      FIN_DESIGN_GUI('Property','Value',...) creates a new FIN_DESIGN_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FIN_DESIGN_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FIN_DESIGN_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FIN_DESIGN_GUI

% Last Modified by GUIDE v2.5 30-Nov-2017 02:33:19

% Begin initialization code - DO NOT EDIT
clc
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FIN_DESIGN_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @FIN_DESIGN_GUI_OutputFcn, ...
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


% --- Executes just before FIN_DESIGN_GUI is made visible.
function FIN_DESIGN_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FIN_DESIGN_GUI (see VARARGIN)

% Choose default command line output for FIN_DESIGN_GUI
handles.output = hObject;

set(handles.axes1, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
 

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FIN_DESIGN_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FIN_DESIGN_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonGO.
function pushbuttonGO_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonGO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% BOUNDARY CONDITIONS AND OTHER PROBLEM DATA
clc  

set(handles.pushbuttonGO,'Enable','off');
set(handles.pushbuttonCheck,'Enable','off');

problem = HBProblem();  

problem.objective_func = @HT_objective_func_alt;
problem.constraints_func = @(chrom) HT_constraints(chrom, problem.bc);
problem.decoding_func = @(chrom) decodeParams(chrom, problem.bc);

problem.grid_dims = [3 3 2 2 2 2];  


problem.bc = struct(); 

% TODO: DEFAULT VALUES AND VALIDATION 

problem.bc.Tb = str2double(get(handles.editTB,'String')); % Temperature @ base [K]
problem.bc.T_inf = str2double(get(handles.editFluidTemp,'String')); %Fluid Temperature [K]
problem.bc.h = str2double(get(handles.editFluidCoeff,'String')); % Fluid Convection coefficient [W/ m^2 K]
problem.bc.H = str2double(get(handles.editBaseHeight,'String'));% Base Body Height [m]
problem.bc.W = str2double(get(handles.editBaseWidth,'String')); % Base Body Width [m]

problem.bc.ThetaBase = problem.bc.Tb - problem.bc.T_inf;% Excess temperature @ base [K]

materials = pushbuttonLoadFile_Callback(hObject, eventdata, handles);
for i = 1:size(materials,1)
    problem.bc.Mats{i}.name = materials{i,1};
    problem.bc.Mats{i}.K    = materials{i,2};    
    problem.bc.Mats{i}.rho  = materials{i,3};
    problem.bc.Mats{i}.cost = materials{i,4};
end

problem.bc.min_pitch = str2double(get(handles.editMinPitch,'String'));%2e-3; % minimum pitch constrain (clearance in mm)
problem.bc.budget    = str2double(get(handles.editBudget,'String'));%1.5e-2; % 1e-3;
problem.bc.maxVol    = inf;%1e-5;  % 1e-6;
problem.bc.minQt     = str2double(get(handles.editQt,'String'));%100;

% PARAMETERS UPPER AND LOWER BOUNDS
% Individual Structure: 
% N : {1,...,10}  number of fins
% w : {1e-3,..,wall width} width
% t : {1,...,wall height} thickness
% l : {0,..,0.5} length
% fin type: {1,..,3} fin type
% Material: {1,..,3} fin material  
N_LB = str2double(get(handles.editNumFinsLB,'String'));
N_UB = str2double(get(handles.textNumFinsUB,'String'));
width_LB = str2double(get(handles.editFinWidthLB,'String'));
width_UB = str2double(get(handles.editFinWidthUB,'String'));
thickness_LB = str2double(get(handles.editFinThicknessLB,'String'));
thickness_UB = str2double(get(handles.editFinThicknessUB,'String'));
length_LB = str2double(get(handles.editFinLengthLB,'String'));
length_UB = str2double(get(handles.editFinLengthUB,'String'));
problem.LB = [ N_LB ,  width_LB, thickness_LB , length_LB ,  1,           1          ];   
problem.UB = [ N_UB ,  width_UB, thickness_UB,  length_UB ,  3, size(problem.bc.Mats,2)]; 
 
set(handles.systemMessage,'String','Running GA ...');
pause(0.5);
[population, popData, candidates] = optimizationLauncher(problem);

set(handles.pushbuttonCheck,'Enable','on');

best_parameters_coded = candidates{1};

diary('example')
diary on
best_parameters  = decodeParams(best_parameters_coded, problem.bc);
diary off
output = fileread('example');  
set(handles.systemMessage,'String',output);
delete('example')
assignin('base','best_parameters',best_parameters);
assignin('base','bp_coded',best_parameters_coded);
assignin('base','bcData',problem.bc);

best_parameters_coded_chrom= best_parameters_coded.chrom;

switch( best_parameters_coded_chrom(5) )
    case 1
        % plot rectangular fin figure 
        img = imread('rectangular.png');
        imshow(img,'Parent',handles.axes1);

    case 2
        img = imread('triangular.png');
        imshow(img,'Parent',handles.axes1);
    case 3    
        img = imread('parabolic.png');
        imshow(img,'Parent',handles.axes1);
end

set(handles.textResNFins,'String',round(best_parameters_coded_chrom(1)));
maxDist = (problem.bc.H - best_parameters_coded_chrom(1)*best_parameters_coded_chrom(3)) / ...
          ( best_parameters_coded_chrom(1) -1 );
           
set(handles.textResMaxDist,'String',num2str(maxDist*1000));

best_parameters_coded_chrom(end-1) = 1;
disp('rect');
[~,q] = HT_objective_func_alt(best_parameters_coded_chrom,problem.bc)
best_parameters_coded_chrom(end-1) = 2;
disp('tri');
[~,q] = HT_objective_func_alt(best_parameters_coded_chrom,problem.bc)
disp('parab');
best_parameters_coded_chrom(end-1) = 3;
[~,q] = HT_objective_func_alt(best_parameters_coded_chrom,problem.bc)




function editBudget_Callback(hObject, eventdata, handles)
% hObject    handle to editBudget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBudget as text
%        str2double(get(hObject,'String')) returns contents of editBudget as a double


% --- Executes during object creation, after setting all properties.
function editBudget_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBudget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editQt_Callback(hObject, eventdata, handles)
% hObject    handle to editQt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQt as text
%        str2double(get(hObject,'String')) returns contents of editQt as a double


% --- Executes during object creation, after setting all properties.
function editQt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editMinPitch_Callback(hObject, eventdata, handles)
% hObject    handle to editMinPitch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMinPitch as text
%        str2double(get(hObject,'String')) returns contents of editMinPitch as a double
H = str2double(get(handles.editBaseHeight,'String'));
t = str2double(get(handles.editFinThicknessLB,'String'));
d = str2double(get(handles.editMinPitch,'String'));
maxN = H/(t+d);
floor(maxN)
set(handles.textNumFinsUB,'String',num2str(floor(maxN)));
set(handles.pushbuttonGO,'Enable','off'); 

% --- Executes during object creation, after setting all properties.
function editMinPitch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMinPitch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editNumFinsUB_Callback(hObject, eventdata, handles)
% hObject    handle to editNumFinsUB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNumFinsUB as text
%        str2double(get(hObject,'String')) returns contents of editNumFinsUB as a double
set(handles.pushbuttonGO,'Enable','off'); 

% --- Executes during object creation, after setting all properties.
function editNumFinsUB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNumFinsUB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFinLengthUB_Callback(hObject, eventdata, handles)
% hObject    handle to editFinLengthUB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFinLengthUB as text
%        str2double(get(hObject,'String')) returns contents of editFinLengthUB as a double
set(handles.pushbuttonGO,'Enable','off'); 

% --- Executes during object creation, after setting all properties.
function editFinLengthUB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFinLengthUB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editNumFinsLB_Callback(hObject, eventdata, handles)
% hObject    handle to editNumFinsLB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNumFinsLB as text
%        str2double(get(hObject,'String')) returns contents of editNumFinsLB as a double
set(handles.pushbuttonGO,'Enable','off'); 

% --- Executes during object creation, after setting all properties.
function editNumFinsLB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNumFinsLB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editBaseWidth_Callback(hObject, eventdata, handles)
% hObject    handle to editBaseWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBaseWidth as text
%        str2double(get(hObject,'String')) returns contents of editBaseWidth as a double
set(handles.editFinWidthUB, 'String', get(handles.editBaseWidth,'String'));
set(handles.pushbuttonGO,'Enable','off'); 

% --- Executes during object creation, after setting all properties.
function editBaseWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBaseWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editBaseHeight_Callback(hObject, eventdata, handles)
% hObject    handle to editBaseHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBaseHeight as text
%        str2double(get(hObject,'String')) returns contents of editBaseHeight as a double

H = str2double(get(handles.editBaseHeight,'String'));
t = str2double(get(handles.editFinThicknessLB,'String'));
d = str2double(get(handles.editMinPitch,'String'));
maxN = H/(t+d);
floor(maxN)
set(handles.textNumFinsUB,'String',num2str(floor(maxN)));
%if(strcmp(get(handles.editFinThicknessUB,'String'),''))
    set(handles.editFinThicknessUB, 'String', get(handles.editBaseHeight,'String'));
%end
set(handles.pushbuttonGO,'Enable','off'); 

% --- Executes during object creation, after setting all properties.
function editBaseHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBaseHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFinLengthLB_Callback(hObject, eventdata, handles)
% hObject    handle to editFinLengthLB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFinLengthLB as text
%        str2double(get(hObject,'String')) returns contents of editFinLengthLB as a double
set(handles.pushbuttonGO,'Enable','off'); 

% --- Executes during object creation, after setting all properties.
function editFinLengthLB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFinLengthLB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTB_Callback(hObject, eventdata, handles)
% hObject    handle to editTB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTB as text
%        str2double(get(hObject,'String')) returns contents of editTB as a double


% --- Executes during object creation, after setting all properties.
function editTB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editFluidTemp_Callback(hObject, eventdata, handles)
% hObject    handle to editFluidTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFluidTemp as text
%        str2double(get(hObject,'String')) returns contents of editFluidTemp as a double


% --- Executes during object creation, after setting all properties.
function editFluidTemp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFluidTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFluidCoeff_Callback(hObject, eventdata, handles)
% hObject    handle to editFluidCoeff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFluidCoeff as text
%        str2double(get(hObject,'String')) returns contents of editFluidCoeff as a double
 

% --- Executes during object creation, after setting all properties.
function editFluidCoeff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFluidCoeff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonLoadFile.
function mat_data = pushbuttonLoadFile_Callback(hObject, eventdata, handles)
%Materials (reads a .csv)
%properties taken from table A1 - Incropera 7th ed.)
%Cost is interpreted as [dollar/kg] 
    %set(handles.pushbuttonCheck,'Enable','on');
    fileName = get(handles.editMaterialsFile, 'String');
    try 
        fileName
        mat_data = importfile(fileName);
        strmsg = strcat('Successfully Loaded:',{' '});
        set(handles.systemMessage,'String',strcat(strmsg,fileName));  
        set(handles.pushbuttonLoadFile,'UserData',[1]);
    catch
        set(handles.pushbuttonLoadFile,'UserData',[0]);
        strmsg = strcat('Error Loading:',{' '});
        set(handles.systemMessage,'String',strcat(strmsg,fileName)); 
    end


function editFinThicknessUB_Callback(hObject, eventdata, handles)
    set(handles.pushbuttonGO,'Enable','off'); 

% --- Executes during object creation, after setting all properties.
function editFinThicknessUB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFinThicknessUB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFinWidthUB_Callback(hObject, eventdata, handles)
% hObject    handle to editFinWidthUB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFinWidthUB as text
%        str2double(get(hObject,'String')) returns contents of editFinWidthUB as a double
set(handles.pushbuttonGO,'Enable','off'); 

% --- Executes during object creation, after setting all properties.
function editFinWidthUB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFinWidthUB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFinThicknessLB_Callback(hObject, eventdata, handles)
% hObject    handle to editFinThicknessLB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFinThicknessLB as text
%        str2double(get(hObject,'String')) returns contents of editFinThicknessLB as a double
H = str2double(get(handles.editBaseHeight,'String'));
t = str2double(get(handles.editFinThicknessLB,'String'));
d = str2double(get(handles.editMinPitch,'String'));
maxN = H/(t+d);
floor(maxN)
set(handles.textNumFinsUB,'String',num2str(floor(maxN)));
set(handles.pushbuttonGO,'Enable','off'); 

% --- Executes during object creation, after setting all properties.
function editFinThicknessLB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFinThicknessLB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFinWidthLB_Callback(hObject, eventdata, handles)
% hObject    handle to editFinWidthLB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFinWidthLB as text
%        str2double(get(hObject,'String')) returns contents of editFinWidthLB as a double
set(handles.pushbuttonGO,'Enable','off'); 

% --- Executes during object creation, after setting all properties.
function editFinWidthLB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFinWidthLB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editMaterialsFile_Callback(hObject, eventdata, handles)
% hObject    handle to editMaterialsFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMaterialsFile as text
%        str2double(get(hObject,'String')) returns contents of editMaterialsFile as a double
set(handles.pushbuttonGO,'Enable','off'); 

% --- Executes during object creation, after setting all properties.
function editMaterialsFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMaterialsFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonCheck.
function pushbuttonCheck_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
all_ok = 1;
%get(handles.pushbuttonLoadFile,'Value')
if ( get(handles.pushbuttonLoadFile,'UserData') == [0])
   all_ok = 0;
   set(handles.systemMessage,'String','No materials file has been loaded!');    
   return
else
    mats = pushbuttonLoadFile_Callback(hObject, eventdata, handles);
end

H = str2double(get(handles.editBaseHeight,'String'));
t = str2double(get(handles.editFinThicknessLB,'String'));
d = str2double(get(handles.editMinPitch,'String'));
maxN = H/(t+d);
floor(maxN)
set(handles.textNumFinsUB,'String',num2str(floor(maxN)));
N_LB = str2double(get(handles.editNumFinsLB,'String'));
N_UB = str2double(get(handles.textNumFinsUB,'String'));
width_LB = str2double(get(handles.editFinWidthLB,'String'));
width_UB = str2double(get(handles.editFinWidthUB,'String'));
thickness_LB = str2double(get(handles.editFinThicknessLB,'String'));
thickness_UB = str2double(get(handles.editFinThicknessUB,'String'));
length_LB = str2double(get(handles.editFinLengthLB,'String'));
length_UB = str2double(get(handles.editFinLengthUB,'String'));
LB = [ N_LB ,  width_LB, thickness_LB , length_LB ,  1,           1          ];   
UB = [ N_UB ,  width_UB, thickness_UB,  length_UB ,  3, size(mats,1)]; 
if(N_UB == 0 || N_LB == 0) %Fin number must be nonzero
   all_ok = 0; 
   set(handles.systemMessage,'String','Fin number LB & UB must be non-zero!');
end
 
if(sum(LB > UB) ~= 0)
   all_ok = 0;
   set(handles.systemMessage,'String','All Upper Bounds must be larger than the Lower Bounds!');
end

% TO DO: CHECK IF ANY TEXTBOX IS EMPTY!


if(all_ok)
    set(handles.systemMessage,'String','Everything seems fine. Hit Go!');
    set(handles.pushbuttonGO,'Enable','on');
else
    set(handles.pushbuttonGO,'Enable','off');    
end
