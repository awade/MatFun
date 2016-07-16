function UniqSol = sysLensFit(q_in,q_out,LensList,zTol,lossTol,n)
%% Function that runs an fminsearch on given lens set with a hole set of intial conditions to see what unique solutions may be selected
%
% (This is for 1D raytracing and gaussian beam
% propergation.)
%
% Only the q_in and q_out values are needed, it is assumed that solutions
% involving lenses placed before or after these set point positions are not
% starting point for the optimisation intial values.  This might be an
% extentino in a future version
%
%
%
% Author: Andrew Wade
% Date: July 12, 2016
%
% Useage:
% ALL UNITS IN SI!
%
% C = sysLensFit(q_in,q_out,GenPairLensList,zTol,lossTol,n)
%
% Inputs:
%   q_in = Input complex beam parameter 
%   q_out = desired ouput complex beam parameter 
%   LensList = list of lens in order  of propergation
%   zTol = Tolerance in lens placement for triggering unique solution
%   lossTol = tollerance of beam overlap 'power loss' before throwing
%   solution out
%   n = number of lens positoins between input and output waist to try,
%   setting this higher will cost more compute time but avoid missing
%   possible solutions.
%
% Ouput:
%   UniqSol = unique solutions for the given lenses in form [z1,...zn,f1,...fn,ploss]

z_in = real(-q_in); z_out = real(-q_out); % Extract start and end point of properation from q values
% n = 10; %Set the number of positions increments to select from. The total number of intial trials will scale as the power of number of lenses
PosList = linspace(z_in,z_out,n); intLensPosList = [combnk(PosList,size(LensList,1));combnk(fliplr(PosList),size(LensList,1))]'; % Divide the avaliable propergation distance into n starting positions and generate list of for the intital conditions of the fminsearch
LMsystemGOF = @(zVar) 1-modeovlp(q_out,LMsystemQTransform([zVar LensList],q_in)); % Construct a minimizable function for overlap of the propergated beam and the desired beam. Note that anonymous functions may have some efficiency issues in Matlab still.
for ii = 1:length(intLensPosList) %Test solutions for all the initial conditions
    [z_sol(:,ii),ploss(ii)] = fminsearch(LMsystemGOF,intLensPosList(:,ii)); % Call and fminsearch on the function with some suggested starting values
end

solList = [z_sol;LensList*ones(1,size(z_sol,2));ploss]; % Pull results, their focal lengths their loss values together

% Filter to throw away solutions outside the range of interest or
% repeats of already there
% zTol = 0.01; %Set placement tollerance before tripping as a different new solution
% lossTol = 0.001; % Set tollerance on overlap mode loss

[ix,~] = find(solList(size(solList,1),:)'>lossTol);solList(:,ix) = []; %Find solutions with loss greater than the tollerance and scrub them from the list of possible solutions

UniqDataScale = [1,1,Inf*ones(1,length(LensList)),Inf]; % Generate a vector for the DataScale option of uniquetol so that the focal lengths and ploss values are ignored in the unique solution search
UniqSol = uniquetol(solList',zTol,'ByRows',true,'DataScale',[1,1,Inf,Inf,Inf]); % look for unique solutions from the output zTol sets the placement tollerance, 'ByRows' speifices to compair results rowwise rather than flattening the array and 'DataScale' option configures it to check the first two columns at 1*zTol and then skip the final column

