%%  This is a module for stiching spans of overlapping PSDs of different frequency bin size from SR785
%
%   Assuming a logerithmic scale of frequency, it is desirable to 
%   stich the smaller frequecy ranges to the bottom of the larger ones
%   wilst truncating out bins in the larger span.
%
%Feed in frequency matrix f(n,m) with correesponding floating point
%data(n,m).  
%%  Synopsis:
%     [freqStitch,dataStitch] = freqStitch(freqPoints,dataPoints)
%   
%  Input:
%     freqPoints = frequency points with numPoints-by-n matrix where there are n set of data to
%     stich together
%     dataPoints = PSD data to be stiched numPoints-by-n matrix
%
%%  Output:
%     freqStitch = frequency values with single vector where smallest vector has been sticked to
%     the next largest PSD span using the order from freqPoints
%     
%     dataStitch = PSD values with single vector where smallest vector has been sticked to
%     the next largest PSD span using the order from freqPoints
%
%          NOTE:  Function has been modified from a number of earier
%          versions to a single trunk (hopefully).  This version can take
%          vectors fed in in any order of span frequency size.
%
%
%  Author:
%     Andrew Wade, andrew.wade@anu.edu.au
%     Australian National University, Department of Quantum Science
%     20 Jan 2015
%
% Mods: Removed throw error on less than two spans.  Can now take in a
% singal span and spit it back out as is.
%
%


function [freqStitch,dataStitch] = freqStitch(fInput, dataInput)

[~,NumSpans]=size(fInput); %Finds the number of points in each span and the total number of spans


if NumSpans<1, %error handling to throw out cases where fewer than two data sets are given to stitch
    err1 = MException('NotEnoughtData:TooFewColumns','Fewer than two columns of spans inputed, there is nothing to stitch here. Go back to the lab and collect some more data.');
    throw(err1)
end



% Find order of spans from lowest to highest by looking at max of each column of frequency
% point (SR785 always give low to high order). Then resort in order.

MaxFreqOfEachVector = max(fInput); %Finds the max frequency of each PSD span.
[~,SortOrderSpans] = sort(MaxFreqOfEachVector); % Finds the sort order (dumping actual sort) to determin which order to stitch in.

for n = 1:length(SortOrderSpans) % Resorts spans in increasing order so they can be stitched
    freqPoints(:,n) = fInput(:,SortOrderSpans(n));
    dataPoints(:,n) = dataInput(:,SortOrderSpans(n));
end

freqStitch = freqPoints(:,1); dataStitch = dataPoints(:,1); %Starts the vectors at the lowest spans

for n = 2:length(SortOrderSpans) %Sequentialy stitch all the spans, starting at the lowest and adding high spans starting at the highest freq of the previous span
    int = find(freqPoints(:,n)>max(freqStitch),1,'first'); % Finds first next largest point of previously stiched data
    freqStitch = [freqStitch;freqPoints(int:end,n)]; %This appending method is expensive memory wise (and computationally) as the vectors are not preallocated. But we are typically never using data sets that large anyway.
    dataStitch = [dataStitch;dataPoints(int:end,n)];
end
size(freqStitch)
size(dataStitch)
end











