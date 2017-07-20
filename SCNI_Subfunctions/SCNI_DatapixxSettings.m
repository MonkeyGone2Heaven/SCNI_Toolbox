%=========================== SCNI_DatapixxSettings.m ===========================
% This function provides a graphical user interface for setting parameters 
% related to the digital and analog I/O channels of DataPixx2. Parameters 
% can be saved and loaded, and the updated parameters are returned in the 
% structure 'Params'.
%
% INPUTS:
%   DefaultInputs: 	optional string containing full path of .mat
%                 	file containing previously saved parameters.
% OUTPUT:
%   Params.DPx.:    Structure containing channel assignments for all 
%                   DataPixx2 channels    
%
%==========================================================================

function ParamsOut = SCNI_DatapixxSettings(ParamsFile, OpenGUI)

persistent Params Fig;

Params.Dir = '/projects/SCNI/SCNI_Datapixx/SCNI_Parameters';
if ismac, Params.Dir = fullfile('/Volumes',Params.Dir); end
if ~exist('ParamsFile','var') || isempty(ParamsFile)
    [~, CompName] = system('hostname');
	CompName(regexp(CompName, '\s')) = [];
    Params.File = fullfile(Params.Dir, sprintf('%s.mat', CompName));
else
    Params.File = ParamsFile;
end
if ~exist('OpenGUI','var')
    OpenGUI = 1;
end
if exist(Params.File,'file')
    Params = load(Params.File);
    if ~isfield(Params,'File')
        Params.File = Params.Params.File;
    end
    if OpenGUI == 0
        ParamsOut = Params;
        return;
    end
end
if ~exist(Params.File,'file') || ~isfield(Params, 'DPx')
    if ~exist(Params.File,'file')
        WarningMsg = sprintf('The parameter file ''%s'' does not exist! Loading default parameters...', Params.File);
    elseif exist(Params.File,'file') && ~isfield(Params, 'DPx')
        WarningMsg = sprintf('The parameter file ''%s'' does not contain DataPixx parameters. Loading default parameters...', Params.File);
    end
    msgbox(WarningMsg,'Parameters not detected!','non-modal')

    Params.DPx.TDTonDOUT        = 1;                                                         % Is DataPixx digital out DB25 connected to TDT digital in DB25?
    Params.DPx.AnalogInCh       = 0:15;
    Params.DPx.AnalogInNames    = {'Left eye X','Left eye Y','Left eye pupil','Right eye X','Right eye Y','Right eye pupil', 'Lever 1', 'Lever 2', 'Photodiode','Scanner TTL', 'None'};
    Params.DPx.AnalogInAssign   = [1,2,3,4,5,6,9,10,11,11,11,11,11,11,11,11];
    Params.DPx.AnalogOutCh      = 0:3;
    Params.DPx.AnalogOutNames   = {'Reward','Audio','None'};
    Params.DPx.AnalogOutAssign  = [1,3,3,3];
    Params.DPx.DigitalInCh      = 0:23;
    Params.DPx.DigitalInNames   = {'Photodiode','Scanner TTL','Spikes','None'};
    Params.DPx.DigitalInAssign  = [1,4,4,4];
    Params.DPx.DigitalOutCh     = 0:23;
    Params.DPx.DigitalOutNames  = {'Reward','TDT port A','TDT port B','TDT port C','None'};
    if Params.DPx.TDTonDOUT == 1
        Params.DPx.DigitalOutAssign = [1,5,5,5,5,5,5,5,5,3,3,3,3,3,3,3,3,4,4,4,4,4,4,4,4];
    end
end


%========================= OPEN GUI WINDOW ================================
Fig.Handle = figure;%(typecast(uint8('ENav'),'uint32'));               	% Assign GUI arbitrary integer        
if strcmp('SCNI_DatapixxSettings', get(Fig.Handle, 'Tag')), return; end	% If figure already exists, return
Fig.FontSize        = 14;
Fig.TitleFontSize   = 16;
Fig.Rect            = [0 200 600 860];                               	% Specify figure window rectangle
Fig.PannelSize      = [170, 650];                                       
Fig.PannelElWidths  = [30, 120];
set(Fig.Handle,     'Name','SCNI: Datapixx settings',...              	% Open a figure window with specified title
                    'Tag','SCNI_DatapixxSettings',...                 	% Set figure tag
                    'Renderer','OpenGL',...                             % Use OpenGL renderer
                    'OuterPosition', Fig.Rect,...                       % position figure window
                    'NumberTitle','off',...                             % Remove figure number from title
                    'Resize', 'off',...                                 % Prevent resizing of GUI window
                    'Menu','none',...                                   % Turn off memu
                    'Toolbar','none');                                  % Turn off toolbars to save space
Fig.Background      = get(Fig.Handle, 'Color');                      	% Get default figure background color
Fig.Margin          = 20;                                             	% Set margin between UI panels (pixels)                                 
Fig.Fields          = fieldnames(Params);                              	% Get parameter field names


%============= CREATE MAIN PANEL
Fig.TopPanelHandle  = uipanel('BackgroundColor',Fig.Background,...       
                    'Units','pixels',...
                    'Position',[20, Fig.Rect(4)-110, Fig.Rect(3)-40, 80],...
                    'Parent',Fig.Handle); 
Fig.Logo            = imread('Logo_VPixx.png');
Fig.LogoAx          = axes('box','off','units','pixels','position', [10, 10, 246, 60],'color',Fig.Background, 'Parent', Fig.TopPanelHandle);
image(Fig.Logo);
axis off;
if ~exist('Datapixx.m','file')
    Params.DPx.Installed = 0;
    Params.DPx.Connected = 0;
else
    Params.DPx.Installed = 1;
    try Datapixx('Open')
        Params.DPx.Connected = 1;
    catch
        Params.DPx.Connected = 0;
    end
end
Fig.MainStrings     = {'DataPixx tools installed?','DataPixx box connected?','TDT connected via DB25?'};
Fig.MainResults     = {Params.DPx.Installed, Params.DPx.Connected, Params.DPx.TDTonDOUT};
Fig.DetectionColors = [1,0,0; 0,1,0];
for n = 1:numel(Fig.MainStrings)
    Ypos = 80-(20*n)-10;
	Fig.Mh(n) = uicontrol('Style', 'checkbox','String',Fig.MainStrings{n},'value', Fig.MainResults{n},'Position', [280,Ypos, 160,20],'Parent',Fig.TopPanelHandle,'HorizontalAlignment', 'left');
    Fig.Mdh(n) = uicontrol('Style', 'text','String','','Position', [450,Ypos+2, 18,18],'Parent',Fig.TopPanelHandle,'HorizontalAlignment', 'left','backgroundcolor', Fig.DetectionColors(Fig.MainResults{n}+1,:));
end
set(Fig.Mh(1:2),'enable','off');
set(Fig.Mh(3), 'callback', {@ToggleTDTconnection});

%======== Set group controls positions
Fig.UnusedChanCol           = [0.5,0.5,0.5];
Fig.UsedChanCol             = [0, 1, 0];
Fig.PannelNames             = {'Analog IN','Analog OUT','Digital IN','Digital OUT'};
Fig.AllPannelChannels       = {'Params.DPx.AnalogInCh','Params.DPx.AnalogOutCh','Params.DPx.DigitalInCh','Params.DPx.DigitalOutCh'};
Fig.AllPannelChannelnames   = {'Params.DPx.AnalogInNames', 'Params.DPx.AnalogOutNames','Params.DPx.DigitalInNames','Params.DPx.DigitalOutNames'};
Fig.AllPannelChannelAssign  = {'Params.DPx.AnalogInAssign','Params.DPx.AnalogOutAssign','Params.DPx.DigitalInAssign','Params.DPx.DigitalOutAssign'};


%============= CREATE PANELS
for p = 1:numel(Fig.PannelNames)
    if p == 1
        BoxXpos(p) 	= Fig.Margin + (Fig.PannelSize(1)+Fig.Margin)*(p-1);
        BoxYpos(p)  = Fig.Rect(4)-450-120;
        PannelSize  = [Fig.PannelSize(1), 450];
    elseif p == 2
        BoxXpos(p) 	= BoxXpos(1);
        BoxYpos(p)  = BoxYpos(1)-180-20;
        PannelSize  = [Fig.PannelSize(1), 180];
    else
      	BoxXpos(p) 	= Fig.Margin + (Fig.PannelSize(1)+Fig.Margin)*(p-2);
        BoxYpos(p)  = Fig.Rect(4)-Fig.PannelSize(2)-120;
        PannelSize  = Fig.PannelSize;
    end
    PannelPos{p}    = [BoxXpos(p), BoxYpos(p), PannelSize]; 
    
    
    Fig.PanelHandle(p) = uipanel( 'Title',Fig.PannelNames{p},...
                    'FontSize',Fig.TitleFontSize,...
                    'BackgroundColor',Fig.Background,...
                    'Units','pixels',...
                    'Position',PannelPos{p},...
                    'Parent',Fig.Handle); 
    
    Ypos         	= PannelPos{p}(4)-Fig.Margin*2.8;
    ChannelList     = eval(Fig.AllPannelChannels{p});               % Get channel numbers for this pannel
    ChannelNames    = eval(Fig.AllPannelChannelnames{p});           % Get I/O names that can be assigned to this pannel
    ChannelAssign   = eval(Fig.AllPannelChannelAssign{p});          % Get channel assignments
    if numel(ChannelAssign) < numel(ChannelList)
        NoneIndx = find(~cellfun(@isempty, strfind(ChannelNames, 'None')));
        ChannelAssign(end+1:numel(ChannelList)) = NoneIndx;
        eval(sprintf('%s = ChannelAssign;', Fig.AllPannelChannelAssign{p}));
    end
    
    %============= CREATE FIELDS
    for n = 1:numel(ChannelList)
        Fig.ChH(p,n) = uicontrol('Style', 'text','String',num2str(ChannelList(n)),'Position', [Fig.Margin,Ypos,Fig.PannelElWidths(1),20],'Parent',Fig.PanelHandle(p),'HorizontalAlignment', 'left');
        Fig.h(p,n) = uicontrol('Style', 'popup','String',ChannelNames,'value', ChannelAssign(n), 'Position', [Fig.PannelElWidths(1)+10,Ypos,Fig.PannelElWidths(2),20],'Parent',Fig.PanelHandle(p),'HorizontalAlignment', 'left','Callback',{@ChannelUpdate,p,n});
        if strfind(ChannelNames{ChannelAssign(n)}, 'None')
            set(Fig.ChH(p,n), 'BackgroundColor', Fig.UnusedChanCol);
        else
            set(Fig.ChH(p,n), 'BackgroundColor', Fig.UsedChanCol);
        end
        Ypos = Ypos-25;
    end
%     set(h(1:numel(SystemLabels)), 'BackgroundColor', Fig.Background);

end
if Params.DPx.TDTonDOUT == 1
    set(Fig.h(4,10:24), 'enable','off','TooltipString','Digital outs 9-23 in use for TDT communciation');    
end


%================= OPTIONS PANEL
uicontrol(  'Style', 'pushbutton',...
            'String','Load',...
            'parent', Fig.Handle,...
            'tag','Load',...
            'units','pixels',...
            'Position', [Fig.Margin,20,100,30],...
            'TooltipString', 'Use current inputs',...
            'FontSize', Fig.FontSize, ...
            'HorizontalAlignment', 'left',...
            'Callback', {@OptionSelect, 1});   
uicontrol(  'Style', 'pushbutton',...
            'String','Save',...
            'parent', Fig.Handle,...
            'tag','Save',...
            'units','pixels',...
            'Position', [140,20,100,30],...
            'TooltipString', 'Save current inputs to file',...
            'FontSize', Fig.FontSize, ...
            'HorizontalAlignment', 'left',...
            'Callback', {@OptionSelect, 2});    
uicontrol(  'Style', 'pushbutton',...
            'String','Continue',...
            'parent', Fig.Handle,...
            'tag','Continue',...
            'units','pixels',...
            'Position', [260,20,100,30],...
            'TooltipString', 'Exit',...
            'FontSize', Fig.FontSize, ...
            'HorizontalAlignment', 'left',...
            'Callback', {@OptionSelect, 3});         

hs = guihandles(Fig.Handle);                                % get UI handles
guidata(Fig.Handle, hs);                                    % store handles
set(Fig.Handle, 'HandleVisibility', 'callback');            % protect from command line
drawnow;
% uiwait(Fig.Handle);
ParamsOut = Params;




%% ========================= UICALLBACK FUNCTIONS =========================
    function ChannelUpdate(hObj, Evnt, Indx1, Indx2)
 
        %========== Update channel color code
        Selection = get(hObj, 'value');
        Channelnames = eval(Fig.AllPannelChannelnames{Indx1});
        if strcmp(Channelnames{Selection},'None')
            set(Fig.ChH(Indx1, Indx2), 'BackgroundColor', Fig.UnusedChanCol);
        else
            set(Fig.ChH(Indx1, Indx2), 'BackgroundColor', Fig.UsedChanCol);
        end
        
        %========== Update params
        switch Indx1 
            case 1  %========= ANALOG IN
                Params.DPx.AnalogInAssign(Indx2) = Selection;
                
            case 2  %========= ANALOG OUT
                Params.DPx.AnalogOutAssign(Indx2) = Selection;
                
            case 3  %========= DIGITAL IN
                Params.DPx.DigitalInAssign(Indx2) = Selection;
                
            case 4  %========= DIGITAL OUT
                Params.DPx.DigitalOutAssign(Indx2) = Selection;
                
        end
       
    end

    %==================== TDT connected to digital out
    function ToggleTDTconnection(Obj, Event, Indx)
        Params.DPx.TDTonDOUT = get(Obj, 'value');
        set(Fig.Mdh(3),'backgroundcolor', Fig.DetectionColors(Params.DPx.TDTonDOUT+1,:));
        if Params.DPx.TDTonDOUT == 1
            Params.DPx.DigitalOutAssign(10:17) = find(~cellfun(@isempty, strfind(Params.DPx.DigitalOutNames, 'TDT port B')));
            Params.DPx.DigitalOutAssign(18:24) = find(~cellfun(@isempty, strfind(Params.DPx.DigitalOutNames, 'TDT port C')));
            set(Fig.ChH(4,10:24), 'BackgroundColor', Fig.UsedChanCol);
            set(Fig.h(4,10:17), 'value', Params.DPx.DigitalOutAssign(10));
            set(Fig.h(4,18:24), 'value', Params.DPx.DigitalOutAssign(18));
            set(Fig.h(4,10:24), 'enable','off','TooltipString','Digital outs 9-23 in use for TDT communciation'); 
        else
            set(Fig.h(4,10:24), 'enable','on','TooltipString','');
        end
    end

    %==================== OPTIONS
    function OptionSelect(Obj, Event, Indx)

        switch Indx
            case 1      %================ LOAD PARAMETERS FILE
                [Filename, Pathname, Indx] = uigetfile('*.mat','Load parameters file', Params.Dir);
                Params.File = fullfile(Pathname, Filename);
                SCNI_DatapixxSettings(Params.File);

            case 2      %================ SAVE PARAMETERS TO FILE
                if exist(Params.File,'file')
                    ButtonName = questdlg(sprintf('A parameters file named ''%s'' already exists. Would you like to overwrite that file?', Params.File), ...
                         'File already exists!', ...
                         'Overwrite', 'Rename', 'Cancel', 'Overwrite');
                     if strcmp(ButtonName,'Cancel')
                         return;
                     end
                end
                [Filename, Pathname, Indx] = uiputfile('*.mat','Save parameters file', Params.File);
                if Filename == 0
                    return;
                end
                Params.File = fullfile(Pathname, Filename);
                DPx     = Params.DPx;
                File    = Params.File;
                if exist(Params.File, 'file')
                    save(Params.File, 'DPx','File','-append');
                elseif ~exist(Params.File, 'file')
                    save(Params.File, 'DPx','File');
                end
                msgbox(sprintf('Parameters file saved to ''%s''!', Params.File),'Saved');

            case 3      %================ CLOSE PARAMETERS GUI
                ParamsOut = [];         % Clear params
                close(Fig.Handle);      % Close GUI figure
                return;
        end
    end

end