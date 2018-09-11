function varargout = emgshow(varargin)
% EMGSHOW MATLAB code for emgshow.fig
%      EMGSHOW, by itself, creates a new EMGSHOW or raises the existing
%      singleton*.
%
%      H = EMGSHOW returns the handle to a new EMGSHOW or the handle to
%      the existing singleton*.
%
%      EMGSHOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EMGSHOW.M with the given input arguments.
%
%      EMGSHOW('Property','Value',...) creates a new EMGSHOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before emgshow_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to emgshow_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help emgshow

% Last Modified by GUIDE v2.5 02-Jan-2017 10:03:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @emgshow_OpeningFcn, ...
                   'gui_OutputFcn',  @emgshow_OutputFcn, ...
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


% --- Executes just before emgshow is made visible.
function emgshow_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to emgshow (see VARARGIN)
index=1;
emgsplit=evalin('base','emgsplit');
emgonset=evalin('base','emgonset');
emgoffset=evalin('base','emgoffset');

slope=evalin('base','slope');
sam_freq=128;
plot(handles.axes1,emgsplit(index,:),'b');
hold(handles.axes1,'on');
onset_camp=mod(emgonset,10)*sam_freq;
h=stem(handles.axes1,onset_camp(index),emgsplit(index,onset_camp(index)),'or');
set(h,'linewidth',3);
result = evalin('base','result');
if result(index) == 1
    legend(handles.axes1,'good');
else
    legend(handles.axes1,'bad');
end
offset_camp=mod(emgoffset,10)*sam_freq;
h=stem(handles.axes1,offset_camp(index),emgsplit(index,offset_camp(index)),'ok');
set(h,'linewidth',3);
hold(handles.axes1,'off');

%Plotting the slope
plot(handles.axes3,slope(index,:),'b');
hold(handles.axes3,'on');
h=stem(handles.axes3,onset_camp(index),slope(index,onset_camp(index)),'or');
set(h,'linewidth',3);
h=stem(handles.axes3,offset_camp(index),slope(index,offset_camp(index)),'ok');
set(h,'linewidth',3);
hold(handles.axes3,'off');

% Choose default command line output for emgshow
handles.output = hObject;
assignin('base','index',index);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes emgshow wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = emgshow_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in back.
function back_Callback(hObject, eventdata, handles)
% hObject    handle to back (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index=evalin('base','index');
emgsplit=evalin('base','emgsplit');
emgonset=evalin('base','emgonset');
emgoffset=evalin('base','emgoffset');
result = evalin('base','result');
slope=evalin('base','slope');
sam_freq=128;
if index>1
    index=index-1;
    hold(handles.axes1,'off');
    plot(handles.axes1,emgsplit(index,:),'b');
    hold(handles.axes1,'on');

    onset_camp=mod(emgonset,10)*sam_freq;

h=stem(handles.axes1,onset_camp(index),emgsplit(index,onset_camp(index)),'or');
set(h,'linewidth',3);
offset_camp=mod(emgoffset,10)*sam_freq;
h=stem(handles.axes1,offset_camp(index),emgsplit(index,offset_camp(index)),'ok');
set(h,'linewidth',3);
if result(index) == 1
    legend(handles.axes1,'good');
else
    legend(handles.axes1,'bad');
end
assignin('base','index',index);
  set(handles.edit1, 'String',index);
  
%Plotting the slope
plot(handles.axes3,slope(index,:),'b');
hold(handles.axes3,'on');
h=stem(handles.axes3,onset_camp(index),slope(index,onset_camp(index)),'or');
set(h,'linewidth',3);
h=stem(handles.axes3,offset_camp(index),slope(index,offset_camp(index)),'ok');
set(h,'linewidth',3);
hold(handles.axes3,'off');

    
end


% --- Executes on button press in forward.
function forward_Callback(hObject, eventdata, handles)
% hObject    handle to forward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index=evalin('base','index');
emgsplit=evalin('base','emgsplit');
emgonset=evalin('base','emgonset');
emgoffset=evalin('base','emgoffset');
result = evalin('base','result');
slope=evalin('base','slope');
sam_freq=128;
if index<size(emgsplit,1)
    index=index+1;
    hold(handles.axes1,'off');
    plot(handles.axes1,emgsplit(index,:),'b');
hold(handles.axes1,'on');
onset_camp=mod(emgonset,10)*sam_freq;
h=stem(handles.axes1,onset_camp(index),emgsplit(index,onset_camp(index)),'or');
set(h,'linewidth',3);
offset_camp=mod(emgoffset,10)*sam_freq;
h=stem(handles.axes1,offset_camp(index),emgsplit(index,offset_camp(index)),'ok');
set(h,'linewidth',3);
if result(index) == 1
    legend(handles.axes1,'good');
else
    legend(handles.axes1,'bad');
end
assignin('base','index',index);
  set(handles.edit1, 'String',index);
  
%Plotting the slope
plot(handles.axes3,slope(index,:),'b');
hold(handles.axes3,'on');
h=stem(handles.axes3,onset_camp(index),slope(index,onset_camp(index)),'or');
set(h,'linewidth',3);
h=stem(handles.axes3,offset_camp(index),slope(index,offset_camp(index)),'ok');
set(h,'linewidth',3);
hold(handles.axes3,'off');
end



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
