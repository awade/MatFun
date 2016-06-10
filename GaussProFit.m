%% Fitting routine for finding waist size and position, 1-D only
%
% This model takes a set of data values for scaned beam widths (radius values) as a
% function of distances and computes the width and position of beam waist
% with least squares fminsearch

% [w0,z0] = GaussProFit(z,wdataIn) 
%
% Output:
% w0  = radius width of beam at its waist [m]
% z0  = poisition of beam waist [m]
%
% Input:
% z = Beam width measurment points relative to some reference point (vector) [m]
% w0 = beam width (radius) of beam at each of the above points (vector) [m]
%
% Performs least squares fminsearch to find the best fit of the data to
% give the beam waist and its position relative to the reference point z =
% 0.
%
%
% Authour: Andrew Wade
% Last edited: 9 June 2016  
%


function [z0,w0] = GaussProFit(z,wdataIn,varargin)

% % % % % Check goodness of input argments: Else throw errors % % % % %
if nargin>3 %Trip error message if too many input arguments
    error(GaussProFit:TooManyInputs', ...
        'Function requires at most three inputs. Try just z values and beam widths and lambda (optional).');
elseif nargin == 2 %defult to 1064 nm if no wavelength is given
    lambda = 1064e-9;
elseif nargin == 3
    lambda = varargin{1};
else
    error(GaussProFit:TooFewInputs', ...
    'Function requires at most three inputs and at most two. Try just z values and beam widths and lambda (optional).');
end

if size(wdataIn) ~= size(z) %Check if both input vectors are of the same dimension
    error(myfuns:InputDataLenthsDontMatch:TooManyInputs', ...
        'The input data have different lengths, you must use distance and waist vectors that are the same size');
end


% Reorder data in accending order of z measurments (so can input can take any order
% or distance measurments
[z,indexOrder] = sort(z,2); % Find sort order of distances in acending order
wdata = wdataIn(indexOrder); % Have a feeling this is horribly ineffeicent, but never going to use many datapoints into a script like this anyway


%Set up waist propergation and error function
w  = @(z,w0,z0) w0.*sqrt(1+(lambda.*(z-z0)./pi./w0.^2).^2); %beam radius as a function of distance from the waist z located at z0 and the beam radius at the waist z0
errorFunction = @(x1) sum((wdata-w(z,x1(1),x1(2))).^2); %Find error between data and curve for beam waist


% Find closest measurment to minimum or set beyond bounds of measurment by
% a meter
[~,indexMinw] = min(wdata); %Find point of minimum actual measured waist
if indexMinw ==1
    zguess = z(indexMinw)-1; %Set minimum well beyond limit of measurment range (-1 meters before)
elseif indexMinw == length(wdata)
    zguess = z(indexMinw)+1; %Set minimum well beyond limit of measurment range (+1 meters after)
else
    zguess = z(indexMinw); % Set to data point closest to the waist
end

outVal = fminsearch(errorFunction,[min(wdata),zguess]);

display('beam waist')
outVal(1)*10^6
display('beam waist position')
outVal(2)*10^3

zPlot = linspace(min(z),max(z),1000); %G
figure(2)
plot(z, wdata, 'o', zPlot, w(zPlot,outVal(1),outVal(2)),'-')
title('x-axis Gasussian beam width fit as a function of z')
xlabel('z/mm')
ylabel('beam radius/mircometers')
legend('Data','Fitted Curve')

