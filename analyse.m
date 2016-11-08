function [t_mean, t_var, t_peaks, t_locs, f_peaks, f_locs, t_max, f_max] = analyse(t, data_t, f, data_f)
%% ANALYSE
%
% DESCRIPTION
%   Locates each peak and sorts them from smallest to largest.
%
% INPUTS
%   t - Time domain
%   data_t - Time series
%   f - Frequency domain
%   data_f - Spectrum
%
% OUTPUTS
%   t_mean - Mean
%   t_var - Variance
%   t_peaks - Peaks in time domain
%   t_locs - Location of peaks
%   f_peaks - Peaks in frequency domain
%   f_locs - Location of peaks
%
% COPYRIGHT (C) Lauren Miller 2016

% Conduct statistical analysis
% Take absolute values

t_mean = abs(mean(data_t)); 
t_var = abs(var(data_t));

% Check for Statistics Toolbox and find peaks

if exist('findpeaks','builtin')
    [t_peaks,t_locs] = findpeaks(data_t,t,'SortStr','descend');
    [f_peaks,f_locs] = findpeaks(data_f,f,'SortStr','descend');
else
    t_peaks = [];
    t_locs = [];
    f_peaks = [];
    f_locs = [];
end

% Find max values.
t_max = max(data_t);
if isempty(t_max)
    t_max = 0;
end

% Find frequency with maximum power.
f_max = f(data_f == max(data_f(2:end)));
if isempty(f_max)
    f_max = 0;
end
f_max = f_max(1);

    