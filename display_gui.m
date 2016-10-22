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
    
    f = uifigure;
    f.Position = [404, 250, 560, 420];
    f.Pointer = 'crosshair';
    
    tab_group = uitabgroup('Parent', f);
    tab1 = uitab('Parent', tab_group, 'Title', 'Capture 1');

    %side_panel = uipanel(f, 'Position', [300, 20, 20, 400]);
    
    %btn = uibutton(side_side_panel, 'Text', 'Load', 'Position', [300, 20, 20, 20]);
end