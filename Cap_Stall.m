function varargout = Cap_Stall(varargin)
% CAP_STALL MATLAB code for Cap_Stall.fig
%      CAP_STALL, by itself, creates a new CAP_STALL or raises the existing
%      singleton*.
%
%      H = CAP_STALL returns the handle to a new CAP_STALL or the handle to
%      the existing singleton*.
%
%      CAP_STALL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CAP_STALL.M with the given input arguments.
%
%      CAP_STALL('Property','Value',...) creates a new CAP_STALL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Cap_Stall_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Cap_Stall_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu_loadresults.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Cap_Stall

% Last Modified by GUIDE v2.5 27-Sep-2017 23:08:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Cap_Stall_OpeningFcn, ...
                   'gui_OutputFcn',  @Cap_Stall_OutputFcn, ...
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


% --- Executes just before Cap_Stall is made visible.
function Cap_Stall_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Cap_Stall (see VARARGIN)

% Choose default command line output for Cap_Stall
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Cap_Stall wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Cap_Stall_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_loaddata_Callback(hObject, eventdata, handles)
% hObject    handle to menu_loaddata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data

% clear Data strutre
if exist('Data','var')
    if isstruct(Data)
        names = fieldnames(Data);
        Data = rmfield(Data,names);
    end
end

pathname = uigetdir('Slect directory for loading data');
Data.pathname = pathname;
files = dir([pathname  '/*_angio.mat']);
load([pathname '/' files(1).name]);
[x,y] = size(angio);
z = length(files);
I = zeros([x y z]);
for  u = 1:z
    load([pathname '/' files(u).name]);
    I(:,:,u) = angio;
end
Data.I = I;
files = dir([pathname  '/*_angioVolume.mat']);
load([pathname '/' files(1).name]);
Data.Volume = angio;
Vz = size(Data.Volume,1);

set(handles.slider_movedata,'max',z);
set(handles.slider_movedata,'min',1);
set(handles.slider_movedata,'Value',1);
set(handles.slider_movedata,'SliderStep',[1/(z-1), 10/(z-1)]);

set(handles.edit_MIPstartidx,'String',num2str(1));
set(handles.edit_MIPnofframes,'String',num2str(Vz));

set(handles.slider_moveinZ,'max',Vz);
set(handles.slider_moveinZ,'min',1);
set(handles.slider_moveinZ,'Value',Vz);
set(handles.slider_moveinZ,'SliderStep',[1/(Vz-1), 10/(Vz-1)]);

img = log(Data.I(:,:,1));
set(handles.edit_MaxI,'String',num2str(max(img(:))));
set(handles.edit_MinI,'String',num2str(min(img(:))));

draw(hObject, eventdata, handles);

function draw(hObject, eventdata, handles)

global Data
I = Data.I;
ii = str2double(get(handles.edit_volnumber,'string'));
MinI = str2double(get(handles.edit_MinI,'String'));
MaxI = str2double(get(handles.edit_MaxI,'String'));
if isfield(Data,'Int_ts')
    cseg = str2double(get(handles.edit_segno,'string'));
else 
    cseg = 0;
end
startidx = str2double(get(handles.edit_MIPstartidx,'String'));
endidx = str2double(get(handles.edit_MIPnofframes,'String'));
set(handles.text2,'String',['to ' num2str(startidx+endidx-1) ' spanning']);
axes(handles.axes1)
colormap('gray');
h = imagesc(log(I(:,:,ii)),[MinI MaxI]);
hold on
if isfield(Data,'Cap')
    for u = 1:size(Data.Cap,1)
        if u == cseg
            hpt = text(Data.Cap(u,2),Data.Cap(u,1),num2str(u),'Color','b','FontSize',10);
        else
            hpt = text(Data.Cap(u,2),Data.Cap(u,1),num2str(u),'Color','g','FontSize',10);
        end
        set(hpt,'ButtonDownFcn', sprintf('Cap_Stall_deletept(%d)',u) );
    end
end
hold off
axis image;
set(h, 'ButtonDownFcn', {@axes1_ButtonDown, handles});
set(gcf, 'WindowScrollWheelFcn', {@axes_WindowScrollWheelFcn, handles},'Interruptible','off');
set(gcf, 'WindowKeyPressFcn', {@figure_WindowKeyPressFcn, handles},'Interruptible','off');

axes(handles.axes2)
colormap('gray');
h2 = imagesc(log(squeeze(max(Data.Volume(startidx:startidx+endidx-1,:,:),[],1))));
hold on
if (get(handles.radiobutton_showseg,'Value') == 1)
    if isfield(Data,'seg')
        jj = str2double(get(handles.edit_segno,'string'));
        plot(Data.seg(jj).pos(:,3),Data.seg(jj).pos(:,2),'r.','markersize',16);
    end
else
    if isfield(Data,'Cap')
        for u = 1:size(Data.Cap,1)
            hpt = text(Data.Cap(u,2),Data.Cap(u,1),num2str(u),'Color','g','FontSize',10);
            set(hpt,'ButtonDownFcn', sprintf('Cap_Stall_deletept(%d)',u) );
        end
    end
    if isfield(Data,'pts')
        for u = 1:size(Data.pts,1)
            hpt1 = text(Data.pts(u,2),Data.pts(u,1),num2str(u),'Color','m','FontSize',10);
            set(hpt1,'ButtonDownFcn', sprintf('Cap_Stall_deleteZpt(%d)',u) );
        end
    end
    
%     if isfield(Data,'pts1')
%         for u = 1:size(Data.pts1,1)
%             hpt1 = text(Data.pts1(u,2),Data.pts1(u,1),num2str(u),'Color','m','FontSize',10);
%             set(hpt1,'ButtonDownFcn', sprintf('Cap_Stall_deleteZpt(%d)',3*u-2) );
%         end
%     end
%     if isfield(Data,'pts2')
%         for u = 1:size(Data.pts2,1)
%             hpt2 = text(Data.pts2(u,2),Data.pts2(u,1),num2str(u),'Color','m','FontSize',10);
%             set(hpt2,'ButtonDownFcn', sprintf('Cap_Stall_deleteZpt(%d)',3*u-1) );
%         end
%     end
%     if isfield(Data,'pts3')
%         for u = 1:size(Data.pts3,1)
%             hpt3 = text(Data.pts3(u,2),Data.pts3(u,1),num2str(u),'Color','b','FontSize',10);
%             set(hpt3,'ButtonDownFcn', sprintf('Cap_Stall_deleteZpt(%d)',3*u) );
%         end
%     end
end
hold off
axis image;
set(h2, 'ButtonDownFcn', {@axes2_ButtonDown, handles});

if isfield(Data,'Int_ts')
    jj = str2double(get(handles.edit_segno,'string'));
    axes(handles.axes3)
    hp = plot(Data.Int_ts(jj,:));
    hold on
    y = ylim;
    x = [ii ii];
    line(x,y);
    if isfield(Data,'StallingPts')
        for uu = 1:length(Data.StallingPts(jj).pos)
            xpt = Data.StallingPts(jj).pos(uu);
            ypt = Data.Int_ts(jj,xpt);
            text(xpt,ypt,'*');
        end
    end
    if isfield(Data,'StallingMatrix')
        xidx = find(Data.StallingMatrix(jj,:) == 1);
        yidx = Data.Int_ts(jj,xidx);
        text(xidx,yidx,'*');
    end
    hold off
    ylim(y);
    set(handles.axes3, 'ButtonDownFcn', {@axes3_ButtonDownFcn, handles});
end

Data.handles =  handles;
Data.hObject =  hObject;
Data.eventdata = eventdata;


%  if isfield(Data,'sliderobject')
%     uicontrol(Data.sliderobject);
% end
% set(handles,'Keypressfcn',@keypressed);
function figure_WindowKeyPressFcn(hObject, eventdata, handles)

global Data

if ~strcmpi(get(gco,'Tag'),'figure1')
    if strcmpi(get(gco,'style'),'edit')
        return;
    end
end

keyPressed = eventdata.Key;
if strcmpi(keyPressed,'space')
    if isfield(Data,'Int_ts')
        jj = str2double(get(handles.edit_segno,'string'));
        ii = str2double(get(handles.edit_volnumber,'string'));
        if isfield(Data,'StallingMatrix')
            if(Data.StallingMatrix(jj,ii) == 0)
                Data.StallingMatrix(jj,ii) = 1;
            else
                Data.StallingMatrix(jj,ii) = 0;
            end
        else
            StallingMatrix = zeros(length(Data.seg),size(Data.I,3));
            StallingMatrix(jj,ii) = 1;
            Data.StallingMatrix = StallingMatrix; 
        end
    end
    draw(hObject, eventdata, handles);
end
if isfield(Data,'sliderobject')
    uicontrol(Data.sliderobject);
end
 


function axes3_ButtonDownFcn(hObject, eventdata, handles)

global Data

parent = (get(hObject, 'Parent'));
mouseclick = get(parent, 'SelectionType');
if strcmp(mouseclick,'normal')
    ii = round(eventdata.IntersectionPoint(1));
    ii = min(max(ii,1),size(Data.I,3));
    set(handles.edit_volnumber,'string',num2str(ii));
    set(handles.slider_movedata,'Value',ii);
    draw(hObject, eventdata, handles);
    if isfield(Data,'sliderobject')
        uicontrol(Data.sliderobject);
    end 
elseif strcmp(mouseclick,'alt')
     ii = round(eventdata.IntersectionPoint(1));
     jj = str2double(get(handles.edit_segno,'string'));
     if isfield(Data,'StallingPts')
         if isfield(Data.StallingPts,'pos')
             Data.StallingPts(jj).pos = [Data.StallingPts(jj).pos; ii];
         else
             Data.StallingPts(jj).pos = ii;
         end
     else 
         stallcount = length(Data.seg);
         Data.StallingPts(stallcount).pos = [];
         Data.StallingPts(jj).pos = ii;
     end
end
draw(hObject, eventdata, handles);
if isfield(Data,'sliderobject')
    uicontrol(Data.sliderobject);
end

function axes_WindowScrollWheelFcn(hObject, eventdata, handles)

global Data

[I_x,I_y,~] = size(Data.I);
[~,V_x,V_y] = size(Data.Volume);
axis1pos = get(handles.axes1, 'CurrentPoint');
axis1pos = axis1pos(1,1:2);
axis2pos = get(handles.axes2,'CurrentPoint');
axis2pos = axis2pos(1,1:2);
axis3pos = get(handles.axes3,'CurrentPoint');
axis3pos = axis3pos(1,1:2);
a3x = handles.axes3.XLim;
a3y = handles.axes3.YLim;
if isfield(Data,'Int_ts')
    cseg = str2double(get(handles.edit_segno,'string'));
else 
    cseg = 0;
end
if  (axis3pos(1) >=a3x(1) && axis3pos(1) <= a3x(2) && axis3pos(2) >=a3y(1) && axis3pos(2) <=a3y(2))
    if eventdata.VerticalScrollCount > 0
        ii = str2num(get(handles.edit_volnumber,'string'));
        ii = min(max(ii+1,1),size(Data.I,3));
        set(handles.edit_volnumber,'string',num2str(ii));
        set(handles.slider_movedata,'Value',ii);
    end
    if eventdata.VerticalScrollCount < 0
        ii = str2num(get(handles.edit_volnumber,'string'));
        ii = min(max(ii-1,1),size(Data.I,3));
        set(handles.edit_volnumber,'string',num2str(ii));
        set(handles.slider_movedata,'Value',ii);
    end
    draw(hObject, eventdata, handles);
    return
end
if (axis1pos(1) >=1 && axis1pos(1) <= I_x && axis1pos(2) >=1 && axis1pos(2) <= I_y)
    MinI = str2double(get(handles.edit_MinI,'String'));
    MaxI = str2double(get(handles.edit_MaxI,'String'));
    if eventdata.VerticalScrollCount > 0
        ii = str2num(get(handles.edit_volnumber,'string'));
        ii = min(max(ii+1,1),size(Data.I,3));
        set(handles.edit_volnumber,'string',num2str(ii));
        set(handles.slider_movedata,'Value',ii);
%         draw(hObject, eventdata, handles);
        axes(handles.axes1)
        colormap('gray');
        h = imagesc(log(Data.I(:,:,ii)),[MinI MaxI]);
        hold on
        if isfield(Data,'Cap')
            for u = 1:size(Data.Cap,1)
                if u == cseg
                    hpt = text(Data.Cap(u,2),Data.Cap(u,1),num2str(u),'Color','b','FontSize',10);
                else
                    hpt = text(Data.Cap(u,2),Data.Cap(u,1),num2str(u),'Color','g','FontSize',10);
                end
                set(hpt,'ButtonDownFcn', sprintf('Cap_Stall_deletept(%d)',u) );
            end
        end
        hold off
        axis image;
        set(h, 'ButtonDownFcn', {@axes1_ButtonDown, handles});
        set(gcf, 'WindowScrollWheelFcn', {@axes_WindowScrollWheelFcn, handles},'Interruptible','off');
        set(gcf, 'WindowKeyPressFcn', {@figure_WindowKeyPressFcn, handles},'Interruptible','off');
    end  
    if eventdata.VerticalScrollCount < 0
        ii = str2num(get(handles.edit_volnumber,'string'));
        ii = min(max(ii-1,1),size(Data.I,3));
        set(handles.edit_volnumber,'string',num2str(ii));
        set(handles.slider_movedata,'Value',ii);
%         draw(hObject, eventdata, handles); 
        axes(handles.axes1)
        colormap('gray');
        h = imagesc(log(Data.I(:,:,ii)),[MinI MaxI]);
        hold on
        if isfield(Data,'Cap')
            for u = 1:size(Data.Cap,1)
                if u == cseg
                    hpt = text(Data.Cap(u,2),Data.Cap(u,1),num2str(u),'Color','b','FontSize',10);
                else
                    hpt = text(Data.Cap(u,2),Data.Cap(u,1),num2str(u),'Color','g','FontSize',10);
                end
                set(hpt,'ButtonDownFcn', sprintf('Cap_Stall_deletept(%d)',u) );
            end
        end
        hold off
        axis image;
        set(h, 'ButtonDownFcn', {@axes1_ButtonDown, handles});
        set(gcf, 'WindowScrollWheelFcn', {@axes_WindowScrollWheelFcn, handles},'Interruptible','off');
        set(gcf, 'WindowKeyPressFcn', {@figure_WindowKeyPressFcn, handles},'Interruptible','off');
    end  
    if isfield(Data,'sliderobject')
        uicontrol(Data.sliderobject);
    end
elseif axis2pos(1) >=1 && axis2pos(1) <= V_x && axis2pos(2) >=1 && axis2pos(2) <= V_y
    if eventdata.VerticalScrollCount > 0
        Vz = size(Data.Volume,1);
        ii = str2double(get(handles.edit_MIPstartidx,'String'));
        jj = str2double(get(handles.edit_MIPnofframes,'String'));
        ii = min(max(ii+1,1),Vz);
        jj = min(max(jj,1),Vz-ii+1);
        set(handles.edit_MIPstartidx,'String',num2str(ii));
        set(handles.edit_MIPnofframes,'String',num2str(jj));
        set(handles.slider_moveinZ,'Value',Vz-ii+1);
        draw(hObject, eventdata, handles);
    end
    if eventdata.VerticalScrollCount < 0
        Vz = size(Data.Volume,1);
        ii = str2double(get(handles.edit_MIPstartidx,'String'));
        jj = str2double(get(handles.edit_MIPnofframes,'String'));
        ii = min(max(ii-1,1),Vz);
        jj = min(max(jj,1),Vz-ii+1);
        set(handles.edit_MIPstartidx,'String',num2str(ii));
        set(handles.edit_MIPnofframes,'String',num2str(jj));
        set(handles.slider_moveinZ,'Value',Vz-ii+1);
        draw(hObject, eventdata, handles);
    end
    if isfield(Data,'sliderobjectZ')
         uicontrol(Data.sliderobjectZ);
    end
end


% pt1 = get(handles.axes1,'Position')






function edit_volnumber_Callback(hObject, eventdata, handles)
% hObject    handle to edit_volnumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_volnumber as text
%        str2double(get(hObject,'String')) returns contents of edit_volnumber as a double

global Data
ii = str2num(get(handles.edit_volnumber,'string'));
ii = min(max(ii,1),size(Data.I,3));
set(handles.edit_volnumber,'string',num2str(ii));
set(handles.slider_movedata,'Value',ii);
draw(hObject, eventdata, handles);
if isfield(Data,'sliderobject')
    uicontrol(Data.sliderobject);
end

% --- Executes during object creation, after setting all properties.
function edit_volnumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_volnumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_moveleft.
function pushbutton_moveleft_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_moveleft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data
ii = str2num(get(handles.edit_volnumber,'string'));
ii = min(max(ii-1,1),size(Data.I,3));
set(handles.edit_volnumber,'string',num2str(ii));
draw(hObject, eventdata, handles);
if isfield(Data,'sliderobject')
    uicontrol(Data.sliderobject);
end

% --- Executes on button press in pushbutton_moveright.
function pushbutton_moveright_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_moveright (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data
ii = str2num(get(handles.edit_volnumber,'string'));
ii = min(max(ii+1,1),size(Data.I,3));
set(handles.edit_volnumber,'string',num2str(ii));
draw(hObject, eventdata, handles);
if isfield(Data,'sliderobject')
    uicontrol(Data.sliderobject);
end


% --- Executes on key press with focus on edit_volnumber and none of its controls.
function edit_volnumber_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to edit_volnumber (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

disp('here');


% --- Executes on slider movement.
function slider_movedata_Callback(hObject, eventdata, handles)
% hObject    handle to slider_movedata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global Data

ii = round(get(hObject,'Value'));
ii = min(max(ii+1,1),size(Data.I,3));
set(handles.edit_volnumber,'string',num2str(ii)); 
Data.sliderobject = hObject;
draw(hObject, eventdata, handles);




% --- Executes during object creation, after setting all properties.
function slider_movedata_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_movedata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
global Data
Data.sliderobject = hObject;


function axes1_ButtonDown(hObject, eventdata, handles)

global Data

parent = (get(hObject, 'Parent'));
pts = round(get(parent, 'CurrentPoint'));
y = pts(1,1);
x = pts(1,2);
if isfield(Data,'Cap')
    Data.Cap = [Data.Cap;x y];
else
    Data.Cap = [x y];
end
draw(hObject, eventdata, handles);
if isfield(Data,'sliderobject')
    uicontrol(Data.sliderobject);
end

function axes2_ButtonDown(hObject, eventdata, handles)

global Data

parent = (get(hObject, 'Parent'));
pts = round(get(parent, 'CurrentPoint'));
y = pts(1,1);
x = pts(1,2);
z = str2double(get(handles.edit_MIPstartidx,'String'));
if isfield(Data,'pts')
    Data.pts = [Data.pts; x y z];
else
    Data.pts = [x y z];
end
% count = 0;
% if isfield(Data,'count')
%     if rem(Data.count,3) == 0
%         if isfield(Data,'pts1')
%             Data.pts1 = [Data.pts1; x y z];
%         else
%             Data.pts1 = [x y z];
%         end
%     end
%     if rem(Data.count,3) == 1
%         if isfield(Data,'pts2')
%             Data.pts2 = [Data.pts2; x y z];
%         else
%             Data.pts2 = [x y z];
%         end
%     end
%     if rem(Data.count,3) == 2
%         if isfield(Data,'pts3')
%             Data.pts3 = [Data.pts3; x y z];
%         else
%             Data.pts3 = [x y z];
%         end
%     end
%     Data.count = Data.count+1;
% else
%     Data.pts1 = [x y z];
%     Data.count = 1;
% end
    
% if isfield(Data,'deletedpts')
%     if(isempty(Data.deletedpts) == 0)
%         if rem(Data.deletedpts(1),3) == 1
%             count = Data.deletedpts(1);
%             Data.deletedpts(1) = [];
%         elseif rem(Data.deletedpts(1),3) == 2
%             count = Data.deletedpts(1);
%             Data.deletedpts(1) = [];
%         elseif rem(Data.deletedpts(1),3) == 0
%             count = Data.deletedpts(1);
%             Data.deletedpts(1) = [];
%         end
%     else
%         if isfield(Data,'count')
%             Data.count = Data.count+1;
%         else
%             Data.count = 1;
%         end
%     end    
% else
%     if isfield(Data,'count')
%         Data.count = Data.count+1;
%     else
%         Data.count = 1;
%     end
% end
% if count == 0
%     if rem(Data.count,3) == 1
%         if isfield(Data,'pts1')
%             Data.pts1 = [Data.pts1; x y z];
%         else
%             Data.pts1 = [x y z];
%         end
%     end
%     if rem(Data.count,3) == 2
%         if isfield(Data,'pts2')
%             Data.pts2 = [Data.pts2; x y z];
%         else
%             Data.pts2 = [x y z];
%         end
%     end
%     if rem(Data.count,3) == 0
%         if isfield(Data,'pts3')
%             Data.pts3 = [Data.pts3; x y z];
%         else
%             Data.pts3 = [x y z];
%         end
%     end
% else 
%     idx = floor((count-1)/3)+1;
%     if rem(count,3) == 1
%         Data.pts1(idx,:) = [x y z];
%     elseif rem(count,3) == 2
%         Data.pts2(idx,:) = [x y z];
%     elseif rem(count,3) == 0
%         Data.pts3(idx,:) = [x y z];
%     end
% end
draw(hObject, eventdata, handles);
if isfield(Data,'sliderobjectZ')
    uicontrol(Data.sliderobjectZ);
end


% --- Executes on slider movement.
function slider_moveinZ_Callback(hObject, eventdata, handles)
% hObject    handle to slider_moveinZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global Data

Vz = size(Data.Volume,1);
ii = Vz-round(get(handles.slider_moveinZ,'Value'))+1;
jj = str2double(get(handles.edit_MIPnofframes,'String'));
ii = min(max(ii,1),Vz);
jj = min(max(jj,1),Vz-ii+1);
set(handles.edit_MIPstartidx,'String',num2str(ii));
set(handles.edit_MIPnofframes,'String',num2str(jj));
Data.sliderobjectZ = hObject;
draw(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function slider_moveinZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_moveinZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
global Data
Data.sliderobjectZ = hObject;



function edit_MIPstartidx_Callback(hObject, eventdata, handles)
% hObject    handle to edit_MIPstartidx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_MIPstartidx as text
%        str2double(get(hObject,'String')) returns contents of edit_MIPstartidx as a double

global Data

Vz = size(Data.Volume,1);
ii = str2double(get(handles.edit_MIPstartidx,'String'));
jj = str2double(get(handles.edit_MIPnofframes,'String'));
ii = min(max(ii,1),Vz);
jj = min(max(jj,1),Vz-ii+1);
set(handles.edit_MIPstartidx,'String',num2str(ii));
set(handles.edit_MIPnofframes,'String',num2str(jj));
set(handles.slider_moveinZ,'Value',Vz-ii+1);
draw(hObject, eventdata, handles);
if isfield(Data,'sliderobjectZ')
    uicontrol(Data.sliderobjectZ);
end


% --- Executes during object creation, after setting all properties.
function edit_MIPstartidx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_MIPstartidx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_MIPnofframes_Callback(hObject, eventdata, handles)
% hObject    handle to edit_MIPnofframes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_MIPnofframes as text
%        str2double(get(hObject,'String')) returns contents of edit_MIPnofframes as a double

global Data

Vz = size(Data.Volume,1);
ii = str2double(get(handles.edit_MIPstartidx,'String'));
jj = str2double(get(handles.edit_MIPnofframes,'String'));
ii = min(max(ii,1),Vz);
jj = min(max(jj,1),Vz-ii+1);
set(handles.edit_MIPstartidx,'String',num2str(ii));
set(handles.edit_MIPnofframes,'String',num2str(jj));
draw(hObject, eventdata, handles);
if isfield(Data,'sliderobjectZ')
    uicontrol(Data.sliderobjectZ);
end



% --- Executes during object creation, after setting all properties.
function edit_MIPnofframes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_MIPnofframes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_SegAnalysis.
function pushbutton_SegAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_SegAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data

I = Data.Volume;
Z = size(Data.I,3);
beta = 100;
c = 500;
[k,l,m] = size(I);
[nz,nx,ny] = size(I);
L   = zeros(k,l,m);
Vs  = zeros(k,l,m);
alpha = 0.25;
gamma12 = 0.5;
gamma23 = 0.5;
T = zeros(k,l,m);
sigma = [2.5];
    for i = 1:length(sigma)
        

        [Dxx, Dyy, Dzz, Dxy, Dxz, Dyz] = Hessian3D(I,sigma(i));

        %Normalizing the Hessian Matrix
        %Dxx = i^2*Dxx; Dyy = i^2*Dyy;  Dzz = i^2*Dzz; Dxy = i^2*Dxy;  Dxz = i^2*Dxz; Dyz = i^2*Dyz;
        
       

        [Lambda1,Lambda2,Lambda3,V1,V2,V3] = eig3volume(Dxx,Dxy,Dxz,Dyy,Dyz,Dzz);
        
        SortL = sort([Lambda1(:)'; Lambda2(:)'; Lambda3(:)'],'descend');
        Lambda1 = reshape(SortL(1,:),size(Lambda1));
        Lambda2 = reshape(SortL(2,:),size(Lambda2));
        Lambda3 = reshape(SortL(3,:),size(Lambda3));
        
        idx = find(Lambda3 < 0 & Lambda2 < 0 & Lambda1 < 0);
        T(idx ) = abs(Lambda3(idx)).*(Lambda2(idx)./Lambda3(idx)).^gamma23.*(1+Lambda1(idx)./abs(Lambda2(idx))).^gamma12;
        idx = find(Lambda3 < 0 & Lambda2 < 0 & Lambda1 > 0 & Lambda1 < abs(Lambda2)/alpha);
        T(idx ) = abs(Lambda3(idx)).*(Lambda2(idx)./Lambda3(idx)).^gamma23.*(1-alpha*Lambda1(idx)./abs(Lambda2(idx))).^gamma12;

%         L1 = (2*Lambda1-Lambda2-Lambda3)./(2*sqrt(Lambda1.^2+Lambda2.^2+Lambda3.^2-Lambda1.*Lambda2-Lambda1.*Lambda3-Lambda2.*Lambda3));
%         L1 = exp(-alpha*(L1-1).^2); 
%         L1(abs(Lambda1)> abs(Lambda2)) = 0;
%         L1(Lambda2>0 | Lambda3>0) = 0;
%         L1 = -L1.*Lambda2;
%         L = max(L,L1); 
% 
%         Ra = abs(Lambda2./Lambda3);
%         Rb = abs(Lambda1./(Lambda2.*Lambda3));
%         s = sqrt(Lambda1.^2+Lambda2.^2+Lambda3.^2);
%         Vs1 = 1-exp(-Ra.^2/(2*alpha)).*exp(-Rb.^2/(2*beta)).*(1-exp(-s.^2/(2*c)));
%         Vs1(Lambda2>0 | Lambda3>0) = 0;
%         Vs1(abs(Lambda1) > abs(Lambda2)) = 0;
%         Vs = max(Vs,Vs1); 
             [Dxx, Dyy, Dzz, Dxy, Dxz, Dyz] = Hessian3D(T,sigma);
        
        [Lambda1,Lambda2,Lambda3,V1,V2,V3] = eig3volume(Dxx,Dxy,Dxz,Dyy,Dyz,Dzz);
        
        SortL = sort([Lambda1(:)'; Lambda2(:)'; Lambda3(:)'],'ascend');
        Lambda1 = reshape(SortL(1,:),size(Lambda1));
        Lambda2 = reshape(SortL(2,:),size(Lambda2));
        Lambda3 = reshape(SortL(3,:),size(Lambda3));
        
        E = -sigma^2.*Lambda2;
        E(E<0) = 0;
    end
%     T = L;
T = E;

T = (T-min(T(:)))*255/(max(T(:))-min(T(:)));

segm = zeros(size(I));
%     if isfield(cna,'Dzz')~= 1
    [Dzz, Dxx, Dyy, Dzx, Dzy, Dxy] = Hessian3D(T,sigma(1));
    [Lambda1,Lambda2,Lambda3,V1,V2,V3] = eig3volume(Dzz,Dzx,Dzy,Dxx,Dxy,Dyy);
    cna.Dzz = Dzz; cna.Dxx = Dxx; cna.Dyy = Dyy; cna.Dzx = Dzx; cna.Dzy = Dzy; cna.Dxy = Dxy;
    Lambda1 = Lambda1; Lambda2 = Lambda2; Lambda3 = Lambda3;
%     else
%        Dzz = cna.Dzz; Dxx = cna.Dxx; Dyy = cna.Dyy; Dzx = cna.Dzx; Dzy = cna.Dzy; Dxy = cna.Dxy;
%        Lambda1 = cna.Lambda1; Lambda2 = cna.Lambda2; Lambda3 = cna.Lambda3; 
%     end
    
    T1 = (T-min(T(:)))/(max(T(:))-min(T(:)));
    T_seg = zeros(size(T));
    idx = find(T1 > 0.075);
    T_seg(idx) = 1;
    
    CC = bwconncomp(T_seg);
    T_segM = T_seg;
    T_cpt = T_seg*0;
    for uuu = 1:length(CC.PixelIdxList)
         if length(CC.PixelIdxList{uuu}) < 100
             T_segM(CC.PixelIdxList{uuu}) = 0;
         end
    end
    
    count  = 0;
    VSidx = find(T_segM == 1);
    seg_no = 0;
    for vv = 1:size(Data.pts,1)
        vv
        seg_no =seg_no+1;

        for direction = 1:2
            z = Data.pts(vv,3);
            x = Data.pts(vv,1);
            y = Data.pts(vv,2);
            xf = x;
            yf = y;
            zf = z;
            coor = zeros([7 3]);
            coor(1,:) = [z x y];
            s = 1;
            BFB = 0;
            BI = 0;

            while 1
                if s==1
    %                 [z x y]
                    M = [ Dzz(z,x,y)  Dzx(z,x,y) Dzy(z,x,y); Dzx(z,x,y) Dxx(z,x,y) Dxy(z,x,y); Dzy(z,x,y)  Dxy(z,x,y) Dyy(z,x,y)];
                    [V,D] = eig(M);
                    D = sum(D,1);
                    [~,id] = min(abs(D));
                    idx = find(abs(D) ~= min(abs(D)));     VD = V(:,id);
                     if s > 1
                        dp = sum(VD.*VP);
                        if   dp < 0
                            VD = -VD;
                        end
                     end
                end
                FS = 2;
                xc = repmat(-FS:FS,[2*FS+1 1]);
                yc = repmat((-FS:FS)',[1 2*FS+1]);
                zc = zeros(2*FS+1,2*FS+1);
                VC = [1;0;0];
                costheta = (VC'*VD)/(norm(VC)*norm(VD));
                sintheta = norm(cross(VC,VD))/(norm(VC)*norm(VD));
                C = cross(VC,VD);
                C = C/norm(C);
                xc = xc(:);
                yc = yc(:);
                zc = zc(:);

                xx = (C(2)^2*xc+C(3)*C(3)*yc+C(2)*C(1)*zc)*(1-costheta)+xc*costheta+(C(3)*zc-C(1)*yc)*sintheta;
                yy = (C(2)*C(3)*xc+C(3)^2*yc+C(3)*C(1)*zc)*(1-costheta)+yc*costheta+(C(1)*xc-C(2)*zc)*sintheta;
                zz= (C(3)*C(1)*xc+C(3)*C(1)*yc+C(3)^2*zc)*(1-costheta)+zc*costheta+(C(2)*yc-C(3)*xc)*sintheta;

                xx = xx+xf;
                yy = yy+yf;
                zz = zz+zf;
                img = zeros(size(xc(:)));

                for u = 1:size(xc(:))
                      img(u) = T(min(max(round(zz(u)),1),nz),min(max(round((xx(u))),1),nx),min(max(round(yy(u)),1),ny));
                %     img(u) = (cna.angio(ceil(zz(u)),ceil(xx(u)),ceil(yy(u)))+cna.angio(floor(zz(u)),floor(xx(u)),floor(yy(u)))+...
                %              cna.angio(ceil(zz(u)),ceil(xx(u)),floor(yy(u)))+cna.angio(ceil(zz(u)),floor(xx(u)),ceil(yy(u)))+...
                %              cna.angio(ceil(zz(u)),floor(xx(u)),floor(yy(u)))+cna.angio(floor(zz(u)),ceil(xx(u)),ceil(yy(u)))+...
                %              cna.angio(floor(zz(u)),ceil(xx(u)),floor(yy(u)))+cna.angio(floor(zz(u)),floor(xx(u)),ceil(yy(u))))/8;
                end

                img = reshape(img,[2*FS+1 2*FS+1]);

                [~,C1idx] = max(squeeze(mean(img,2)));
                [~,C2idx] = max(squeeze(mean(img,1)));
                uidx = sub2ind(size(img),C1idx,C2idx);

                Cz(s) = min(max(round(zz(uidx)),1),nz);
                Cx(s) = min(max(round(xx(uidx)),1),nx);
                Cy(s) = min(max(round(yy(uidx)),1),ny);
                if direction == 1
                    C1z(s) = min(max(round(zz(uidx)),1),nz);
                    C1x(s) = min(max(round(xx(uidx)),1),nx);
                    C1y(s) = min(max(round(yy(uidx)),1),ny);
                end

                segm(Cz(s),Cx(s),Cy(s)) = 1;
                ss= 7;
                surmat = T(min(max(Cz(s)-ss,1),nz):min(max(Cz(s)+ss,1),nz),min(max(Cx(s)-ss,1),nx):min(max(Cx(s)+ss,1),nx),min(max(Cy(s)-ss,1),ny):min(max(Cy(s)+ss,1),ny)) ;
    %            Vidx = find(surmat > 0.1*img(C1idx,C2idx)); 
                Vidx = find(surmat~=0 | surmat==0);
                [Vsub1,Vsub2,Vsub3] = ind2sub(size(surmat),Vidx);
    %            shiftmat = [Cz(s) Cx(s) Cy(s); Cz(s) Cx(s) Cy(s); Cz(s) Cx(s) Cy(s)];
                shiftmat = [repmat(Cz(s),[length(Vsub1) 1]) repmat(Cx(s),[length(Vsub2) 1]) repmat(Cy(s),[length(Vsub3) 1])];

                Vsub = [Vsub1 Vsub2 Vsub3]-ss*ones(size([Vsub1 Vsub2 Vsub3]))+shiftmat;
               tidx = find(Vsub(:,1) < 1 |Vsub(:,1) > nz | Vsub(:,2) < 1 | Vsub(:,2) > nx | Vsub(:,3) < 1 |Vsub(:,3) > ny);
               Vsub(tidx,:,:) = [];
               VFidx = sub2ind(size(T),Vsub(:,1),Vsub(:,2),Vsub(:,3));
    %            Vf1idx = sub2idx(size(T));
               idx_intersect = intersect(VFidx,VSidx);
               idxvaluept = sub2ind(size(T),z,x,y);
    %            
               T_segM([idxvaluept;idx_intersect]) = seg_no;
               VSidx = setdiff(VSidx,[idxvaluept;idx_intersect]);
               if s == 1
                   if direction == 1
                       mask = [idxvaluept;idx_intersect];
                   else 
                       mask = [mask; idxvaluept;idx_intersect];
                   end
               else
                   mask = [mask; idxvaluept;idx_intersect];
               end

               vidx = find(img > 0.3*img(C1idx,C2idx));
               sumArea(s) = length(vidx);
               sumT(s) = img(C1idx, C2idx);

               step = 2;
        %        noRecenter = 0;
               if s>1
                    if sum([Cz(s)-Cz(s-1) Cx(s)-Cx(s-1) Cy(s)-Cy(s-1)])==0
    %                    disp( sprintf('Recenter did not move. prev_step = %d. ',prev_step) )
                       step = prev_step + 1;
        %                noRecenter = 1;
                   end

        %            if VP(1) >= 1/(step+1) && Cz(s) <= Cz(s-1);
        %               
        %                    step = prev_step+1;
        %                   
        %            elseif  VP(1) <= -1/(step+1) && Cz(s) >= Cz(s-1);
        %                     step = prev_step+1;
        %                  
        %            elseif VP(2) >= 1/(step+1) && Cx(s) <= Cx(s-1);
        %                      step = prev_step+1;
        %                    
        %             elseif VP(2) <= -1/(step+1) && Cx(s) >= Cx(s-1);
        %                     step = prev_step+1;
        %                    
        %             elseif VP(3) >= 1/(step+1)&& Cy(s) <= Cy(s-1);
        %                      step = prev_step+1;
        %                     
        %             elseif  VP(3) <= -1/(step+1) && Cy(s) >= Cy(s-1);
        %                     step = prev_step+1;
        %                     
        %             end
               end

               if step > 4
                   BFB = BFB+1;
                   break;
               end
               prev_step = step;

                 M = [ Dzz(Cz(s),Cx(s),Cy(s))  Dzx(Cz(s),Cx(s),Cy(s)) Dzy(Cz(s),Cx(s),Cy(s)); Dzx(Cz(s),Cx(s),Cy(s)) Dxx(Cz(s),Cx(s),Cy(s)) Dxy(Cz(s),Cx(s),Cy(s)); Dzy(Cz(s),Cx(s),Cy(s))  Dxy(Cz(s),Cx(s),Cy(s)) Dyy(Cz(s),Cx(s),Cy(s))];
                   [V,D] = eig(M);
                   D = sum(D,1);
                   [~,id] = min(abs(D));
                   idx = find(abs(D) ~= min(abs(D)));     VD = V(:,id);
                   if s== 1
                       if direction == 2
                           VD = -VD;
                       end
                   end
                   if s > 1
                        dp = sum(VD.*VP);
                        if  dp < 0
                            VD = -VD;
                        end
                   end

                   if s>1
                   VPP = VP;
               end
               VP = VD;
               zf = (Cz(s)+step*VD(1)); z = round(zf);
               xf = (Cx(s)+step*VD(2)); x = round(xf);
               yf = (Cy(s)+step*VD(3)); y = round(yf);
               coor(7,:) = coor(6,:);
               coor(6,:) = coor(5,:);
               coor(5,:) = coor(4,:);
               coor(4,:) = coor(3,:);
               coor(3,:) = coor(2,:);
               coor(2,:) = coor(1,:);
               coor(1,:) = [z x y];

               if z<1 || z>nz || x<1 || x>nx || y<1 || y>ny

    %                disp('out of bounds');
                   break;
               end

               if coor(1,:) == coor(2,:) | coor(1,:) == coor(3,:) | coor(1,:) == coor(4,:) | coor(1,:) == coor(5,:) | coor(1,:) == coor(6,:) | coor(1,:) == coor(7,:)
                   BFB = BFB+1;
                   break;
               end

               lambdasC(:,s) =  [Lambda1(Cz(s),Cx(s),Cy(s)); Lambda2(Cz(s),Cx(s),Cy(s)); Lambda3(Cz(s),Cx(s),Cy(s))];
               if direction ==1
                   lambdasC1(:,s) =  [Lambda1(Cz(s),Cx(s),Cy(s)); Lambda2(Cz(s),Cx(s),Cy(s)); Lambda3(Cz(s),Cx(s),Cy(s))];
               end
               lambdasN(:,s) =  [Lambda1(z,x,y); Lambda2(z,x,y); Lambda3(z,x,y)];

%                dist1 = sqrt((z-Data.pts1(vv,3))^2+(x-Data.pts1(vv,1))^2+(y-Data.pts1(vv,2))^2);
%                dist2 = sqrt((z-Data.pts2(vv,3))^2+(x-Data.pts2(vv,1))^2+(y-Data.pts2(vv,2))^2);
%                if dist1 <= 5 || dist2 <= 5 || s>40
%     %                disp(sprintf('sumT(%d) = %.3f is <= 10', s, sumT(s)));
%                    BI = BI+1;
%                    break;
%                end
                if s > 10
                    break;
                end
               s = s+1;
              

            end  
            if direction ==1
                seg(seg_no).pos = [C1z(end:-1:1)' C1x(end:-1:1)' C1y(end:-1:1)'];
            elseif direction ==2
                seg(seg_no).pos = [seg(seg_no).pos; Cz(1:s)' Cx(1:s)' Cy(1:s)'];
            end
            C1z = []; Cz =[]; C1x = []; Cx =[]; C1y = []; Cy =[];
        end
        seg(seg_no).mask = mask;
    end
    Data.seg = seg;
    
    figure; colormap('gray');
    imagesc(log(squeeze(max(I,[],1)))); 
    hold on
    for uu = 1:length(seg)
        plot(seg(uu).pos(:,3),seg(uu).pos(:,2),'r.','markersize',16);
    end
    hold off
    
   Int_ts = zeros(length(seg),Z);
   slashpos = max(strfind(Data.pathname,filesep));
   datapath = Data.pathname(1:slashpos-1);
   files = dir([datapath '/*_angio.mat']);
   underscorepos = strfind(Data.pathname,'_');
   underscorepos = underscorepos(end-1:end);
   startidx = str2num(Data.pathname(underscorepos(1)+1:underscorepos(2)-1));
   endidx = str2num(Data.pathname(underscorepos(2)+1:end));
       for kk = 1:length(files)
           kk
           load([datapath '/' files(kk).name]);
           angio = angio(startidx:endidx,:,:);
           for ll = 1:length(seg)
               Int_ts(ll,kk) = mean(angio(seg(ll).mask));
           end
       end
   
   Data.Int_ts = Int_ts;
   if isfield(Data,'StallingMatrix')
       Int_rows = size(Data.Int_ts,1);
       Stall_rows = size(Data.StallingMatrix,1);
       stall_cols = size(Data.StallingMatrix,2);
       if Int_rows > Stall_rows
           Data.StallingMatrix = [Data.StallingMatrix; zeros([Int_rows-Stall_rows stall_cols])];
       end
   end
   draw(hObject, eventdata, handles);
    
    
    



function edit_segno_Callback(hObject, eventdata, handles)
% hObject    handle to edit_segno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_segno as text
%        str2double(get(hObject,'String')) returns contents of edit_segno as a double

global Data
jj = str2double(get(handles.edit_segno,'string'));
jj = min(max(jj,1),length(Data.seg));
set(handles.edit_segno,'string',num2str(jj));
draw(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit_segno_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_segno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_prevseg.
function pushbutton_prevseg_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_prevseg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data
jj = str2double(get(handles.edit_segno,'string'));
jj = min(max(jj-1,1),length(Data.seg));
set(handles.edit_segno,'string',num2str(jj));
draw(hObject, eventdata, handles);


% --- Executes on button press in pushbutton_nextseg.
function pushbutton_nextseg_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_nextseg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data
jj = str2double(get(handles.edit_segno,'string'));
jj = min(max(jj+1,1),length(Data.seg));
set(handles.edit_segno,'string',num2str(jj));
draw(hObject, eventdata, handles);


% --- Executes on button press in radiobutton_showseg.
function radiobutton_showseg_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_showseg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_showseg

draw(hObject, eventdata, handles);

% 
% % --- Executes on button press in pushbutton_SaveResults.
% function pushbutton_SaveResults_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbutton_SaveResults (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)





function edit_MaxI_Callback(hObject, eventdata, handles)
% hObject    handle to edit_MaxI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_MaxI as text
%        str2double(get(hObject,'String')) returns contents of edit_MaxI as a double

draw(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit_MaxI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_MaxI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_MinI_Callback(hObject, eventdata, handles)
% hObject    handle to edit_MinI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_MinI as text
%        str2double(get(hObject,'String')) returns contents of edit_MinI as a double

draw(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit_MinI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_MinI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menu_loadResults_Callback(hObject, eventdata, handles)
% hObject    handle to menu_loadResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global Data

[filename, pathname] = uigetfile;
temp_struct = load([pathname filename]);
if isfield(temp_struct,'Cap')
    Data.Cap = temp_struct.Cap;
end
if isfield(temp_struct,'pts')
    Data.pts = temp_struct.pts;
end
if isfield(temp_struct,'seg')
    Data.seg = temp_struct.seg;
end
if isfield(temp_struct,'Int_ts')
    Data.Int_ts = temp_struct.Int_ts;
end
if isfield(temp_struct,'StallingMatrix')
   Data.StallingMatrix = temp_struct.StallingMatrix;
end

draw(hObject, eventdata, handles);


% --------------------------------------------------------------------
function menu_saveresults_Callback(hObject, eventdata, handles)
% hObject    handle to menu_saveresults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data

[filename, pathname] = uiputfile('*.mat');
if isfield(Data,'Cap')
    Cap = Data.Cap;
    save([pathname filename],'Cap');
end
if isfield(Data,'pts')
    pts = Data.pts;
    save([pathname filename],'pts','-append');
end
if isfield(Data,'seg')
    seg = Data.seg;
    save([pathname filename],'seg','-append');
end
if isfield(Data,'Int_ts')
    Int_ts=  Data.Int_ts;
    save([pathname filename],'Int_ts','-append');
end
if isfield(Data,'StallingMatrix')
    StallingMatrix = Data.StallingMatrix;
    save([pathname filename],'StallingMatrix','-append');
end
