%% Analysis

% DESCRIPTION
%  Load data from JSONLOAD, conduct analysis and display plots
% INPUTS
%  roll - Roll time series
%  pitch - Pitch time series
%  roll_f - Roll in frequency domain
%  pitch_ f - Pitch in frequency domain
% OUTPUTS
%  mean_p - Mean pitch
%  mean_r - Mean roll
%  var_p - Variance of roll
%  var_r - Variance of pitch

function [t_mean, t_var, t_peaks, t_locs, f_peaks, f_locs] = analyse(t, data_t, f, data_f)

% Conduct statistical analysis
% Take absolute values
t_mean = abs(mean(data_t)); 
t_var = abs(var(data_t));

% Find peaks.
if exist('findpeaks','builtin')
    [t_peaks,t_locs] = findpeaks(data_t,t,'SortStr','descend');
    [f_peaks,f_locs] = findpeaks(data_f,f,'SortStr','descend');
else
    t_peaks = [];
    t_locs = [];
    f_peaks = [];
    f_locs = [];
end

    
    