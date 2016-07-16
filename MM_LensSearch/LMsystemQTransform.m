function q_prop = LMsystemQTransform(SystemElementsParameters,q_in,varargin)

%% Function that generates ABCD transfer function and applies to get the transform of q_in (the complex beam parameter)
%
% An abitrary number of lenses and mirrors are input with thier positions
% and focuses and the function outputs a four element matrix with their
% transfer function.  (This is for 1D raytracing and gaussian beam
% propergation.
%
% The itterative computing of ABCD is problematic. Although its
% computationally expensive, at least its flexable to much bigger systems
% of equations. Previously I had used a fixed system of equations for two
% lenses and then modified the function if I needed a three lens solution.
% This is just more generic
%
%
%
% Author: Andrew Wade
% Date: June 29, 2016
% Mod notes: v0.1 Minimum working example
%
%
%
%
%
%
% Useage:
% ALL UNITS IN SI!
%
% ABCD = LMsystem(LensList,lambda)
% ABCD = LMsystem(LensList)
%
% Inputs:
%   LensList = [z1 f1;z2 f2;...z_n f_n] % List of all refracting and
%   reflecting elements in thier order of propergation. Use f_n =inf if you
%   want a final free space propergation at the end
% 
%   lambda = wavelenth of light (defult 1064 nm)
%
% Ouput:
%   ABCD = the ABCD raytracing transfer matrix of the whole system
%


%% Error throwing if input is bad
if nargin>3 %Trip error message if too many input arguments
    error('Too many input argments. Function requires at most two inputs. Type "help LMsystem" for useage');
elseif nargin<1
    error('Too few input argments. Function requires at least one matrix input. Type "help LMsystem" for useage');
end


%Unpack system of elements and compute total ABCD matrix
M = [1 0;0 1]; %Initialise input matrix
for ii = 1:size(SystemElementsParameters,1) % Loop through all elements in element list
    d = SystemElementsParameters(ii,1);%Propergation distance from zero reference point on the z plane
    f = SystemElementsParameters(ii,2); % Focal length of element
    M = [1 -d;0 1]*[1 0;-1./f 1]*[1 d;0 1]*M; %Free space propergation followed by focusing element followed by transform to get back to the position basis of the initla beam: this is so all the beams are all referenced to the same reference frame. Here SystemElementsParameters(1) is position and SystemElementsParameters(2) is the focual length (assume thin lens for refracting optics
end


q_prop = 1./((M(2,2)./q_in+M(2,1))./(M(1,2)./q_in+M(1,1))); % Generating output value q_out from ABCD elements of the system transfer matrix