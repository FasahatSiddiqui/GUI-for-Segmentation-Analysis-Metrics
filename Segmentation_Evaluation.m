function varargout = Segmentation_Evaluation(varargin)
% SEGMENTATION_EVALUATION MATLAB code for Segmentation_Evaluation.fig
%      SEGMENTATION_EVALUATION, by itself, creates a new SEGMENTATION_EVALUATION or raises the existing
%      singleton*.
%
%      H = SEGMENTATION_EVALUATION returns the handle to a new SEGMENTATION_EVALUATION or the handle to
%      the existing singleton*.
%
%      SEGMENTATION_EVALUATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGMENTATION_EVALUATION.M with the given input arguments.
%
%      SEGMENTATION_EVALUATION('Property','Value',...) creates a new SEGMENTATION_EVALUATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Segmentation_Evaluation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Segmentation_Evaluation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Segmentation_Evaluation

% Last Modified by GUIDE v2.5 06-Sep-2021 00:43:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Segmentation_Evaluation_OpeningFcn, ...
                   'gui_OutputFcn',  @Segmentation_Evaluation_OutputFcn, ...
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


% --- Executes just before Segmentation_Evaluation is made visible.
function Segmentation_Evaluation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Segmentation_Evaluation (see VARARGIN)

% Choose default command line output for Segmentation_Evaluation
handles.output = hObject;
ss = ones(300,400);
axes(handles.axes2);
imshow(ss);
axes(handles.axes3);
imshow(ss);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Segmentation_Evaluation wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = Segmentation_Evaluation_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc
[filename, pathname] = uigetfile({'*.*';'*.bmp';'*.jpg';'*.gif'}, 'Pick a Input Image');
i_data = imread([pathname,filename]);
if length(size(i_data))>2
	i_data=rgb2gray(i_data);
end
img_res = imresize(i_data,[256,256]);
axes(handles.axes2);
imshow(img_res);%title('Input Image');
% ss = ones(300,400);
% axes(handles.axes3);
% imshow(ss);
handles.ImgData1 = i_data;
guidata(hObject,handles);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc
[filename, pathname] = uigetfile({'*.*';'*.bmp';'*.jpg';'*.gif'}, 'Pick a semented image');
s_data = imread([pathname,filename]);
seg_res = imresize(s_data,[256,256]);
axes(handles.axes3);
imshow(seg_res);%title('Segmented Image');
% ss = ones(256,256);
% axes(handles.axes2);
% imshow(ss);
handles.ImgData2 = s_data;
guidata(hObject,handles);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Ia=handles.ImgData1;
input_data=Ia;
Is = handles.ImgData2;
Segmented_data=Is;
%%
if length(size(input_data))>2
	input_data=rgb2gray(input_data);
end
input_data=double(input_data);
center = unique(Segmented_data);
cluster_number = length(center);
%MSE
[max_area,n] = size(input_data);
total_pixel=max_area*n;
Segmented_data=double(Segmented_data);
MSE=(minus(input_data,Segmented_data)).^2;
MSE=sum(MSE(:));	
MSE=MSE/total_pixel;	
%%
%region extraction of segmented clusters in an image
Region=0;
Ei_val=0;
cond=-2;
Constant=1./(max_area*n*1000);
Win_segmented=ones(max_area+2,n+2);
Win_input=Win_segmented;
Win_segmented(2:max_area+1,2:n+1)=Segmented_data;   % crop-double(Segmented image) 
Win_input(2:max_area+1,2:n+1)=input_data;           % crop-double(Input image)
Pixels_diff=minus(Win_segmented,Win_input);
Pixels_diff=Pixels_diff.^2;
for z=1:cluster_number
    ti=0;
    [Rc,Rr]=find(Segmented_data==center(z));
    LRf=length(Rc);
    if LRf>0
        Win_eva=ones(max_area+2,n+2);
        Eva_data=ones(max_area,n);
        Eva_data=512*Eva_data;
        Win_eva=512*Win_eva;
        for LRT=1:LRf
            Eva_data(Rc(LRT),Rr(LRT))=-1;
        end
        Win_eva(2:max_area+1,2:n+1)=Eva_data;
     end
     Region_pixels=0;           % OPTIONAL CODE TO DELETE THE HISTORY
     while 1
         [Rc,Rr]=find(Win_eva==-1);
         LRi=length(Rc);
         if LRi==0
             break;
         end
         LRc=Rc(1);
         LRr=Rr(1);
         while 1
             LR=length(LRc);
             if LR>0
                 for LRT=1:LR
                     Win_eva(LRc(LRT),LRr(LRT))=1/0;
                     for X=-1:1
                         for Y=-1:1
                             if Win_eva(LRc(LRT)+X,LRr(LRT)+Y)==-1
                                 Win_eva(LRc(LRT)+X,LRr(LRT)+Y)=cond;
                             end
                         end
                     end
                 end
                 [LRc,LRr]=find(Win_eva==cond);
             end
             if LR==0
                 [LrC,LrR]=find(Win_eva==inf);
                 ti=ti+1;
                 Ei(ti)=sum(Pixels_diff(Win_eva==inf));
                 Win_eva(Win_eva==inf)=712;
                 Region_pixels(ti)=length(LrC);
                 break;
             end
         end
     end
     Region(z,1:ti)=Region_pixels(1,1:ti);            % Region
     Ei_val(z,1:ti)=Ei(1,1:ti);                       % ei.^2
end
%%    
% Evaluated Functions-----------------------------------------------------
[Reg,Ieg]=find(Region>0);
Number_region=length(Reg);              % Number of Regions
%F(I)
Region_area=(Region).^0.5;              % A(i)
Efb=Ei_val./Region_area;                % ei.^2/A(i)
Efb(Region==0)=0;                       % ei.^2/A(i)
sum_constant=sum(Efb(:));               % sum [ei.^2/A(i)]
Efd=(Number_region).^0.5;               % Sqrt of Regions
Function_I=Efd*sum_constant;            % F(I) function
%F'(I)
max_area=max(Region(:));                     % maximum of Area
min_area=min(Region(:));                     % minimum of Area
unique_area=unique(Region(:));               % Distinct number of Area
if min_area==0
    unique_area=unique_area(unique_area>0);  % Removed regions, have no  Area
end
num_unique=length(unique_area);                     % length of regions Area
for Gfg=1:num_unique
    [Gfh,Gfi]=find(Region==unique_area(Gfg));
    region_same=length(Gfh);                    % Region have same Area
    region_Sarea(Gfg)=region_same;              % Regions having same Area 
    Constant2=(1/unique_area(Gfg))+1;           % 1+1/Area
    Gfl(Gfg)=(region_same).^Constant2;          % Regions of same Area with power
end
sum_region=(sum(Gfl(:))).^0.5;                      % Sqrt of sum of Regions
Function_Idash=Constant*sum_region*sum_constant;    % Final outcome from F'(I) function
%Q(I)
Hfa=1+log10(Region);                    % 1+log(A(i))
Hfb=Ei_val./Hfa;                        % e(i).^2/1+log(A(i))
Hfc=(region_Sarea./unique_area').^2;    % [R(A(i))/A(i)].^2  
Hfd=minus(Region,Region);               % Create space matrix
for Hfe=1:num_unique                    % [R(A(i))/A(i).^2] in matrix format
    Hfd(Region==unique_area(Hfe))=Hfc(Hfe);
end 
Hfg=Hfb+Hfd;                            % [e(i).^2/1+log(A(i))] + [R(A(i))/A(i)].^2
Hfm=sum(Hfg(:));
Function_Q=Constant*Efd*Hfm;            % Final outcome of Q(I) function
%%
% Inter Cluster Variance
count=0;
for i=1:cluster_number
    for j=1:cluster_number
        if i~=j
            count=count+1;
            cluster_dist(count)=abs(center(i)-center(j));
        end
    end
end
min_clusdist=min(cluster_dist(:));
INTER=(sum(cluster_dist(:)))./length(cluster_dist);
Result=[MSE,INTER,Function_I,Function_Idash,Function_Q]
set(handles.edit1,'string',MSE);
set(handles.edit2,'string',INTER);
set(handles.edit3,'string',Function_I);
set(handles.edit4,'string',Function_Idash);
set(handles.edit5,'string',Function_Q);
% Update GUI
guidata(hObject,handles);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all;

% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1


% --- Executes on button press in togglebutton2.
function togglebutton2_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton2


% --- Executes on button press in togglebutton3.
function togglebutton3_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton3


% --- Executes on button press in togglebutton4.
function togglebutton4_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton4


% --- Executes on button press in togglebutton5.
function togglebutton5_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton5


% --- Executes on button press in togglebutton6.
function togglebutton6_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton6



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
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


% --- Executes on button press in togglebutton8.
function togglebutton8_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton8


% --- Executes on button press in togglebutton9.
function togglebutton9_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton9
