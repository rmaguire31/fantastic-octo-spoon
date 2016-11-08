function set_config(config_fname)
%% SET_CONFIG
%
%
%

% Sanity checks.
if nargin < 1
    error('set_config:fileNotFound', 'No filename specified.');
end

% Retrieve current configuration.
config = get_config(config_fname);

% Calculate end times, as these are easier for user to comprehend.
for i = 1:length(config)
    config{i}.end_time_s = ...
        config{i}.start_time_s + config{i}.length/config{i}.sample_rate_hz;
end

% Find out how many captures the user would like to schedule.
inp = inputdlg(...
    {'Number of Captures:'}, 'Settings', [1 40],...
    {num2str(length(config))}...
);
num_captures = 0;
if ~isempty(inp)
    num_captures = str2double(inp{1});
end

% Choose sensible defaults, based on current settings file.
if num_captures > length(config)
    for i = 1+length(config):num_captures
        config{i} = struct();
        config{i}.sample_rate_hz = config{i-1}.sample_rate_hz;
        config{i}.start_time_s = config{i-1}.end_time_s + 1;
        config{i}.end_time_s = config{i}.start_time_s + 2;
    end
else
    config = config(1:num_captures);
end

if num_captures == 1
    % Prompt.
    config{1} = prompt_capture(config{1});
elseif num_captures > 1
    % Keep prompting until user presses Apply (~edit).
    edit = true;
    while edit
        [config, edit] = prompt_config(config);
        if ~edit
            for i = 2:length(config)
                if config{i}.start_time_s <= config{i-1}.end_time_s
                    msg = sprintf(...
                        'Capture %d starts before capture %d ends.',...
                        i, i - 1 ...
                    );
                    uiwait(errordlg(msg, 'Overlapping Captures'));
                    edit = true;
                end
            end
        end
    end
end

% Use length, not end time as this is easier for the microcontroller to
% parse.
for i = 1:length(config)
    config{i}.length = floor(...
        (config{i}.end_time_s - config{i}.start_time_s) *...
        config{i}.sample_rate_hz...
    );
    config{i} = rmfield(config{i}, 'end_time_s');
end
if ~isempty(config)
    % Write config file.
    jsondump(config, config_fname);
end
end

function [config, edit] = prompt_config(config)
%% PROMPT_CONFIG
%
%
%

prompts = cell(length(config), 1);
for i = 1:length(prompts)
    prompts{i} = sprintf(...
        'Start: %d, End: %d, Rate: %d',...
        config{i}.start_time_s,...
        config{i}.end_time_s,...
        config{i}.sample_rate_hz...
    );
end

[idx, edit] = listdlg(...
    'ListString', prompts,...
    'OKString', 'Edit',...
    'CancelString', 'Apply',...
    'SelectionMode', 'single',...
    'ListSize', [220, 300]...
);
if edit && idx <= length(config)
    config{idx} = prompt_capture(config{idx});
end

% Sort config by start time.
sorted_idxs = [];
for i = 1:length(config)
    unsorted_idxs = setdiff(1:length(config), sorted_idxs);
    
    % Find next smallest value.
    sorted_idxs(i) = unsorted_idxs(1);
    for j = unsorted_idxs
        if config{j}.start_time_s < config{sorted_idxs(i)}.start_time_s
            sorted_idxs(i) = j;
        end
    end
end
config = config(sorted_idxs);
end

function capture = prompt_capture(default_capture)
%% PROMPT_CONFIG
%
%
%

prompts = {
    'Capture Start Time (s):',...
    'Capture End Time (s):',...
    'Capture Sample Rate (Hz):',... 
};
dlg_title = 'Settings';
num_lines = [1 40];
defaults = {
    num2str(default_capture.start_time_s),...
    num2str(default_capture.end_time_s),...
    num2str(default_capture.sample_rate_hz),...
};
    
exit_flagS = 0;
while (exit_flagS == 0)

    exit_flagS = 1;
    
    % Creation of the dialog box
    inp = inputdlg(prompts, dlg_title, num_lines, defaults);

    % Assign variables to the inputs from the dialog box
    capture = struct();
    if ~isempty(inp)
        capture.start_time_s = str2double(inp{1});
        capture.end_time_s = str2double(inp{2});
        capture.sample_rate_hz = str2double(inp{3});

        % The following are error messages for incorrect values entered.
        % Users are then given the opportunity to change their entered
        % values.

        % Start Capture time must be greater than or equal to zero
        if capture.start_time_s < 0
            uiwait(errordlg(...
                'Capture Start Time cannot be negative',...
                'Incorrect Value Entered'...
            ));
            exit_flagS = 0;
        end

        % Make sure End Capture time is larger than the Start Capture Time
        if capture.end_time_s < capture.start_time_s
            uiwait(errordlg(...
                'Capture End Time must be greater than Capture Start Time',...
                'Incorrect Value Entered'...
            ));
            exit_flagS = 0;
        end

        % Make sure frequency is greater than zero
        if capture.sample_rate_hz <= 0
             uiwait(errordlg(...
                 'Capture Sample Rate must be greater than 0',...
                 'Incorrect Value Entered'...
             ));
            exit_flagS = 0;
        end
    else
        capture = default_capture;
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
            config{1}.sample_rate_hz = 100;
            config{1}.length = 200;
            jsondump(config, config_fname);
        otherwise
            rethrow(e);
    end
end
end
