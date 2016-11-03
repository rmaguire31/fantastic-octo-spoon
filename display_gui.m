function display_gui(mbed_path, config_fname, default_capture_fname)
%% DISPLAY_GUI
%
% DESCRIPTION
%   GUI interface to display analysed data and enable user to modify
%   capture settings.
%
% INPUTS
%   mbed_path - Path to MBED file system.
%   config_fname - Name of the capture file read by the microcontroller
%       containing capture definitions.
%   default_capture_fname - Name of the capture file written by the
%       microcontroller and read to extract capture data.
%
% OUTPUTS
%   
%  
% COPYRIGHT (C) Russell Maguire, Imi Ward Parsons, Lauren Miller, Tom Poon
%   2016

% Sanity check inputs.
if nargin < 1 || isempty(mbed_path)
    if isunix()
        mbed_path = ['/media/' getenv('USERNAME') '/MBED/'];
    elseif ispc()
        mbed_path = 'E:\';
    elseif ismac()
        error('TODO(rsm): Someone with a MAC please implement this.');
    end
end
if nargin < 2 || isempty(config_fname)
    config_fname = [mbed_path 'CONFIG.JSN'];
end
if nargin < 3 || isempty(default_capture_fname)
    default_capture_fname = [mbed_path 'CAPTURES.JSN'];
end

if ~exist(mbed_path, 'dir')
    error('display_gui:fileNotFound', 'Unable to find MBED filesystem.');
end

% Initialise configuration with a call to get_config().
get_config(config_fname);

% Initialise GUI interface.
capture_tabgroup = init_gui(...
    @load_capture,...
    @save_capture,...
    @()set_config(config_fname),...
    @close_func...
);
capture_fname = default_capture_fname;
update_capture_tabs(capture_fname, capture_tabgroup);

bytes = 0;
gui_alive = 1;
while (gui_alive)
    drawnow();
%     capture_finfo = dir(default_capture_fname);
%     if isempty(capture_finfo)
%         bytes = 0;
%         
%     elseif capture_finfo.bytes < bytes
%         % New capture has been started.
%         bytes = capture_finfo.bytes;
%         
%     elseif capture_finfo.bytes > bytes
%         % File has been updated.
%         bytes = capture_finfo.bytes;
%         
%         % Update tabs.
%         capture_fname = default_capture_fname;
%         update_capture_tabs(capture_fname, capture_tabgroup);
%     end
end

    function load_capture()
    [fname, path, idx] = uigetfile({'*.json', '*.JSN'}, 'Load Capture');
    if idx > 0
        capture_fname = [fname, path];
        update_capture_tabs(capture_fname, capture_tabgroup);
    end
    end

    function save_capture() 
    while 1
        [fname, path, idx] = uiputfile({'*.json'}, 'Save Capture');
        if idx > 0
            % Save capture file to new location.
            new_capture_fname = [fname, path];
            [success, msg] = copyfile(capture_fname, new_capture_fname);
            
            % Check if copy was successful.
            if ~success
                uiwait(errordlg(msg, 'Save Capture'));
            else
                capture_fname = new_capture_fname;
                break;
            end
        else
            % User cancelled
            break;
        end
    end
    end

    function close_func()
        gui_alive = 0;
    end
end

function capture_tabgroup = init_gui(load_func, save_func, settings_func, close_func)
%% INIT_GUI
%
%
%

% Create figure.
f = figure('Visible', 'off');
f.Name = 'Acceleration Data Capture Program';
f.MenuBar = 'none';
f.ToolBar = 'none';
f.Position(3:4) = [800, 600];
f.DeleteFcn = @(h,data)close_func();

% Options.
option_panel = uipanel(f);
option_panel.Title = 'Options';
option_panel.Position = [0.8 0.01 0.19 0.98];

load_btn = uicontrol(option_panel);
load_btn.String = 'Load';
load_btn.Units = 'normalized';
load_btn.Position = [0.05 0.88 0.9 0.1];
load_btn.Callback = @(h,data)load_func();

save_btn = uicontrol(option_panel);
save_btn.String = 'Save';
save_btn.Units = 'normalized';
save_btn.Position = [0.05 0.755 0.9 0.1];
save_btn.Callback = @(h,data)save_func();

settings_btn = uicontrol(option_panel);
settings_btn.String = 'Settings';
settings_btn.Units = 'normalized';
settings_btn.Position = [0.05 0.63 0.9 0.1];
settings_btn.Callback = @(h,data)settings_func();

% Capture tabs.
capture_tabgroup = uitabgroup(f);
capture_tabgroup.Position = [0.01 0.01 0.8 0.98];

f.Visible = 'on';
end

function update_capture_tabs(capture_fname, capture_tabgroup)
%% UPDATE_CAPTURE_TABS
%
%

% Parse capture file.
try
    raw_captures = jsonload(capture_fname);
catch e
    switch e.identifier
        case {'jsonload:fileNotFound'}
            raw_captures = {};
        otherwise
            rethrow(e);
    end
end

% Postprocess and analyse captures.
captures = cell(size(raw_captures));
for i = 1:length(captures)
    % Process capture.
    captures{i} = struct();
    [
        captures{i}.t,...
        captures{i}.roll,...
        captures{i}.pitch,...
        captures{i}.f,...
        captures{i}.roll_f,...
        captures{i}.pitch_f,...
    ] = postprocess(...
        raw_captures{i}.start_time_s,...
        raw_captures{i}.sample_rate_hz,...
        raw_captures{i}.x,...
        raw_captures{i}.y,...
        raw_captures{i}.z...
    );

    captures{i}.stats = struct();
    % Analyse roll.
    [
        captures{i}.stats.roll_mean,...
        captures{i}.stats.roll_var,...
        captures{i}.stats.roll_peaks,...
        captures{i}.stats.roll_locs,...
        captures{i}.stats.roll_f_peaks,...
        captures{i}.stats.roll_f_locs,...
    ] = analyse(...
        captures{i}.t,...
        captures{i}.roll,...
        captures{i}.f,...
        captures{i}.roll_f...
    );
    % Analyse pitch.
    [
        captures{i}.stats.pitch_mean,...
        captures{i}.stats.pitch_var,...
        captures{i}.stats.pitch_peaks,...
        captures{i}.stats.pitch_locs,...
        captures{i}.stats.pitch_f_peaks,...
        captures{i}.stats.pitch_f_locs,...
    ] = analyse(...
        captures{i}.t,...
        captures{i}.pitch,...
        captures{i}.f,...
        captures{i}.pitch_f...
    );
end

% Remove any existing tabs.
for i = 1:length(capture_tabgroup.Children)
    delete(capture_tabgroup.Children{i});
end

% Display capture data.
if isempty(captures)
    tab = uitab('Parent', []);
    tab.Title = 'New Tab';
    
    msg = uicontrol(tab);
    msg.Style = 'text';
    msg.String = [...
        'Press ''Load'' to load an existing capture file or record a '...
        'new capture by power cycling the MBED.'...
    ];
    msg.Units = 'normalized';
    msg.Position = [0.1, 0.1, 0.8, 0.8];
    msg.HorizontalAlignment = 'center';
    
    tab.Parent = capture_tabgroup;
else
    for i = 1:length(captures)
        % Create a tab for this capture.
        tab = uitab('Parent', []);
        tab.Title = sprintf('Capture %d', i);
        
        % Panel for plots.
        graph_panel = uipanel(tab);
        graph_panel.Title = 'Results';
        graph_panel.Units = 'normalized';
        graph_panel.Position = [0, 0.2, 1, 0.8];
        
        % Time domain.
        t_axes = subplot(2,1,2);
        hold(t_axes, 'on');
        t_axes.Parent = graph_panel;
        traces = [captures{i}.roll, captures{i}.pitch];
        plot(t_axes, captures{i}.t, traces);
        xlabel(t_axes, 'Time (s)');
        ylabel(t_axes, 'Orientation (deg)');
        
        % Roll peak values.
        plot(...
            captures{i}.stats.roll_locs,...
            captures{i}.stats.roll_peaks,...
            'v'...
        );
        text(...
            captures{i}.stats.roll_locs,...
            captures{i}.stats.roll_peaks,...
            num2str((1:numel(captures{i}.stats.roll_peaks))')...
        );
        
        % Pitch peak values.
        plot(...
            captures{i}.stats.pitch_locs,...
            captures{i}.stats.pitch_peaks,...
            'v'...
        );
        text(...
            captures{i}.stats.pitch_locs,...
            captures{i}.stats.pitch_peaks,...
            num2str((1:numel(captures{i}.stats.pitch_peaks))')...
        );
        
        % Frequency domain.
        f_axes = subplot(2,1,1);
        f_axes.Parent = graph_panel;
        traces = [captures{i}.roll_f, captures{i}.pitch_f];
        plot(f_axes, captures{i}.f, traces);
        xlabel(f_axes, 'Frequency (Hz)');
        ylabel(f_axes, 'Power (dB)');
        legend(f_axes, 'Roll', 'Pitch');
            
        % Roll peak frequencies.
        plot(...
            captures{i}.stats.roll_f_locs,...
            captures{i}.stats.roll_f_peaks,...
            'v'...
        );
        text(...
            captures{i}.stats.roll_f_locs,...
            captures{i}.stats.roll_f_peaks,...
            num2str((1:numel(captures{i}.stats.roll_f_peaks))')...
        );
        
        % Pitch peak frequencies.
        plot(...
            captures{i}.stats.pitch_f_locs,...
            captures{i}.stats.pitch_f_peaks,...
            'v'...
        );
        text(...
            captures{i}.stats.pitch_f_locs,...
            captures{i}.stats.pitch_f_peaks,...
            num2str((1:numel(captures{i}.stats.pitch_f_peaks))')...
        );
    
        % Panel for statistics.
        stats_panel = uipanel(tab);
        stats_panel.Title = 'Statistics';
        stats_panel.Units = 'normalized';
        stats_panel.Position = [0, 0, 1, 0.2];
        
        % Roll statistics
        roll_stats = uicontrol(stats_panel);
        roll_stats.Style = 'text';
        roll_stats.String = sprintf(...
            [...
                'Mean Roll: %10g rad\n'...
                'Roll Std Deviation: %10g rad\n'...
                'Peak Roll: %10g Hz\n'...
                'Peak Roll Frequency: %10g Hz'...
            ],...
            captures{i}.stats.roll_mean,...
            sqrt(captures{i}.stats.roll_var),...
            max(captures{i}.stats.roll_peaks),...
            max(captures{i}.stats.roll_f_peaks)...
        );
        roll_stats.Units = 'normalized';
        roll_stats.Position = [0.1, 0.1, 0.4, 0.8];
        roll_stats.HorizontalAlignment = 'left';
        
        % Pitch statistics
        pitch_stats = uicontrol(stats_panel);
        pitch_stats.Style = 'text';
        pitch_stats.String = sprintf(...
            [...
                'Mean Pitch: %10g rad\n'...
                'Pitch Std Deviation: %10g rad\n'...
                'Peak Pitch: %10g Hz\n'...
                'Peak Pitch Frequency: %10g Hz'
            ],...
            captures{i}.stats.pitch_mean,...
            sqrt(captures{i}.stats.pitch_var),...
            max(captures{i}.stats.pitch_peaks),...
            max(captures{i}.stats.pitch_f_peaks)...
        );
        pitch_stats.Units = 'normalized';
        pitch_stats.Position = [0.5, 0.1, 0.4, 0.8];
        pitch_stats.HorizontalAlignment = 'left';
        
        tab.Parent = capture_tabgroup;
    end
end
end

function config = get_config(config_fname)
%% GET_CONFIG
%
%
%

try
    % Parse existing config file.
    config = jsonload(config_fname);
catch e
    module = e.identifier(1:strfind(e.identifier, ':')-1);
    switch module
        case {'jsonload'}
            % Write new config file, populated with some default values.
            config = {};
            config{1} = struct();
            config{1}.start_time_s = 5;
            config{1}.sample_rate_hz = 50;
            config{1}.length = 100;
            jsondump(config, config_fname);
        otherwise
            rethrow(e);
    end
end
end

function set_config(config_fname)
%% SET_CONFIG
%
%
%

% Retrieve current configuration.
config = get_config(config_fname);

% Calculate end times, as these are easier for user to comprehend.
for i = 1:length(config)
    config{i}.end_time_s = ...
        config{i}.start_time_s + config{i}.length/config{i}.sample_rate_hz;
end


prompts = {
    'Capture Start Time (s):',...
    'Capture End Time (s):',...
    'Capture Sample Rate (Hz):',... 
};
dlg_title = 'Settings';
num_lines = [1 40];
defaults = {
    num2str(config{1}.start_time_s),...
    num2str(config{1}.end_time_s),...
    num2str(config{1}.sample_rate_hz),...
};
    
exit_flagS = 0;
while (exit_flagS == 0)

    exit_flagS = 1;
    
    % Creation of the dialog box
    inp = inputdlg(prompts, dlg_title, num_lines, defaults);

    % Assign variables to the inputs from the dialog box
    new_config = {};
    if ~isempty(inp)
        new_config{1} = struct();
        new_config{1}.start_time_s = str2double(inp{1});
        new_config{1}.end_time_s = str2double(inp{2});
        new_config{1}.sample_rate_hz = str2double(inp{3});

        % The following are error messages for incorrect values entered.
        % Users are then given the opportunity to change their entered
        % values.

        % Start Capture time must be greater than or equal to zero
        if new_config{1}.start_time_s < 0
            uiwait(errordlg(...
                'Capture Start Time cannot be negative',...
                'Incorrect Value Entered'...
            ));
            exit_flagS = 0;
        end

        % Make sure End Capture time is larger than the Start Capture Time
        if new_config{1}.end_time_s < new_config{1}.start_time_s
            uiwait(errordlg(...
                'Capture End Time must be greater than Capture Start Time',...
                'Incorrect Value Entered'...
            ));
            exit_flagS = 0;
        end

        % Make sure frequency is greater than zero
        if new_config{1}.sample_rate_hz <= 0
             uiwait(errordlg(...
                 'Capture Sample Rate must be greater than 0',...
                 'Incorrect Value Entered'...
             ));
            exit_flagS = 0;
        end
    end
end

% Use length, not end time as this is easier for the microcontroller to
% parse.
for i = 1:length(new_config)
    new_config{i}.length = floor(...
        (new_config{i}.end_time_s - new_config{i}.start_time_s) *...
        new_config{i}.sample_rate_hz...
    );
    new_config{i} = rmfield(new_config{i}, 'end_time_s');
end
if ~isempty(new_config)
    % Write config file.
    jsondump(new_config, config_fname);
end
end
