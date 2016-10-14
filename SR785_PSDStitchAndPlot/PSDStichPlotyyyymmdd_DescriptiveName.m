%Matlab script for extracting PSD traces and
%stiching them together in single plots.
%
% Author: Andrew Wade
%
% Date Created: 6 June 2012
% Date Last Modified: 3 Oct ? (significate rewrite using structured
% arrays to generalise readin and processing)
%
% Mod: 30 Jan 2015 put in code around plotting that now make axis tight
% around the x axis by sitching all the stiched PSD frequency vectors and
% finding the max.  Its a bit clumsy using the eval, but should garenteed
% work for all validly entered metdatags.
%
% Mod: 14 Oct 2016 removed stuff to do with SQZ to put on github
%
%
% To get data address a`s s.NameOfTag_f  = freq Vector array and s.NameOfTag
% = data vector array
%
% Stiched data is access by going into the array as
% StitchedData.NameOfTag_f and StitchedData.NameOfTag
%
%
%   Based on PSDStichPlotyyyymmdd_V2_0 standard matlab function in the
%   dropbox folder.
%

clear all % Clear the decks
% close all


%Put files in here
FileNames_wtMetaData = {'SRS002.ASC','DNSR780',0,'';... %Define array containing {'Filename.txt',NameOfTag,NL Float,'Comment'}. Note these are mixture of data types so be careful
                        'SRS003.ASC','DNSR780',0,'';...
                        'SRS004.ASC','DNSR780',0,'';...
                        'SRS005.ASC','UnTermPSLTempBox',0,'';...
                        'SRS006.ASC','UnTermPSLTempBox',0,'';...
                        'SRS007.ASC','UnTermPSLTempBox',0,'';...
                        'SRS008.ASC','UnTermPSLTempBox',0,'';...
                        'SRS009.ASC','Term4p2kohmPSLTempBox',0,'';...
                        'SRS010.ASC','Term4p2kohmPSLTempBox',0,'';...
                        'SRS011.ASC','Term4p2kohmPSLTempBox',0,'';...
                        'SRS012.ASC','Term4p2kohmPSLTempBox',0,'';...
                        'SRS013.ASC','DNSR780LF',0,'';...
                        'SRS014.ASC','UnTermPSLTempBoxLF',0,'';...
                        'SRS015.ASC','Term4p2kohmPSLTempBoxLF',0,'';...
%                         'SRS016.ASC','ShotNoise',0,'';...
%                         'SRS017.ASC','DarkNoise',0,'';...
%                         'SRS018.ASC','DarkNoise',0,'';...
%                         'SRS019.ASC','DarkNoise',0,'';...
%                         'SRS020.ASC','DarkNoise',0,'';...
%                         'SRS021.ASC','DarkNoise',0,'';...
%                         'SRS022.ASC','SR785Floor',0,'';...
%                         'SRS023.ASC','SR785Floor',0,'';...
%                         'SRS024.ASC','SR785Floor',0,'';...
%                         'SRS025.ASC','SR785Floor',0,'';...
%                         'SRS026.ASC','SR785Floor',0,'';... 
                        };
                    

                    
                    

%% Block to read in all data
% This is a standard block drawn from file SRSReadAndStitch (Created: 6
% June2012 mod: 09 May 2014 The CArray outputs are grouped into cells within an array according to their meta data label.
% this is more memory efficent than previous versions.

NumHeaderLines = 14; %Define the expected number of header lines in the SR785 file. Ussual for FFTs is 14.

% Lists all files to be loaded
display('Files imported...');
for n = 1:length(FileNames_wtMetaData(:,1)) % Displays all the files to open.
display(FileNames_wtMetaData{n,1})
end
display('...end list');

s = struct; % Generate blank array to be added to below
s.MetaList = ''; % Preallocate blank list of meta tags
h = waitbar(0,'Opening files...'); % Create waitbar and get its handle.
for n = 1:length(FileNames_wtMetaData(:,1)) % Loops to read in each file name in turn
    waitbar(n/length(FileNames_wtMetaData(:,1)),h) % Update waitbar with progress through list of files

    % Open file n and dump contents into a buffer variable
    fid = fopen(FileNames_wtMetaData{n,1},'r'); % Opens file for reads
    Buffer_C = textscan(fid,'%f %f','HeaderLines',NumHeaderLines); %scan csv material less header 2 lines into an 2x1 array nested in C. Each nested read has two columns of data
    fclose(fid); % Closes the file
    
    % Sort data into dynamic cells acording to the metadata labeling.  This will
    % generate sub cells of array 's' that are length(C_Array)-by-m
    % matrixes that contain multiply spans. Freqency, data and NL gain are
    % all generated as per text string label e.g. SQZ/AntiSQZ/SN/DN.
    
    %Example output:
    % FileNames_wtMetaData = {'SRS001.ASC','SQZyyyymmdd',x,'';...
    %                         'SRS002.ASC','SQZyyyymmdd',x,'';...
    %                        }
    %GIVES
    %s.SQZyyyymmdd = [801x2] data matrix
    %s.SQZyyyymmdd_f = [801x2] frequency matrix
    %s.SQZyyyymmdd_NLVal = [1x2] vector with NL values
    %

        FileBatch = char(FileNames_wtMetaData(n,2)); %Find metadata label for file entry in FileNames_wtMetaData
    if sum(ismember(fieldnames(s),FileBatch))>0 % Test if batch identifer is already present in 's', if so append to it
        s.(FileBatch) = [s.(FileBatch),Buffer_C{:,2}];
        s.([FileBatch '_f']) = [s.([FileBatch '_f']),Buffer_C{:,1}];
        s.([FileBatch '_NLVal']) = [s.([FileBatch '_NLVal']),FileNames_wtMetaData{n,3}];
    else % If not already cell then create and dump in first data
        s.(FileBatch) = Buffer_C{:,2};
        s.([FileBatch '_f']) = Buffer_C{:,1};
        s.([FileBatch '_NLVal']) = FileNames_wtMetaData{n,3};
        s.MetaList = [s.MetaList;{FileBatch}];
    end
end
close(h) % close waitbar

%For loop stiching blocks of data together by metadata tag
for n = 1:length(s.MetaList) % Loops through all the different groups of spans in data batch
[StitchedData.([char(s.MetaList(n)) '_f']),StitchedData.(char(s.MetaList(n)))] = freqStitch(s.([char(s.MetaList(n)) '_f']),s.(char(s.MetaList(n))));
end

% 
%% Plot all data
PlotEntryList = ['StitchedData.' char(s.MetaList(1)) '_f,' 'StitchedData.' char(s.MetaList(1))]; % Seed first element of plot list (need min one data set)
for n = 2:length(s.MetaList) % Step through the rest of data sets appending to the plot list with each itteration
    PlotEntryList = [PlotEntryList ',StitchedData.' char(s.MetaList(n)) '_f,StitchedData.' char(s.MetaList(n))]; % Generate plot list
end

CompileOfAllfVectors = ['StitchedData.' char(s.MetaList(1)) '_f'];
for n = 2:length(s.MetaList) % Step through the rest of data sets appending to the plot list with each itteration
    CompileOfAllfVectors = [CompileOfAllfVectors ';StitchedData.' char(s.MetaList(n)) '_f']; % Generate freq vector list
end

figure(1)
eval(['plot(' PlotEntryList ')']) % Plots list of entries created in do loop above, eval is useful for dynamic lines of code
ax = gca; % Returns handle of the curret axes for the current figure
ax.GridLineStyle = '-'; % Sets grid lines to solid instead of defult dotted
ax.MinorGridLineStyle = '-'; % Sets minor grid lines to solid instead of defult dotted
ax.XScale = 'log'; %Sets axis type to 'log'
ax.FontSize = 14; % Set the font size to something readable
ax.YLim = [-170,-80]; % Set y-axis limits
ax.XLim = [min(eval(['[' CompileOfAllfVectors ']'])),max(eval(['[' CompileOfAllfVectors ']']))];%[min(vector),max(vector)]; % Set 
title([datestr(date,'yyyy-mm-dd') ' PSD of modified LIGO temperature sensor interface board (D9803001)'])
xlabel('Frequency [Hz]')
ylabel('PSD voltage noise modified LIGO Temperature Box [dBVrms/Hz^{1/2}]')
% legend(s.MetaList)
legend('SR780 DN floor','Voltage noise at board output input open','Voltage noise at board output with 40.2kOhm load at input')
grid on



%% % Convert to Vrms from dBVrms
% %For loop converting already stiched data to new units of Vrms from dBVrms
% for n = 1:length(s.MetaList) % Loops through all the different groups of spans in data batch
% StitchedData.(char(s.MetaList(n))) = 10.^(StitchedData.(char(s.MetaList(n)))./20)
% end


% % Plot all data
% PlotEntryList = ['StitchedData.' char(s.MetaList(1)) '_f,' 'StitchedData.' char(s.MetaList(1))]; % Seed first element of plot list (need min one data set)
% for n = 2:length(s.MetaList) % Step through the rest of data sets appending to the plot list with each itteration
%     PlotEntryList = [PlotEntryList ',StitchedData.' char(s.MetaList(n)) '_f,StitchedData.' char(s.MetaList(n))]; % Generate plot list
% end
% 
% CompileOfAllfVectors = ['StitchedData.' char(s.MetaList(1)) '_f'];
% for n = 2:length(s.MetaList) % Step through the rest of data sets appending to the plot list with each itteration
%     CompileOfAllfVectors = [CompileOfAllfVectors ';StitchedData.' char(s.MetaList(n)) '_f']; % Generate freq vector list
% end
% 
% figure(2)
% eval(['semilogy(' PlotEntryList ')']) % Plots list of entries created in do loop above, eval is useful for dynamic lines of code
% ax = gca; % Returns handle of the curret axes for the current figure
% ax.GridLineStyle = '-'; % Sets grid lines to solid instead of defult dotted
% ax.MinorGridLineStyle = '-'; % Sets minor grid lines to solid instead of defult dotted
% ax.XScale = 'log'; %Sets axis type to 'log'
% ax.FontSize = 14; % Set the font size to something readable
% ax.YLim = [1e-9,1e-4]; % Set y-axis limits
% ax.XLim = [min(eval(['[' CompileOfAllfVectors ']'])),max(eval(['[' CompileOfAllfVectors ']']))];%[min(vector),max(vector)]; % Set 
% title([datestr(date,'yyyy-mm-dd') ' PSD of modified LIGO temperature sensor interface board (D9803001)'])
% xlabel('Frequency [Hz]')
% ylabel('PSD voltage noise modified LIGO Temperature Box [Vrms/Hz^{1/2}]')
% set(gca,'fontsize', 28)
% % legend(s.MetaList)
% legend('SR780 DN floor','Voltage noise at board output input open','Voltage noise at board output with 40.2kOhm load at input')
% grid on




 
%% Compute some averages
% % minIndex = find(s.ShotNoise_f>=1024,1,'first');
% % maxIndex = find(s.ShotNoise_f>=1.485e4,1,'first');
% % 
% % meanSN = mean(s.ShotNoise(minIndex:maxIndex))
% % meanSQZ = mean(s.SQZ(minIndex:maxIndex))
% % meanAntiSQZ = mean(s.AntiSQZ(minIndex:maxIndex))
% % meanDN = mean(s.DarkNoise(minIndex:maxIndex))
% % 
% % meanSQZ-meanSN
% % meanAntiSQZ-meanSN
