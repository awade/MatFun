%Matlab script for extracting datasets form tab delimited and comma
%seperated files and putting into structured array for plotting in
%batchplot.m

%
% Author: Andrew Wade
%
% Date Created: 2017 Jan 1
%
%% Plot data

addpath('~/SVN/MatFun/') %location of standard functions

clear all % Clear the decks
close all

importList = {
%'filenameData.txt','dataTag',numHeaderLines,'Plot title','channelOneTitle','ChannelTwoTitle','xaxislabel','yaxislabel','comment','internal comment';...
'PSDNoiseIntergratorCircuitTMTF_13-01-2017_111010.txt','dataTag',30,2,'Plot title','channelOneTitle','ChannelTwoTitle','xaxislabel','yaxislabel','annotationch1','annotationch2','comment';...
};

importList ={'PSDNoiseIntergratorCircuitTMTF_13-01-2017_111010.txt','intNoise',30,2,'Plot all title','channelOneTitle','ChannelTwoTitle','xaxislabel','yaxislabelCh1','yaxislabelCh2','annotation1','anotation2','comment';...
    'PSDNoiseIntergratorCircuitTMTF_13-01-2017_111010.txt','test2part',30,2,'Plot all title','channelOneTitle','ChannelTwoTitle','xaxislabel','yaxislabelCh1','yaxislabelCh2','annotation1','anotation2','comment'};

s = import2struct(importList); % Generate blank array to be added to below




[h] = bplotdual(s);


%%
startFigNum = 11;
for n = 1:length(s.MetaList)
    figure(startFigNum - 1 + n)
    plot(s.(char(s.MetaList(n))).fStitched,s.(char(s.MetaList(n))).ch1Stitched,s.(char(s.MetaList(n))).fStitched,s.(char(s.MetaList(n))).ch2Stitched)
    ax = gca; % Returns handle of the curret axes for the current figure
    ax.GridLineStyle = '-'; % Sets grid lines to solid instead of defult dotted
    ax.MinorGridLineStyle = '-'; % Sets minor grid lines to solid instead of defult dotted
    ax.XScale = 'log'; %Sets axis type to 'log'
    ax.YScale = 'log';
    ax.FontSize = 14; % Set the font size to something readable
    % % ax.YLim = [-170,-80]; % Set y-axis limits
    ax.XLim = [min(min(s.(char(s.MetaList(n))).fStitched)),max(max(s.(char(s.MetaList(n))).fStitched))];
    title(s.(char(s.MetaList(n))).PlotTitle)
    xlabel(s.(char(s.MetaList(n))).xaxisLabel)
    ylabel(s.(char(s.MetaList(n))).yaxisLabelCh1)
    legend(s.(char(s.MetaList(n))).legendch1,s.(char(s.MetaList(n))).legendch2)
    grid on
    hold off
end

%%
startFigNum = 21;
for n = 1:length(s.MetaList)
    figure(startFigNum + 2*(n-1))
    plot(s.(char(s.MetaList(n))).fStitched,s.(char(s.MetaList(n))).ch1Stitched)
    ax = gca; % Returns handle of the curret axes for the current figure
    ax.GridLineStyle = '-'; % Sets grid lines to solid instead of defult dotted
    ax.MinorGridLineStyle = '-'; % Sets minor grid lines to solid instead of defult dotted
    ax.XScale = 'log'; %Sets axis type to 'log'
    ax.YScale = 'log';
    ax.FontSize = 14; % Set the font size to something readable
    % % ax.YLim = [-170,-80]; % Set y-axis limits
    ax.XLim = [min(min(s.(char(s.MetaList(n))).fStitched)),max(max(s.(char(s.MetaList(n))).fStitched))];
    title(s.(char(s.MetaList(n))).Ch1Title)
    xlabel(s.(char(s.MetaList(n))).xaxisLabel)
    ylabel(s.(char(s.MetaList(n))).yaxisLabelCh1)
    legend(s.(char(s.MetaList(n))).legendch1)
    grid on
    hold off
    
    figure(startFigNum + 1 + 2*(n-1))
    plot(s.(char(s.MetaList(n))).fStitched,s.(char(s.MetaList(n))).ch2Stitched)
    ax = gca; % Returns handle of the curret axes for the current figure
    ax.GridLineStyle = '-'; % Sets grid lines to solid instead of defult dotted
    ax.MinorGridLineStyle = '-'; % Sets minor grid lines to solid instead of defult dotted
    ax.XScale = 'log'; %Sets axis type to 'log'
    ax.YScale = 'log';
    ax.FontSize = 14; % Set the font size to something readable
    % % ax.YLim = [-170,-80]; % Set y-axis limits
    ax.XLim = [min(min(s.(char(s.MetaList(n))).fStitched)),max(max(s.(char(s.MetaList(n))).fStitched))];
    title(s.(char(s.MetaList(n))).Ch2Title)
    xlabel(s.(char(s.MetaList(n))).xaxisLabel)
    ylabel(s.(char(s.MetaList(n))).yaxisLabelCh1)
    legend(s.(char(s.MetaList(n))).legendch2)
    grid on
    hold off
end






%% Plot Stitched and plot data

% Compute the RMS
for n = 1:length(s.MetaList)
    s.(char(s.MetaList(n))).ch1StitchedRMS = rms(s.(char(s.MetaList(n))).fStitched,s.(char(s.MetaList(n))).ch1Stitched)';
    s.(char(s.MetaList(n))).ch2StitchedRMS = rms(s.(char(s.MetaList(n))).fStitched,s.(char(s.MetaList(n))).ch2Stitched)';
    s.(char(s.MetaList(n))).legendch1RMS = [s.(char(s.MetaList(n))).legendch1 ' RMS'];
    s.(char(s.MetaList(n))).legendch2RMS = [s.(char(s.MetaList(n))).legendch2 ' RMS'];
end


%%
% Compile all avaliable data together to plot on a single plot
PlotEntryList = ''; CompileOfAllfVectors = ''; LegendValues = ''; 
elementListToPlot = {'ch1Stitched','legendch1';'ch1StitchedRMS','legendch1RMS';'ch2Stitched','legendch2';'ch2StitchedRMS','legendch2RMS';}; %Ordered list speificing elements out of each dataset to actually plot along with appended legend text
for n = 1:length(s.MetaList) % Step through the rest of data sets appending to the plot list with each itteration
    for elm = 1:size(elementListToPlot,1)
        if isfield(s.(s.MetaList{n}),elementListToPlot{elm,1})
            PlotEntryList = [PlotEntryList 's.' char(s.MetaList(n)) '.fStitched,s.' char(s.MetaList(n)) '.' elementListToPlot{elm,1} ',']; % Generate plot list
            LegendValues{n*elm} = s.(char(s.MetaList(n))).(elementListToPlot{elm,2});
        end
    end
    
    CompileOfAllfVectors = [CompileOfAllfVectors 's.' char(s.MetaList(n)) '.fStitched;']; % Generate freq vector list
end

%  PlotEntryList = [PlotEntryList 's.' char(s.MetaList(n)) '.fStitched,s.' char(s.MetaList(n)) '.ch1RMSStitched,'];
%     if isfield(s.(MetaList(n)),'ch2') %check if ch2 is there skip if not
%         PlotEntryList = [PlotEntryList 's.' char(s.MetaList(n)) '.fStitched,s.' char(s.MetaList(n)) '.ch2Stitched,']; % Generate plot list
%         PlotEntryList = [PlotEntryList 's.' char(s.MetaList(n)) '.fStitched,s.' char(s.MetaList(n)) '.ch2RMSStitched,'];
%     end

PlotEntryList = PlotEntryList(1:end-1); % remove trailing comma
CompileOfAllfVectors = CompileOfAllfVectors(1:end-1); % remove trailing semi-colon


% Now plot
n = 1; %Just use labels from first dataset loaded.
figure(98)
eval(['plot(' PlotEntryList ')']) % Plots list of entries created in do loop above, eval is useful for dynamic lines of code
ax = gca; % Returns handle of the curret axes for the current figure
ax.GridLineStyle = '-'; % Sets grid lines to solid instead of defult dotted
ax.MinorGridLineStyle = '-'; % Sets minor grid lines to solid instead of defult dotted
ax.XScale = 'log'; %Sets axis type to 'log'
ax.YScale = 'log';
ax.FontSize = 14; % Set the font size to something readable
% % ax.YLim = [-170,-80]; % Set y-axis limits
ax.XLim = [min(min(s.(char(s.MetaList(n))).fStitched)),max(max(s.(char(s.MetaList(n))).fStitched))];
title(s.(char(s.MetaList(n))).PlotTitle)
xlabel(s.(char(s.MetaList(n))).xaxisLabel)
ylabel(s.(char(s.MetaList(n))).yaxisLabelCh1)
legend(LegendValues)
grid on
hold off
