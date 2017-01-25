%% Script for computing dispersion in the refractive index of air for given key parameters
%
% [Reduced_n] = RIAir(lambda,p,t,xCO2,RH)
%
% Output: 
%   Reduced_n = n-1; n is refractive index of air at given inputs
%
% Input:
%   lambda = wavelength [m]
%   p = preasure [Pa] (use SI pascal NOT kpascel or mBar)
%   t = temperature [C] (model not valid for temperatures below freezing)
%   xCO2 = concentration CO2 in [ppm]
%   RH = Relative humitity [%]
%
% Accounts for environmental conditions such as preasure, temperature,
% humidty, CO2 concentrations etc.
%
% The model used is that of Ciddor and follows the methdology layed out by
% NIST (US), see http://emtoolbox.nist.gov/Wavelength/Documentation.asp
% (accessed 21 May 2015).  There is some debate as to the best model
% avaliable Edlen or Ciddor. They both have their pros and cons in validity
% over ranges of wavelengths as well as limits to validity under extreem
% ends of air temperatures, preasures, moisture levels etc.  The
% decrepancies are probably not big enough to warrant concern until we
% get to the limits of the model.  I have just chosen Ciddor.
%
% All units here are SI unless otherwise specified
%
%
%
% Authour: Andrew Wade
% Date: 22 May 2015
% Mods: Have added blocks for computing mole fraction H2O using other
% definitions of humitity



function [Reduced_n] = RIAir(lambda,p,t,xCO2,RH)

% We internally define a set of model constants

A1 = -13.928169; A2 = 34.7078238;

alpha = 1.00062; beta = 3.14e-8; gamma = 5.60e-7;

w0 = 295.235; w1 = 2.6422; w2 = -0.03238; w3 = 0.004028;

k0 = 238.0185; k1 = 5792105; k2 = 57.362; k3 = 167917;

a0 = 1.58123e-6; a1 = -2.9331e-8; a2 = 1.1043e-10;

b0 = 5.707e-6; b1 = -2.051e-8;

c0 = 1.9898e-4; c1 = -2.376e-6;

d = 1.83e-11; e = -0.765e-8;

pR1 = 101325; TR1 = 288.15;

Za = 0.9995922115;

rhovs = 0.00985938;

R = 8.314472; Mv = 0.018015;


% Compute the mole fraction (for H20 adjustment).
% Three equations for three alternative definitions of humidity.
%%% Comment or uncomment blocks to activate different defs. %%%

% %%% Block 1: dew point %%%
% % Must define td as input to function
% T = td + 273.15; 
% Theta = T./273.16;
% Y = A1.*(1-Theta.^(-1.5))+A2.*(1-Theta.^(-1.25));
% psv = 611.657.*exp(Y);
% f = alpha+beta.*p+gamma.*t.^2;
% xv = f.*psv./p; % The mole fraction found from relative humitity
% %%% End Block 1: relative humitity %%%

%%% Block 2: relative humitity %%%
T = t + 273.15;
Theta = T./273.16;
Y = A1.*(1-Theta.^(-1.5))+A2.*(1-Theta.^(-1.25));
psv = 611.657.*exp(Y);
f = alpha+beta.*p+gamma.*t.^2;
xv = (RH./100).*f.*psv./p; % The mole fraction found from relative humitity
%%% End Block 2: relative humitity %%%


% %%% Block 3: partial preassure %%%
% % Must define pv (parital preasure) [Pa] as input to function
% T = t + 273.15;
% Theta = T./273.16;
% f = alpha+beta.*p+gamma.*t.^2;
% xv = f.*pv./p; % The mole fraction found from relative humitity
% %%% End Block 3: relative humitity %%%



% Compute the rest of the derived quantities
T = t + 273.15;

S = 1./(lambda.*1e6).^2;% Convert laser wavelength to micrometers then find recipricol square.

ras = 10^-8.*(k1./(k0-S)+k3./(k2-S));

rvs = 1.022e-8.*(w0+w1.*S+w2.*S.^2+w3.*S.^3);

Ma = 0.0289635+1.2011e-8.*(xCO2-400);

raxs = ras.*(1+5.34e-7.*(xCO2-450));

Zm = 1-(p./T).*(a0+a1.*t+a2.*t.^2+(b0+b1.*t).*xv+(c0+c1.*t).*xv.^2)+(p./T).^2.*(d+e.*xv.^2);

rhoaxs = pR1.*Ma./(Za.*R.*TR1);

rhov = xv.*p.*Mv./(Zm.*R.*T);

rhoa = (1-xv).*p.*Ma./(Zm.*R.*T);


%From all above derived quantities compute RI
Reduced_n = (rhoa./rhoaxs).*raxs+(rhov./rhovs).*rvs;% Compute this way to see more clearly how it deviates from vacuum, simply add 1 to get to true RI
end