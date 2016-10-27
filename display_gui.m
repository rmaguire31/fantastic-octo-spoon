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
%
% COPYRIGHT (C) Russell Maguire, Imi Ward Parsons, Lauren Miller & Tom Poon 2016

function display_gui

    [t_start, t_end, freq] = init_config();
    init_gui();
    
    %While(1)
        %Check capture file date
        %Update gui as needed
	
        %if matlab can check update , good
	
        %Change_of_settings_cb()  %%callback
            %Update_config()
            
end

function [t_start, t_end, freq] = init_config()          %default capture settings

    t_start = 0;
    t_end = 10;
    freq = 100;
    
end

function init_gui()
    
    f = figure;                             %uifigure?? no toolbar
    f.Position = [404, 250, 760, 420];      %[position from left, bottom, width, height]
    f.Pointer = 'crosshair';
    f.Name = 'Acceleration Data Capture Program';
    %f.Color = [0.4 0 0.8];``               %want to change background colour?
    
    tab_group = uitabgroup(f);
    tab1 = uitab('Parent', tab_group, 'Title', 'Capture 1');
    tab2 = uitab('Parent', tab_group, 'Title', 'Capture 2');
    %tab1.Position = [410, 260, 300, 420];

    side_panel = uipanel(f, 'Title', 'Options', 'FontSize', 12, 'BackgroundColor', [0.4 0 0.8]);
    side_panel.Position = [710 260 260 420];
    btn = uibutton(side_panel, 'Text', 'Load');
    
    %'Position', [0, 20, 20, 20]);
    
end

%Imi sucks  #check