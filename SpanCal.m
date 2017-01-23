function [fvec,SpanFreqRanges,IFPercentOfSpan] = SpanCal(fl,fu,numSpans,numPointsPerSpan,IFRequired)
%
% Script for computing upper and lower bounds as well as % of 
% span for IF BW setting for multispan takes using a spectrum analyzier in logspace
% frequency mode. Spits out the full logspace vector and the settings that
% need to be keyed into SA.
%
% Syntax:  [fvec,SpanFreqRanges,IFPercentSettings] = SpanCal(fl,fu,numSpans,numPoints,IFRequired)
%
% Inputs:
%    fl - Lower frequency bound
%    fu - Upper frequency bound
%    numSpans - Number of spans want to take
%    numPoints - Number of points in each span
%    IFRequired - IF bandwidth (the resolution bandwidth) in Hz desired
%
% Outputs:
%    fvec - Full expected frequency vector once all stitched together, put
%    placeholder '~' in if you just want to dump this value.
%    SpanFreqRanges - 2xn vector of upper and lower frequency bands of
%    n=numSpans total spans to take
%    IFPercentOfSpan - The resolution bandwidth as a percentage of total
%    span, set this value into the SA for the desired IF bandwidth.
%
% Example: 
%   [fvec,SpanFreqRanges,IFPercentSettings] = SpanCal(fl,fu,numSpans,numPoints,IFRequired)
%   [~,SpanFreqRanges,IFPercentSettings] =
%   SpanCal(fl,fu,numSpans,numPoints,IFRequired) %Same as above but dump
%   the long vector
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: NA

% Author: Andrew Wade
% Work address: Caltech
% email: awade@ligo.caltech.edu
% Website: http://www.
% Jan 2017; Last revision: 20-Jan-2017

%------------- BEGIN CODE --------------

fvec = logspace(log10(fl),log10(fu),numSpans.*numPointsPerSpan);

%Compute the span ranges for optimal log spacing accros all n spans
SpanFreqRanges = zeros(numSpans,2);
for ii = 1:numSpans
    SpanFreqRanges(ii,1) = fvec(1+(ii-1)*numPointsPerSpan);
    SpanFreqRanges(ii,2) = fvec(numPointsPerSpan+(ii-1)*numPointsPerSpan);
end

%Compute span of each data grab and convert IFRequired value to percent of
%span
Span = abs(SpanFreqRanges(:,2)-SpanFreqRanges(:,1)); % Abolute value makes the order of fu,fl unimportant, this is good if want to span down instead of up on concectuive measurments
IFPercentOfSpan = IFRequired./Span*100; %Used dot version of devide incase user wants to enter a vector with changing resolution bandwidth
end

