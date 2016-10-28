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

    [t_start, t_end, freq, capnum, capinter] = init_config();
    init_gui();
    
    %While(1)
        %Check capture file date
        %Update gui as needed
	
        %if matlab can check update , good
	
        %Change_of_settings_cb()  %%callback
            %Update_config()
            
end

function [t_start, t_end, freq, capnum, capinter] = init_config()          %default capture settings

    t_start = 0;
    t_end = 10;
    freq = 100;
    capnum = 1;
    capinter = 30;
    
end

function init_gui()
    
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
end

function load()

    [filename, pathname] = uigetfile({'Data Files (*.json';'*.jsn'});
    disp
end

%Imi sucks  #check