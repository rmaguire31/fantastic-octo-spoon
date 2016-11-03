%% display_gui
%
% DESCRIPTION
%   GUI interface to display analysed data and enable user to modify capture settings.
%
% INPUTS
% 
%
% OUTPUTS
%   
%  
% COPYRIGHT (C) Russell Maguire, Imi Ward Parsons, Lauren Miller & Tom Poon 2016

function display_gui

    [t_start, t_end, freq, cap_num, cap_inter] = init_config();
    init_gui(t_start, t_end, freq, cap_num, cap_inter);
    
    %While(1)
        %Check capture file date
        %Update gui as needed
	
        %if matlab can check update , good
	
        %Change_of_settings_cb()  %%callback
            %Update_config()
            
end

function [t_start, t_end, freq, cap_num, cap_inter] = init_config()          %default capture settings

    t_start = 0;
    t_end = 10;
    freq = 100;
    cap_num = 1;
    cap_inter = 30;
    
end

function init_gui(t_start, t_end, freq, cap_num, cap_inter)
    
    f = figure('Name', 'Acceleration Data Capture Program', 'Color', [0.4 0 0.8]);     %uifigure?? no toolbar
    %f.Position = [330, 250, 750, 420];     %[position from left, bottom, width, height]
    f.Pointer = 'crosshair';
    
    tgroup = uitabgroup(f, 'Position', [0.01 0.01 0.8 0.98]);
    tab1 = uitab('Parent', tgroup, 'Title', 'Capture 1');
    tab2 = uitab('Parent', tgroup, 'Title', 'Capture 2');        %if number-of-captures = number of tabs cb

    side_panel = uipanel(f, 'Title', 'Options', 'FontSize', 11, 'Position', [0.8 0.01 0.19 0.98], 'BackgroundColor', 'white');
    btn1 = uicontrol(side_panel, 'Units', 'normalized', 'String', 'Load', 'Position', [0.05 0.88 0.9 0.1]);
    btn1.Callback = @load;
    btn2 = uicontrol(side_panel, 'Units', 'normalized', 'String', 'Save', 'Position', [0.05 0.755 0.9 0.1]);
    btn3 = uicontrol(side_panel, 'Units', 'normalized', 'String', 'Settings', 'Position', [0.05 0.63 0.9 0.1]);
    btn3.Callback = @settings;
end

function load()         %POON WORK

    [filename, pathname] = uigetfile({'Data Files (*.json';'*.jsn'});
    disp
end

function [t_start, t_end, freq, cap_num, cap_inter] = settings(t_start, ...
    t_end, freq, cap_num, cap_inter)

    exit_flagS = 0;
    while (exit_flagS == 0)

        % Labels for entry boxes
        prompt = {'Start Capture Time:', 'End Capture Time:', 'Capture Frequency:',... 
        'Number of Captures:', 'Time Interval Between Captures:'};
        % Title
        dlg_title = 'Settings';
        % Size of Entry boxes
        num_lines = [1 40]; 
        %default answers
        defaultans = {num2str(t_start), num2str(t_end), num2str(freq),...
            num2str(cap_num), num2str(cap_inter)}; 
        % Creation of the dialog box
        s = inputdlg(prompt, dlg_title, num_lines, defaultans);

        % Assign variables to the inputs from the dialog box 
        t_start = str2double(s{1});
        t_end = str2double(s{2});
        freq  = str2double(s{3});
        cap_num = str2double(s{4});
        cap_inter = str2double(s{5});

        % The following are error messages for incorrect values entered
        % Users are then given the opportunity to change their entered values

        % Start Capture time must be greater than or equal to zero
        if t_start < 0
            e1 = errordlg('Start Capture Time cannot be negative',...
                'Incorrect Value Entered');
            uiwait(e1);
            exit_flagS = 0;
        end

        % Make sure End Capture time is larger than the Start Capture Time
        if t_end < t_start
            e2 = errordlg('End capture Time must be greater than Start Captutre Time',...
                'Incorrect Value Entered');
            uiwait(e2);
            exit_flagS = 0;
        end

        % Make sure frequency is greater than zero
        if freq <= 0
             e3 = errordlg('Frequency must be greater than 0');
             uiwait(e3);
             exit_flagS = 0;
        end

        % Make sure number of captures is a positive integer
        if cap_num < 1 || rem(cap_num, 1)~=0
             e4 = errordlg('Start Capture Time must be a positive integer',...
                 'Incorrect Value Entered');
             uiwait(e4);
             exit_flagS = 0;
        end

        %Make sure the interval between captures is greater than or
        %equal to zero
        if cap_inter < 0 
             e5 = errordlg('Interval between Captures cannot be negative',...
                 'Incorrect Value Entered');
             uiwait(e5);
             exit_flagS = 0;
        end

        %exit the While loop only if all values are ok 
        if t_start >= 0 && t_end > t_start && freq > 0 && cap_num >= 1 && cap_inter > 0 ...
            && rem(cap_num, 1)==0
             exit_flagS = 1;
        end

    end

    %Can also enforce limits to make sure no crazy numbers that could
    %potentially crash the system (limit frequency, no. of captures)

    % use to test out the settings function:
    fprintf('\nStart Time = %d\n', t_start);
    fprintf('End time = %d\n', t_end);
    fprintf('Frequency = %d\n', freq);
    fprintf('No. of captures = %d\n', cap_num);
    fprintf('Interval between caputures = %d\n', cap_inter);
    % delete 5 lines above when no errors

end 