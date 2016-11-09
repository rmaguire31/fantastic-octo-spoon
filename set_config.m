function set_config(config_fname)
%% SET_CONFIG
%
% DESCRIPTION
%   Settings file is constructed to enable multiple captures and permit
%   parameter changes.

% INPUTS
%   config_fname - Settings file reference.
%
% COPYRIGHT (C) Russell Maguire, Imi Ward Parsons, Lauren Miller, Tom Poon
% 2016

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
exit_flag = false;
while ~exit_flag
    inp = inputdlg(...
        {'Number of Captures:'}, 'Settings', [1 40],...
        {num2str(length(config))}...
    );
    num_captures = [];
    if ~isempty(inp)
        num_captures = str2double(inp{1});
    end
    
    % Check input.
    exit_flag = ...
        isempty(num_captures) ||...
        ~rem(num_captures, 1) && num_captures > 0;
    if ~exit_flag
        uiwait(errordlg(...
            'Number of captures should be a positive integer.',...
            'Incorrect Value Entered'...
        ));
    end
end

% Choose sensible defaults, based on current settings file.
if num_captures > length(config)
    for i = 1+length(config):num_captures
        config{i} = struct();
        config{i}.sample_rate_hz = config{i-1}.sample_rate_hz;
        config{i}.start_time_s = config{i-1}.end_time_s + 1;
        config{i}.end_time_s = config{i}.start_time_s + 2;
    end
elseif num_captures < length(config)
    config = config(1:num_captures);
end

if num_captures > 0
    % Keep prompting until user presses Done.
    done = false;
    while ~done
        [config, done] = prompt_config(config);
        
        % Check for overlapping captures.
        if ~done
            for i = 2:length(config)
                if config{i}.start_time_s <= config{i-1}.end_time_s
                    msg = sprintf(...
                        'Capture %d starts before capture %d ends.',...
                        i, i - 1 ...
                    );
                    uiwait(errordlg(msg, 'Overlapping Captures'));
                    done = true;
                end
            end
        end
    end
end

% Convert back to length, not end time as this is easier for the
% microcontroller to parse.
for i = 1:length(config)
    config{i}.length = floor(...
        (config{i}.end_time_s - config{i}.start_time_s) *...
        config{i}.sample_rate_hz...
    );
    config{i} = rmfield(config{i}, 'end_time_s');
end
% Write config file.
if ~isempty(config)
    jsondump(config, config_fname);
end
end

function config = get_config(config_fname)
%% GET_CONFIG
%
% DESCRIPTION
%   Locate existing configuration file and write a new one, populated with
%   default values
% 
% INPUTS
%   config_fname - Settings file reference
%
% COPYRIGHT (C) Russell Maguire, Imi Ward Parsons, Lauren Miller, Tom Poon
% 2016

try
    % Parse existing config file.
    config = jsonload(config_fname);
catch e
    module = e.identifier(1:strfind(e.identifier, ':')-1);
    switch module
        case {'jsonload'}
            % Create new config, populated with some default values.
            config = {};
            config{1} = struct();
            config{1}.start_time_s = 5;
            config{1}.sample_rate_hz = 44.1;
            config{1}.length = 200;
            jsondump(config, config_fname);
        otherwise
            rethrow(e);
    end
end
end

function [config, done] = prompt_config(config)
%% PROMPT_CONFIG
%
% DESCRIPTION
%   User is allowed to conduct multiple captures at once and alter the
%   settings for each one individually.
% 
% INPUTS
%   config - Settings file.
%
% COPYRIGHT (C) Russell Maguire, Imi Ward Parsons, Lauren Miller, Tom Poon
% 2016

% Display capture details as prompts, makes it easier for user to review
% configuration.
prompts = cell(length(config), 1);
for i = 1:length(prompts)
    prompts{i} = sprintf(...
        'Start: %.3g s, End: %.3g s, Rate: %.3g Hz',...
        config{i}.start_time_s,...
        config{i}.end_time_s,...
        config{i}.sample_rate_hz...
    );
end

% Prompt user for capture to edit.
[idx, edit] = listdlg(...
    'Name', 'Settings',...
    'PromptString', 'Scheduled Captures:',...
    'ListString', prompts,...
    'OKString', 'Edit',...
    'CancelString', 'Done',...
    'SelectionMode', 'single',...
    'ListSize', [300, 300]...
);
% If the user didn't press Edit, he pressed Done and vice versa.
done = ~edit;
if edit && idx <= length(config)
    config{idx} = prompt_capture(config{idx});
end

% Sort config by start time.
sorted_idxs = [];
for i = 1:length(config)
    % Exclude already sorted indices.
    unsorted_idxs = setdiff(1:length(config), sorted_idxs);
    
    % Find index of next smallest value.
    sorted_idxs(i) = unsorted_idxs(1);
    for j = unsorted_idxs(2:end)
        if config{j}.start_time_s < config{sorted_idxs(i)}.start_time_s
            sorted_idxs(i) = j;
        end
    end
end
% Permute config.
config = config(sorted_idxs);
end

function capture = prompt_capture(default_capture)
%% PROMPT_CONFIG
%
% DESCRIPTION
%   This includes the oringal settings file.
% 
% INPUTS
%   default_capture - Capture utilises default parameters.
%
% COPYRIGHT (C) Russell Maguire, Imi Ward Parsons, Lauren Miller, Tom Poon
% 2016

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
        elseif capture.start_time_s < 5
            % Warn if start time is earlier than two seconds.
            uiwait(warndlg(...
                [
                    'The microcontroller may miss the start of the '...
                    'capture due to scheduling process time.'
                ],...
                'Early Start Time'...
            ));
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
