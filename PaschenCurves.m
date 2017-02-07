% Script for ploting the Paschen arc breakdown volatages as a function of pd for systems
% operating under vacuum.  
%
% These curves give the breakdown voltage as a function of presure and arc
% distance and is empirically derived.  This is a matter of concern for
% vacuum systems that utilise high voltage to drive actuators and its is
% important to know at what presures it is important to switch off HV
% drivers to ensure safe operation of experiments operating in these
% extreem environments.
%
%
% The Paschen Curves operates according to 
%
% V = a.*p.*d/(ln(p.*d)+b)
%
% Where p is presure, d is distance and a and b are constants specific to
% the gas in question.
%
% The relationship is ultimatly derived from mean free path of gasses and
% it is important to remember that p and d are always co-products.  This
% also means that arc voltage doens't just decrease as a function of voltage
% as the cascade effect is inhibited at shorter distances by a lower
% avaliablity of ionisable gasses. Arc voltage acutally increases below a
% certain optimal distance given a presure and viasa vesa for presures.

%A simple version of the breakdown voltage hase the form:
% V = V_min.*(p.*d./c)./(1+log(p.*d./c))
% In textbooks V_min and c are ussually explicitly defined and
% avliable from various sources on the web

clear all 


nPlotLength = 1000;

% Define some common gas properties
GasProperties = {...
    %'Name',V_minValue,c_value
    'Air',327,7.558;...
    'CO2',420,6.798;...
    'Nitrogen (N2)',251,8.931;...
    'Oxygen (O2)',450,9.331;...
    'He',156,53.32;...
    'Ar',137,11.997};

for n = 1:size(GasProperties,1)
    V_min = GasProperties{n,2};
    c = GasProperties{n,3};
    pd = logspace(log10(max(c)./exp(1)),3,nPlotLength);
    BreakdownVoltage = V_min.*pd./c./(1+log(pd./c));
    BreakdownVoltage = V_min.*pd./(1+log(pd./c));
    GasProperties{n,4} = pd;
    GasProperties{n,5} = BreakdownVoltage;
end



figure(77); cla; hold on
cellfun(@(x,y) plot(x,y),GasProperties(:,4),GasProperties(:,5));
grid on
ax = gca; % Returns handle of the curret axes for the current figure
ax.GridLineStyle = '-'; % Sets grid lines to solid instead of defult dotted
ax.MinorGridLineStyle = '-'; % Sets minor grid lines to solid instead of defult dotted
ax.XScale = 'log'; %Sets axis type to 'log'
ax.YScale = 'log';
ax.FontSize = 14; % Set the font size to something readable
title('Paschens Curve - Breakdown voltage as function of p*d')   
xlabel('p*d [Torr.cm]')
ylabel('Break Down Voltage [Volts]')
legend(GasProperties{:,1})
hold off