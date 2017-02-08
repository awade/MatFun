function [h] = bplotcust(s,elementListToPlot,varargin)
%bplotcust - Takes a structural vector with standard formate and plots a
%single pannel display calling channels in ordered list elementListToPlot and thei
%legend entries.
%
% Syntax:  bplotcust(s,elementListToPlot)
%
% Inputs:
%    s - structured array with following elements
%
%                 f: [800×1 double]
%               ch1: [800×1 double]
%               ch2: [800×1 double]
%         PlotTitle: 'Plot all title'
%          Ch1Title: 'channelOneTitle'
%          Ch2Title: 'ChannelTwoTitle'
%        xaxisLabel: 'xaxislabel'
%     yaxisLabelCh1: 'yaxislabelCh1'
%     yaxisLabelCh2: 'yaxislabelCh2'
%         legendch1: 'annotation1'
%         legendch2: 'anotation2'
%           comment: 'comment'
%         fStitched: [800×1 double]
%       ch1Stitched: [800×1 double]
%       ch2Stitched: [800×1 double]
%
%   elementListToPlot - nx2 array listing which channels to plot in row one
%   and which legend entries to use in the legand key.
%    
%   {'nameofchannel','legendentryvar'}
%
% Outputs:
%    h list - returns figure handles
%
% Example: 
%    load a structured array using import2struct.m then run
%    bplotcust(s,elementListToPlot)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: import2struct.m
%
% Author: Andrew Wade
% Work address: West-bridge Caltech
% email: awade@ligo.caltech.edu
% Website: 
% Created: 20170123; Last revision: 20170123

%------------- BEGIN CODE --------------
%% Parsing optional starting number for figures
if length(varargin)>1
    error('Error, too many input argument or wrong type. \nType help bplotdual for usage')
elseif length(varargin)==1
    startFigNum = varargin{1};
else
    startFigNum = 1;
end



% Compile all avaliable data together to plot on a single plot
PlotEntryList = ''; CompileOfAllfVectors = []; LegendValues = '';
for n = 1:length(s.MetaList) % Step through the rest of data sets appending to the plot list with each itteration
    for elm = 1:size(elementListToPlot,1)
        if isfield(s.(s.MetaList{n}),elementListToPlot{elm,1}) %Skips over if field doesn't exist
            PlotEntryList = [PlotEntryList 's.' char(s.MetaList(n)) '.fStitched,s.' char(s.MetaList(n)) '.' elementListToPlot{elm,1} ',']; % Generate plot list
            LegendValues = [LegendValues '''' s.(char(s.MetaList(n))).(elementListToPlot{elm,2}) '''' ','];
        end
    end
    CompileOfAllfVectors = [CompileOfAllfVectors;s.(char(s.MetaList(n))).fStitched]; % Generate freq vector list, this is for setting axis limits
end



PlotEntryList = PlotEntryList(1:end-1); % remove trailing comma
LegendValues = LegendValues(1:end-1);% remove trailing comma
% CompileOfAllfVectors = CompileOfAllfVectors(1:end-1); % remove trailing semi-colon


% Now plot
n = 1; %Just use labels from first dataset loaded.
h = figure(startFigNum);
eval(['p = plot(' PlotEntryList ',''LineWidth'',1.5' ');']) % Plots list of entries created in do loop above, eval is useful for dynamic lines of code
ax = gca; % Returns handle of the curret axes for the current figure
ax.GridLineStyle = '-'; % Sets grid lines to solid instead of defult dotted
ax.MinorGridLineStyle = '-'; % Sets minor grid lines to solid instead of defult dotted
ax.XScale = 'log'; %Sets axis type to 'log'
ax.YScale = 'log';
ax.FontSize = 16; % Set the font size to something readable
% % ax.YLim = [-170,-80]; % Set y-axis limits
ax.XLim = [min(CompileOfAllfVectors),max(CompileOfAllfVectors)];
title(s.(char(s.MetaList(n))).dataPlotTitle)
xlabel(s.(char(s.MetaList(n))).xaxisLabel)
ylabel(s.(char(s.MetaList(n))).yaxisLabelCh1)
eval(['legend(' LegendValues ')'])
grid on
hold off

%------------- END OF CODE --------------
%Please send suggestions/questions to address at top of script

end