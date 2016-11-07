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

% Remove config from MBED filesystem, MBED filesystem doesn't like us
% making changes to existing files.
delete(config_fname);

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
