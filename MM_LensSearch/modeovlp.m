function inBeamProfiles = modeovlp(q1,q2)

%% Function that generates the beam overlap given two complex beam parameters of two gaussian beams
%
%
% Author: Andrew Wade
% Date: June 29, 2016
% Mod notes: v0.1 Minimum working example
%
%
%
% Useage:
% ALL UNITS IN SI!
%
% ploss = modeovlp(q1,q2)
%
% Inputs:
%   q1 = complex beam parameter one
%   q2 = complex beam parameter two
% 
%   lambda = wavelenth of light (defult 1064 nm)
%
% Ouput:
%   ploss = mode overlap of two beams
%


%% Error throwing if input is bad
if nargin>2 %Trip error message if too many input arguments
    error('Too many input argments. Function requires at most two inputs. Type "help modeovlp" for useage');
elseif nargin<1
    error('Too few input argments. Function requires at least 2 inputs. Type "help modeovlp" for useage');
end

%Compute the mode overlap
inBeamProfiles=abs((4*imag(q1).*imag(q2))./abs(conj(q1)-q2).^2); %This was copied from Antonio's codebase, but not sure if it is a normlised intergral or the loss. Check against my old scripts

