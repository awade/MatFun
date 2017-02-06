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
% V = a.*p.*d/(ln(p.*.d)+b)
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
%

% for air
a = 4.36e7; %[V/(atm.m)]
b = 12.8; %[-]


d_PaschenCurve = logspace(-5.5,1,100);
p = 1;

V_PaschenCurve = a.*p.*d_PaschenCurve./(log(p.*d_PaschenCurve)+b);
V_minBreakDown = a.*exp(1-b)


figure(1)
loglog(d_PaschenCurve,V_PaschenCurve)
title('Paschens Curve - Breakdown voltage as function of p*d')   
xlabel('p*d [kg.m^-1.s^2')
ylabel('V_BreakDown [volts]')
grid off
% ledgend('','')


%% The above is redone for a different arangement of the above equation in

%the form:
% V = V_min.*p.*d./c./(1+log(p.*d./c))
% This is a much better form as V_min and c are explicitly defined and
% avliable from various sources on the web

nPlotLength = 1000;
V_minVals = [327,420,251,450,156,137]
c_vals = [7.558,6.798,8.931,9.331,53.32,11.997];%[0.567,0.51,0.67,0.7,4.0,0.9];

for n = 1:length(c_vals)
d_PaschenCurves(:,n) = logspace(log10(max(c_vals(n))./exp(1)),3,nPlotLength);
p = 1;
end

V_PaschenCurves = zeros(length(d_PaschenCurves),length(V_minVals));

for n = 1:length(V_minVals)
    V_min = V_minVals(n);
    c = c_vals(n);
    V_PaschenCurves(:,n) = V_min.*p.*d_PaschenCurves(:,n)./c./(1+log(p.*d_PaschenCurves(:,n)./c));
    V_Unitless(:,n) = p.*d_PaschenCurves(:,n)./c./(1+log(p.*d_PaschenCurves(:,n)./c));
end

figure(2)
loglog(d_PaschenCurves(:,1),V_PaschenCurves(:,1),d_PaschenCurves(:,2),V_PaschenCurves(:,2),d_PaschenCurves(:,3),V_PaschenCurves(:,3),d_PaschenCurves(:,4),V_PaschenCurves(:,4),d_PaschenCurves(:,5),V_PaschenCurves(:,5),d_PaschenCurves(:,6),V_PaschenCurves(:,6))
title('Paschens Curve - Breakdown voltage as function of p*d')   
xlabel('p*d [Torr.cm^-2]')
ylabel('V_BreakDown [Volts]')
grid off
legend('Air','CO2', 'Nitrogen (N2)','Oxygen (O2)','He','Ar')


figure(3)
loglog(d_PaschenCurves(:,1),V_Unitless(:,1),d_PaschenCurves(:,2),V_Unitless(:,2),d_PaschenCurves(:,3),V_Unitless(:,3),d_PaschenCurves(:,4),V_Unitless(:,4),d_PaschenCurves(:,5),V_Unitless(:,5),d_PaschenCurves(:,6),V_Unitless(:,6))





% %% 3D plot of presure and distance vs Voltage
% p = linspace(0.01,1,20);
% d = linspace(0.0001,0.1,20);
% 
% 
% [P,D] = meshgrid(p,d);
% V = a.*P.*D./(log(P.*D)+b);
% display(V)
% mfigure(3)
% surf(P,D,V)
% 
% productPD = P.*D;
% 
% 
% 
% 
% 
% 
% 
% 
% %Symboically solve for pd for a range of chosen voltages to work out if
% %curves overlap or minimum V_breakdown repsents the minimum
% 
% %%
% syms pd
% dp_atBreakDown = [];
% 
% for V = 328:50:1000
%     buff = vpasolve(a*pd./(log(pd)+b)==V,pd);
%     dp_atBreakDown = [dp_atBreakDown buff];
% end
% 
% p = linspace(1e-2,1e3,100);
% figure(2)
% hold on
% for n = 1:length(dp_atBreakDown)
% loglog(p,dp_atBreakDown(n)./p)
% end
