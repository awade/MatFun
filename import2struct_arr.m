function s = import2struct(importList)
%import2struct.m - Matlab script for extracting datasets form tab delimited and comma seperated files and putting into structured array for plotting in batchplot.m
%
% Syntax:  s = import2struct(importarray)
%
% Inputs:
%    importarray - Curly brace array with following comma seperated data
%                  fields with each line imported seperated by semicolon
%   importList =
%   {'PSDNoiseIntergratorCircuitTMTF_13-01-2017_111010.txt','dataTag',30,2,'Plot all title','channelOneTitle','ChannelTwoTitle','xaxislabel','yaxislabelCh1','yaxislabelCh2','annotation','comment';...
%     n more lines};
%
%   If channel unused leave black '' placeholders
%
% Outputs:
%    s - Structed array containing all the data
%
% Example:
%    s = import2struct(importarray);
%
% Other m-files required: freqStitch.m
%
% See also: OTHER_FUNCTION_NAME1,  OTHER_FUNCTION_NAME2

% Author: Andrew Wade
% Work address: West-bridge Caltech
% email: awade@ligo.caltech.edu
% Website:
% Jan 2017; Last revision: 20170123

%------------- BEGIN CODE --------------

%
% Author: Andrew Wade
%
% Date Created: 2017 Jan 1
%
% Update log:
% # 20170113 - Wrapped up as a generalised function where array  is passed
% in and pretty plots are made.  All data is contained in the array
% elements for plot titles, axis labels etc
%
%   Based on PSDStichPlotyyyymmdd_DescriptiveName.m standard matlab function in the
%   git repo folder.
%


% Function sorts data into dynamic cells acording to the metadata labeling 'nameTag'.  This will
% generate sub cells of array 's' that are length(C_Array)-by-m
% matrixes that contain multiply spans. Freqency, data, stitched data and comments as per text string label e.g. SQZ/AntiSQZ/SN/DN and are
% are also plotted as stitched data

% TODO: Debug code remove later
% importList = {
% %'filenameData.txt','dataTag',numHeaderLines,'Plot title','channelOneTitle','ChannelTwoTitle','xaxislabel','yaxislabel','comment','internal comment';...
% 'PSDNoiseIntergratorCircuitTMTF_13-01-2017_111010.txt','dataTag',30,2,'Plot title','channelOneTitle','ChannelTwoTitle','xaxislabel','yaxislabel','annotation','comment';...
% };
% NumHeaderLines = 30; %Define the expected number of header lines in the SR785 file. Ussual for FFTs is 14.


% Lists all files to be loaded
display('Files imported...');
for n = 1:length(importList(:,1)) % Displays all the files to open.
    display(importList{n,1})
end
display('...end list');

s = struct; % Generate blank array to be added to below
% s.PlotAllTitle = PlotAllTitle;
% s.Ch1Name = Ch1Name; s.Ch2Name = Ch2Name;


s.MetaList = ''; % Preallocate blank list of meta tags
h = waitbar(0,'Opening files...'); % Create waitbar and get its handle.
for n = 1:length(importList(:,1)) % Loops to read in each file name in turn
    waitbar(n/length(importList(:,1)),h) % Update waitbar with progress through list of files
    
    % Open file n and dump contents into a buffer variable
    fid = fopen(importList{n,1},'r'); % Opens file for reads
    if (importList{n,4}==1)
        Buffer_C = textscan(fid,'%f %f','HeaderLines',importList{n,3}); %scan csv material less header 2 lines into an 2x1 array nested in C. Each nested read has two columns of data
        fclose(fid); % Closes the file
    elseif (importList{n,4}==2)
        Buffer_C = textscan(fid,'%f %f %f','HeaderLines',importList{n,3}); %scan csv material less header 2 lines into an 2x1 array nested in C. Each nested read has two columns of data
        fclose(fid); % Closes the file
    else
        error('Wrong number of channels, must be either 1 or 2')
    end
    
    size(Buffer_C)
    FileBatch = char(importList(n,2)); %Find metadata label for file entry in FileNames_wtMetaData
    if sum(ismember(fieldnames(s),FileBatch))>0 % Test if batch identifer is already present in 's', if so append to it in new row
        s.(FileBatch).f = [s.(FileBatch).f,Buffer_C{:,1}];
        s.(FileBatch).ch1 = [s.(FileBatch).ch1,Buffer_C{:,2}];
        if (importList{n,4}==2)
            s.(FileBatch).ch2 = [s.(FileBatch).ch2,Buffer_C{:,3}];
        end
        s.(FileBatch).comment = [s.(FileBatch).comment,importList{n,12}];
%         s.(FileBatch).dataPlotTitle = [s.(FileBatch).dataPlotTitle,importList{n,5}];
    else % If not already cell then create and dump in first data
        s.(FileBatch).f = {Buffer_C{:,1}};
        s.(FileBatch).ch1 = {Buffer_C{:,2}};
        if (importList{n,4}==2)
            s.(FileBatch).ch2 = Buffer_C{:,3};
            s.(FileBatch).yaxisLabelCh2 = importList{n,10};
            s.(FileBatch).legendch2 = importList{n,12};
        end
        s.(FileBatch).dataPlotTitle = importList{n,5};
        s.(FileBatch).Ch1Title = importList{n,6};
        s.(FileBatch).Ch2Title = importList{n,7};
        s.(FileBatch).xaxisLabel = importList{n,8};
        s.(FileBatch).yaxisLabelCh1 = importList{n,9};
        s.(FileBatch).legendch1 = importList{n,11};
        s.(FileBatch).comment = importList{n,13};
        s.MetaList = [s.MetaList;{FileBatch}];
    end
end
close(h) % close waitbar


%% For loop stiching blocks of data together grouping metadata blocks together
for n = 1:length(s.MetaList) % Loops through all the different groups of spans in data batch
    [s.(char(s.MetaList(n))).fStitched,s.(char(s.MetaList(n))).ch1Stitched] = freqStitch_arr(s.(char(s.MetaList(n))).f,s.(char(s.MetaList(n))).ch1);
    if (importList{n,4}==2)
        [s.(char(s.MetaList(n))).fStitched,s.(char(s.MetaList(n))).ch2Stitched] = freqStitch_arr(s.(char(s.MetaList(n))).f,s.(char(s.MetaList(n))).ch2);
    end
end





end
