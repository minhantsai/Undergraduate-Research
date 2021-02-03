function varargout = myGUI(varargin)
% MYGUI MATLAB code for myGUI.fig
%      MYGUI, by itself, creates a new MYGUI or raises the existing
%      singleton*.
%
%      H = MYGUI returns the handle to a new MYGUI or the handle to
%      the existing singleton*.
%
%      MYGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MYGUI.M with the given input arguments.
%
%      MYGUI('Property','Value',...) creates a new MYGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before myGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to myGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help myGUI

% Last Modified by GUIDE v2.5 09-Nov-2018 14:52:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @myGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @myGUI_OutputFcn, ...
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


% --- Executes just before myGUI is made visible.
function myGUI_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to myGUI (see VARARGIN)

% Choose default command line output for myGUI
handles.output = hObject;
handles.fig_num = 0;
% Update handles structure
guidata(hObject, handles);
if nargin == 3
    initial_dir = pwd;
elseif nargin > 4
    if strcmpi(varargin{1},'dir')
        if exist(varargin{2},'dir')
            initial_dir = varargin{2};
        else
            errordlg('Input argument must be a valid directory','Input Argument Error!')
            return
        end
    else
        errordlg('Unrecognized input argument','Input Argument Error!');
        return;
    end
end
% Populate the listbox
load_listbox(initial_dir,handles)
% Return figure handle as first output argument

% UIWAIT makes myGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% %%%% backimage
% % This creates the 'background' axes
% ha = axes('units','normalized', 'position',[0 0 1 1]);
% % Move the background axes to the bottom
% uistack(ha,'bottom');
% % Load in a background image and display it using the correct colors
% % The image used below, is in the Image Processing Toolbox.  If you do not have %access to this toolbox, you can use another image file instead.
% I=imread('image.jpg');
% hi = imagesc(I);
% colormap gray
% % Turn the handlevisibility off so that we don't inadvertently plot into the axes again
% % Also, make the axes invisible
% set(ha,'handlevisibility','off','visible','off')

%DEFAULT
set(handles.edit1,'String','Untitled'); % for title
set(handles.edit2,'String','10');       % for test time
set(handles.popupmenu1, 'Value', 9);    % for port


% --- Outputs from this function are returned to the command line.
function varargout = myGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%  BUTTON 相關  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in "start".
function buttonSTART_Callback(hObject, eventdata, handles)
%check name and time are set
name = get(handles.edit1,'String');
time = str2num(get(handles.edit2,'String'));
curvename = 'anc';
check = get(handles.checkbox1,'Value');
if isempty(name)
    f = warndlg('please name your plot first','Warning');
    return;
end
pmItems     = get(handles.popupmenu1,'String');
COM = pmItems{get(handles.popupmenu1,'Value')};
s = serial(COM);
set(s,'BaudRate',9600); 
%error handling
try
    fopen(s);
catch
   f = warndlg('please connect arduino or choose correct port','Wrong Port');
end

interval = time*10; 
t = 0;
xdata = 0; 

while(t<interval)
    b = str2num(fgetl(s));

    xdata = [xdata,b];    
    plot(xdata);
    %plot setting
    set(gca,'fontsize',12)               % 座標大小
    xtext=xlabel('Time (s)','FontSize',16);    % x軸文字
    set(xtext, 'Units', 'Normalized', 'Position', [0.5, -0.06, 0]);
    ytext=ylabel('Voltage (V)','FontSize',16); % y軸文字
    set(ytext, 'Units', 'Normalized', 'Position', [-0.07, 0.5, 0]);
    box off;                             % 關閉格線
    t = t+ 1;
    xticklabels(xticks/10);
    drawnow;
end
fclose(s);
xlim([0 interval]);
title(handles.axes1,name,'FontSize',20);
handles.data = xdata;
average = mean(xdata(2:interval));
handles.average = average;
set(handles.text14,'String',num2str(average));
concentration = calibrates(average);
set(handles.text15,'String',num2str(concentration));
guidata(hObject,handles);

% --- Executes on button press in "close".
function buttonCLOSE_Callback(hObject, eventdata, handles)
result=questdlg('確定要關閉?', '關閉', 'yes', 'no', 'no');
if strcmp(result, 'yes')
    close
end

% --- Executes on button press in "OK".
function buttonOK_Callback(hObject, eventdata, handles)
name = get(handles.edit1,'String');
set(handles.text5,'String',name);
time = get(handles.edit2,'String');
handles.name = name;
handles.time = str2num(time);
guidata(hObject,handles);

% --- Executes on button press in "fig".
function buttonFIG_Callback(hObject, eventdata, handles)

name = get(handles.edit1,'String');
title(handles.axes1,name,'FontSize',20);
if isempty(name)
    f = warndlg('please name your plot first','Warning');
    return;
end

filter = {'*.fig';'*.jpg';'*.mat';'*.*'};
[FileName,PathName,filterindex] = uiputfile(filter,'Save as',name);
if isequal(FileName,0) || isequal(PathName,0)
    return;
end
saveDataName = fullfile(PathName,FileName);
ax_old = gca;
f_new = figure;
ax_new = copyobj(ax_old,f_new);
saveas(ax_new, saveDataName, 'fig');
load_listbox(pwd,handles);

% --- Executes on button press in "Excel".
function buttonEXCEL_Callback(hObject, eventdata, handles)
% hObject    handle to buttonEXCEL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
time = str2num(get(handles.edit2,'String'));
name = get(handles.edit1,'String');

filter = {'*.xls'};
[FileName,PathName] = uiputfile(filter,'Save as',name);
data={'Time (sec)', 'Voltage (V)'};
for i=1:time*10
	data{i+1,1}=0.1*i;
	data{i+1,2}=handles.data(i);
end
 	data{time*10+2,1}='average';
 	data{time*10+2,2}= handles.average;
xlswrite([PathName FileName],data);
load_listbox(pwd,handles);

% --- Executes on button press in 'JPG'.
function buttonJPG_Callback(hObject, eventdata, handles)
name = get(handles.edit1,'String');
if isempty(name)
    f = warndlg('please name your plot first','Warning');
    return;
end
filter = {'*.jpg';'*.png';'*.tif'};
[FileName,PathName] = uiputfile(filter,'Save as',name);
  if PathName == 0 %if the user pressed cancelled, then we exit this callback
      return
  end
  haxes=handles.axes1;
  ftmp = figure('visible','off');
  new_axes = copyobj(haxes, ftmp);
  set(new_axes,'Units','normalized','Position',[0.15 0.15 0.75 0.75]);
  saveas(ftmp, fullfile(PathName,FileName));
  delete(ftmp);
  load_listbox(pwd,handles);

% --- Executes on button press in 'reset'.
function buttonRESET_Callback(hObject, eventdata, handles)
cla;
set(handles.edit1,'String','Untitled'); 
set(handles.text5,'String','Untitled');
set(handles.text14,'String','');
set(handles.text15,'String','');

% --- Executes on button press in 'choose dir'.
function buttonDIR_Callback(hObject, eventdata, handles)
% hObject    handle to buttonDIR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selpath = uigetdir;
load_listbox(selpath,handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%  EDIT_BOX 相關  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function edit1_Callback(hObject, eventdata, handles)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit2_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
  new_value = strtrim(get(hObject, 'String'));
  if isempty(new_value)
    new_value = handles.prev_value;
  end
  set(hObject, 'String', new_value);
  handles.prev_value = new_value;
  guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%  CHECK_BOX 相關  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
check = get(hObject,'Value');
if (check)
    hold off;
else
    hold off;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%  下拉選單 相關  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
val = get(handles.popupmenu1,'Value'); %get currently selected option from menu
% Determine the selected data set.
str = get(hObject, 'String');
val = get(hObject,'Value');
% Set current data to the selected data set.
switch str{val};
    case 'COM1' 
       handles.COM = 'COM1';
    case 'COM2' 
       handles.COM = 'COM2';
    case 'COM3' 
       handles.COM = 'COM3';
    case 'COM4' 
       handles.COM = 'COM4';
    case 'COM5' 
       handles.COM = 'COM5';
    case 'COM6' 
       handles.COM = 'COM6';
    case 'COM7' 
       handles.COM = 'COM7';
    case 'COM8' 
       handles.COM = 'COM8';
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%  小工具 相關  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function uipushtool2_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%%%%%%%%%%%%%%%  目錄 相關  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_5_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_6_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_9_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_10_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%%%%%%%%%%%%%%%  LIST_BOX 相關  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2
get(handles.figure1,'SelectionType');
if strcmp(get(handles.figure1,'SelectionType'),'open')
    index_selected = get(handles.listbox2,'Value');
    file_list = get(handles.listbox2,'String');
    filename = file_list{index_selected};
    %如果選到的是資料夾
    if  handles.is_dir(handles.sorted_index(index_selected))
        cd (filename)
        load_listbox(pwd,handles)
    %如果選到的是FILE   
    else
        [path,name,ext] = fileparts(filename);
        switch ext
            case '.fig'
                open (filename)
            otherwise
                try
                    open(filename)
                catch ex
                    errordlg(...
                      ex.getReport('basic'),'File Type Error','modal')
                end
        end
    end
end

% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Read the current directory and sort the names
% ------------------------------------------------------------
function load_listbox(dir_path,handles)
cd (dir_path)
dir_struct = dir(dir_path);
[sorted_names,sorted_index] = sortrows({dir_struct.name}');
handles.file_names = sorted_names;
handles.is_dir = [dir_struct.isdir];
handles.sorted_index = sorted_index;
guidata(handles.figure1,handles)
set(handles.listbox2,'String',handles.file_names,...
	'Value',1)
set(handles.text10,'String',pwd)

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% Add the current directory to the path, as the pwd might change thru' the
% gui. Remove the directory from the path when gui is closed 
% (See figure1_DeleteFcn)
setappdata(hObject, 'StartPath', pwd);
addpath(pwd);


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% Remove the directory added to the path in the figure1_CreateFcn.
if isappdata(hObject, 'StartPath')
    rmpath(getappdata(hObject, 'StartPath'));
end

function concentraion = calibrates(average)
concentraion=0;
