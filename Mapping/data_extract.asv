function varargout = data_extract(varargin)
% DATA_EXTRACT M-file for data_extract.fig
%      DATA_EXTRACT, by itself, creates a new DATA_EXTRACT or raises the existing
%      singleton*.
%
%      H = DATA_EXTRACT returns the handle to a new DATA_EXTRACT or the handle to
%      the existing singleton*.
%
%      DATA_EXTRACT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATA_EXTRACT.M with the given input arguments.
%
%      DATA_EXTRACT('Property','Value',...) creates a new DATA_EXTRACT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before data_extract_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to data_extract_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help data_extract

% Last Modified by GUIDE v2.5 06-Dec-2010 11:58:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @data_extract_OpeningFcn, ...
                   'gui_OutputFcn',  @data_extract_OutputFcn, ...
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


% --- Executes just before data_extract is made visible.
function data_extract_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to data_extract (see VARARGIN)

% Choose default command line output for data_extract
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes data_extract wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = data_extract_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in epocList.
function epocList_Callback(hObject, eventdata, handles)
% hObject    handle to epocList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns epocList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from epocList
	[selectedValue,noMoreValues] = takeSelectValueFromList(handles.epocList,0);
    serverName = get(handles.activex3, 'UseServer');
    tankName = get(handles.activex3, 'UseTank');
    blockName = get(handles.activex3, 'activeBlock');
	if strcmp(selectedValue{1}, 'Channel') == 0
        [epocValues,epocTimes,epocIsEmpty] = getEpocValues(serverName, tankName, blockName, selectedValue{1});
        if epocIsEmpty == 1
            set(handles.epocInfo, [strcat('Epoc: ', selectedValue),'Epoc is empty']);
        else
            set(handles.epocInfo, 'String',[strcat('Epoc: ', selectedValue),strcat('Max = ', num2str(max(epocValues)), '; Min = ', num2str(min(epocValues))), mat2str(epocValues)]);
        end
    else
        set(handles.epocInfo, 'String',[strcat('Artifical Epoc: ', selectedValue),'Used to artificially generate a list of channel numbers']);
    end



% --- Executes during object creation, after setting all properties.
function epocList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epocList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in otherGroupingsList.
function otherGroupingsList_Callback(hObject, eventdata, handles)
% hObject    handle to otherGroupingsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns otherGroupingsList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from otherGroupingsList


% --- Executes during object creation, after setting all properties.
function otherGroupingsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to otherGroupingsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in setToXAxis.
function setToXAxis_Callback(hObject, eventdata, handles)
% hObject    handle to setToXAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [selectedValue,noMoreValues] = takeSelectValueFromList(handles.epocList,1);
    set(handles.xAxisEpoc, 'String', selectedValue);
    set(handles.xAxisEpoc, 'Enable', 'on');
    refreshButtonStates(handles);
    clear selectedValue
    clear noMoreValues;


% --- Executes on button press in setToYAxis.
function setToYAxis_Callback(hObject, eventdata, handles)
% hObject    handle to setToYAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [selectedValue,noMoreValues] = takeSelectValueFromList(handles.epocList,1);
    set(handles.yAxisEpoc, 'String', selectedValue);
    set(handles.yAxisEpoc, 'Enable', 'on');
    refreshButtonStates(handles);
    clear selectedValue
    clear noMoreValues;

% --- Executes on button press in removeFromXAxis.
function removeFromXAxis_Callback(hObject, eventdata, handles)
% hObject    handle to removeFromXAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.xAxisEpoc, 'Enable', 'off');
    xAxisEpocValue = get(handles.xAxisEpoc, 'String');
    set(handles.xAxisEpoc, 'String', '');
    addValueToList(handles.epocList, xAxisEpocValue);
    refreshButtonStates(handles);
    clear xAxisEpocValue;
    clear epocListValues;


% --- Executes on button press in removeFromYAxis.
function removeFromYAxis_Callback(hObject, eventdata, handles)
% hObject    handle to removeFromYAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.yAxisEpoc, 'Enable', 'off');
    yAxisEpocValue = get(handles.yAxisEpoc, 'String');
    set(handles.yAxisEpoc, 'String', '');
    addValueToList(handles.epocList, yAxisEpocValue);
    refreshButtonStates(handles);
    clear yAxisEpocValue;
    clear epocListValues;

% --- Executes on button press in addToOtherGroupings.
function addToOtherGroupings_Callback(hObject, eventdata, handles)
% hObject    handle to addToOtherGroupings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [selectedValue,noMoreValues] = takeSelectValueFromList(handles.epocList,1);
    addValueToList(handles.otherGroupingsList, selectedValue);
    set(handles.otherGroupingsList, 'Enable', 'on');
    refreshButtonStates(handles);
    clear selectedValue;
    clear noMoreValues;

% --- Executes on button press in removeFromOtherGroupings.
function removeFromOtherGroupings_Callback(hObject, eventdata, handles)
% hObject    handle to removeFromOtherGroupings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [selectedValue,noMoreValues] = takeSelectValueFromList(handles.otherGroupingsList,1);
    addValueToList(handles.epocList, selectedValue);
    if noMoreValues == 1
        set(handles.otherGroupingsList, 'Enable', 'off');
    end
    refreshButtonStates(handles);
    clear selectedValue;
    clear noMoreValues;


% --- Executes on selection change in snippetEpocCombo.
function snippetEpocCombo_Callback(hObject, eventdata, handles)
% hObject    handle to snippetEpocCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns snippetEpocCombo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from snippetEpocCombo


% --- Executes during object creation, after setting all properties.
function snippetEpocCombo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to snippetEpocCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function activex1_ServerChanged(hObject, eventdata, handles)
% hObject    handle to activex1 (see GCBO)
% eventdata  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)
set(handles.activex2, 'UseServer', eventdata.NewServer);
handles.activex2.Refresh;


% --------------------------------------------------------------------
function activex2_TankChanged(hObject, eventdata, handles)
% hObject    handle to activex2 (see GCBO)
% eventdata  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)
set(handles.activex3, 'UseServer', eventdata.ActServer);
set(handles.activex3, 'UseTank', eventdata.ActTank);
handles.activex3.Refresh;

% --------------------------------------------------------------------
function activex3_BlockChanged(hObject, eventdata, handles)
% hObject    handle to activex3 (see GCBO)
% eventdata  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)
buildEpocLists(eventdata.ActServer, eventdata.ActTank, eventdata.ActBlock, handles);
clearFields(handles);
set(handles.epocList, 'Enable', 'on');
set(handles.snippetEpocCombo, 'Enable', 'on');
refreshButtonStates(handles);


% --- Executes on button press in extractData.
function extractData_Callback(hObject, eventdata, handles)
% hObject    handle to extractData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA) 


% --- Executes during object creation, after setting all properties.
function epocInfo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epocInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function epocInfo_Callback(hObject, eventdata, handles)
% hObject    handle to epocInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of epocInfo as text
%        str2double(get(hObject,'String')) returns contents of epocInfo as a double
    

% --- Executes on button press in setReferenceEpoc.
function setReferenceEpoc_Callback(hObject, eventdata, handles)
% hObject    handle to setReferenceEpoc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [selectedValue,noMoreValues] = takeSelectValueFromList(handles.epocList,0);
    if strcmp(selectedValue,'Channel') == 0
        set(handles.referenceEpoc, 'String', selectedValue);
        set(handles.referenceEpoc, 'Enable', 'on');
        refreshButtonStates(handles);
    end
    clear selectedValue
    clear noMoreValues;

% --- Executes on button press in removeReferenceEpoc.
function removeReferenceEpoc_Callback(hObject, eventdata, handles)
% hObject    handle to removeReferenceEpoc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.referenceEpoc, 'Enable', 'off');
    set(handles.referenceEpoc, 'String', '');
    refreshButtonStates(handles);
    clear xAxisEpocValue;
    clear epocListValues;

    
    


% --- Executes on button press in xInvert.
function xInvert_Callback(hObject, eventdata, handles)
% hObject    handle to xInvert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of xInvert


% --- Executes on button press in yInvert.
function yInvert_Callback(hObject, eventdata, handles)
% hObject    handle to yInvert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of yInvert


% --- Executes on button press in forceXYEntries.
function forceXYEntries_Callback(hObject, eventdata, handles)
% hObject    handle to forceXYEntries (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of forceXYEntries


function buildEpocLists(serverName, tankName, blockName, handles)
EVTYPE_STRON = hex2dec('101');
EVTYPE_SNIP = hex2dec('8201');

TT = actxserver('TTank.X');
TT.ConnectServer(serverName,'Me');
TT.OpenTank(tankName,'R');
TT.SelectBlock(blockName);
TT.CreateEpocIndexing;

evtCodes = TT.GetEventCodes(EVTYPE_STRON);

epocListItems = cell(length(evtCodes)+1,1);
epocListIsEmpty = 1;
for evtCodeIndex = 1:length(evtCodes)
    evtString = TT.CodeToString(evtCodes(evtCodeIndex));
    evtValues = TT.GetEpocsV(evtString,0,0,1);
    if length(evtValues) > 1 %returns 1 if no events were returned
        epocListItems{evtCodeIndex} = evtString;
        epocListIsEmpty = 0;
    end
end
if epocListIsEmpty == 1
    epocListItems = {'None'};
else
    epocListItems{length(evtCodes)+1} = 'Channel';
    epocListItems(cellfun(@isempty,epocListItems)) = [];
end
set(handles.epocList,'String',unique(epocListItems));

clear evtCodes;
clear epocListIsEmpty;
clear evtCodeIndex;
clear evtString;
clear evtValues;

snipCodes = TT.GetEventCodes(EVTYPE_SNIP);

snipItems = cell(length(snipCodes),1);
for snipCodeIndex = 1:length(snipCodes)
    snipString = TT.CodeToString(snipCodes(snipCodeIndex));
	snipListItems{snipCodeIndex} = snipString;
end
set(handles.snippetEpocCombo,'String',snipListItems);

clear snipCodes;
clear snipCodeIndex;
clear snipString;

TT.CloseTank
TT.ReleaseServer

function [selectedValue,noMoreValues] = takeSelectValueFromList(hObject,removeItem)
    selectedIndex = get(hObject, 'Value');
    if removeItem == 1
        set(hObject, 'Value',1);
    end
    values = get(hObject, 'String');
    if iscell(values)
        selectedValue = values(selectedIndex);
        if removeItem == 1
            values(selectedIndex) = [];
        end
    else
        selectedValue = values;
        if removeItem == 1
            values = {};
        end
    end
    if length(values) > 1
        set(hObject, 'String', sort(values));
    else
        if isempty(values)
            set(hObject, 'String','');
        else
            set(hObject, 'String', values{1});
        end
    end
    if length(values) < 1
        noMoreValues = 1;
    else
        noMoreValues = 0;
    end
    
    clear selectedIndex;
    clear values;
    
function addValueToList(hObject, newValue)
    values = get(hObject, 'String');
    valueToInsert = cell(1,1);
    if iscell(newValue) == 0
        valueToInsert = {newValue};
    else
        valueToInsert = newValue;
    end
    if isempty(values)
        values = valueToInsert;
    else
       if iscell(values) == 0
            values = {values,valueToInsert{1}};
       else
            values(end + 1) = valueToInsert(1);
       end
    end
%    if iscell(values)
%        values(end + 1) = valueToInsert(1);
%    else
%        values = valueToInsert;
%    end
    
    if length(values) > 1
        set(hObject, 'String', sort(values));
    else
        set(hObject, 'String', values{1});
    end
%
function refreshButtonStates(handles)    
    if checkHasValue(handles.otherGroupingsList) == 1
        set(handles.removeFromOtherGroupings, 'Enable', 'on');
    else
        set(handles.removeFromOtherGroupings, 'Enable', 'off');
    end
    
    if checkHasValue(handles.xAxisEpoc) == 1
        set(handles.setToXAxis, 'Enable', 'off');
        set(handles.removeFromXAxis, 'Enable', 'on');
    else
        set(handles.setToXAxis, 'Enable', 'on');
        set(handles.removeFromXAxis, 'Enable', 'off');
    end
    
    if checkHasValue(handles.yAxisEpoc) == 1
        set(handles.setToYAxis, 'Enable', 'off');
        set(handles.removeFromYAxis, 'Enable', 'on');
    else
        set(handles.setToYAxis, 'Enable', 'on');
        set(handles.removeFromYAxis, 'Enable', 'off');

    end

    if checkHasValue(handles.referenceEpoc) == 1
        set(handles.setReferenceEpoc, 'Enable', 'off');
        set(handles.removeReferenceEpoc, 'Enable', 'on');
    else
        set(handles.setReferenceEpoc, 'Enable', 'on');
        set(handles.removeReferenceEpoc, 'Enable', 'off');
    end
    
	if checkHasValue(handles.epocList) == 1
        if checkHasValue(handles.xAxisEpoc) == 0
            set(handles.setToXAxis, 'Enable', 'on');
        end
        if checkHasValue(handles.yAxisEpoc) == 0
            set(handles.setToYAxis, 'Enable', 'on');
        end
        if checkHasValue(handles.referenceEpoc) == 0
            set(handles.setReferenceEpoc, 'Enable', 'on');
        end
        set(handles.addToOtherGroupings, 'Enable', 'on');
    else
        set(handles.setToXAxis, 'Enable', 'off');
        set(handles.setToYAxis, 'Enable', 'off');
        set(handles.setReferenceEpoc, 'Enable', 'off');
        set(handles.addToOtherGroupings, 'Enable', 'off');
    end
    
%
function hasValue = checkHasValue(hObject)
    values = get(hObject, 'String');
	if isempty(values) == 1;
    	hasValue = 0;
    else
        hasValue = 1;
    end

%
function [epocValues,epocTimes,epocIsEmpty] = getEpocValues(serverName, tankName, blockName, epocName)
    TT = actxserver('TTank.X');
    TT.ConnectServer(serverName,'Me');
    TT.OpenTank(tankName,'R');
    TT.SelectBlock(blockName);
    TT.CreateEpocIndexing;

    evtValues = TT.GetEpocsV(epocName,0,0,10000);
    if length(evtValues) > 1 %returns 1 if no events were returned
    	epocValues = unique(evtValues(1,:));
        epocTimes = unique(evtValues(2,:));
        epocIsEmpty = 0;
    else
        epocIsEmpty = 1;
    end
    clear evtValues;
    TT.CloseTank
    TT.ReleaseServer
%
function clearFields(handles)
    set(handles.xAxisEpoc,'String','');
    set(handles.yAxisEpoc,'String','');
    set(handles.referenceEpoc,'String','');
    set(handles.otherGroupingsList,'Value', 1);
    set(handles.otherGroupingsList,'String',{});
    
%
function epocOffset_Callback(hObject, eventdata, handles)
% hObject    handle to epocOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of epocOffset as text
%        str2double(get(hObject,'String')) returns contents of epocOffset as a double


% --- Executes during object creation, after setting all properties.
function epocOffset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epocOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stimDuration_Callback(hObject, eventdata, handles)
% hObject    handle to stimDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stimDuration as text
%        str2double(get(hObject,'String')) returns contents of stimDuration as a double


% --- Executes during object creation, after setting all properties.
function stimDuration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stimDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in minChannel.
function minChannel_Callback(hObject, eventdata, handles)
% hObject    handle to minChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns minChannel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from minChannel


% --- Executes during object creation, after setting all properties.
function minChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
