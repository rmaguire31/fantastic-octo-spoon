vq = resample(v, ratio);
%% RESAMPLE
%
% DESCRIPTION
%   Allow off-line captured data resampling
%
% INPUTS
%   v - Vector to resample
%   ratio - Ratio of original over new sample rate.
%
% OUTPUTS
%   vq - New resampled vector.
%
% COPYRIGHT (C) Lauren Miller 2016

xq = linspace(1, length(vi), length(vi) * ratio);
vq = interp1(v, xq, 'spline');