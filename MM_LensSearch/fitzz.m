%% Test script for batching possible modematching solutions from a set of avaliable lenses

close all % Clear the decks
clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Some old code for speed up using parrallel loops.  
%
%Setting up parrallel computing pool of processors (defult to use on Macbook is 2) OP3ANU can do 6 
% if matlabpool('size') == 0 % checking to see if my pool is already open
% %     matlabpool open 6 % Open 6 parralel processes for 6 core processor
%     matlabpool open 2 % Open 2 parralel processes for 2 core processor
%     
% end

% USE TO CLOSE POOL OF PROCESSORS: matlabpool close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % % % User set values % % % %
lambda = 1.064e-6; % Set the laser wavelength
n = 1; % RI air


w_in  = 210.15e-6; z_in = 0; %Input beam
w_out  = 332e-6; z_out = 190.5e-3+203e-3+127e-3; %desired out beam

% Compute beam complex parameters
q_in = 1i.*pi.*w_in.^2./lambda-z_in % Input q value plus translation of waist from z = 0 reference point
q_out = 1i.*pi.*w_out.^2./lambda-z_out %Computed desired output value


% LensSet = [50 100 200 300 400 500 750 1000 50 100 200 300 400 500 750 1000].*1e-3; %List all avaliable lenses

LensSet = [50.53 56.94 74.95 85.85 85.85 85.85 101.66 101.66 103.20 103.20 103.20 114.54 114.54 127.12 143.23 143.23 171.92 171.92 229.08 254.24 343.62 343.62 343.62 401.00 401.00 401.00 458.15 572.69 572.69 572.69 687.45 687.45 687.45 687.45 795.10 1145.61].*1e-3; % List of all lenses avliable in the PSL lab


% LensSet = [50 100 200 300].*1e-3; %List all avaliable lenses

GenPairLensList = [combnk(LensSet,2);fliplr(combnk(LensSet,2))];

%%
% LensList = [100;400].*1e-3


zTol = 0.01; %Set placement tollerance before tripping as a different new solution
lossTol = 0.1; % Set tollerance on overlap mode loss
n = 10; %Set the number of positions increments to select from. The total number of intial trials will scale as the power of number of lenses

tic %Start timer
GenAllSols = [];
parfor ii = 1:length(GenPairLensList)
    C = sysLensFit(q_in,q_out,GenPairLensList(ii,:)',zTol,lossTol,n); % Optimisation useing a bunch of test intial values so we don't miss obvious solutions, i.e. lenses switched or multiply solutions
    GenAllSols = [GenAllSols;C]; %Add valid solutions to full list of lens choise options
end
toc % Display compute time

%%
%Need Reduce to unique solutions again to account for cases double lens selection
%from original list
UniqDataScale = [1,1,Inf*ones(1,size(GenPairLensList,2)),Inf]; % Generate a vector for the DataScale option of uniquetol so that the focal lengths and ploss values are ignored in the unique solution search
GenAllSols = uniquetol(GenAllSols,zTol,'ByRows',true,'DataScale',[1,1,Inf,Inf,Inf]); % look for unique solutions from the output zTol sets the placement tollerance, 'ByRows' speifices to compair results rowwise rather than flattening the array and 'DataScale' option configures it to check the first two columns at 1*zTol and then skip the final column

%% Also remove solutions that involve placing the lenses outside the input and output wasit positoins
GenAllSols
for ii = 1:size(GenPairLensList,2) % Loop through total number of lenses
[ix,~] = find(GenAllSols(:,ii)<z_in); GenAllSols(ix,:) = []; %Remove all soltions outside the bounds of z_in and z_out
[ix,~] = find(GenAllSols(:,ii)>z_out); GenAllSols(ix,:) = [];
end

%% Also remove solutions where second lens apears is before the first, this is a quirky solution that isn't phsyical
[ix,~] = find(GenAllSols(:,1)>GenAllSols(:,2)); GenAllSols(ix,:) = []; %Remove all soltions outside the bounds of z_in and z_out


% (size(GenAllSols,2)-1)/2
% [ix,~] = find(GenAllSols(size(GenAllSols,1),:)>lossTol);GenAllSols(:,ix) = []; %Find solutions with loss greater than the tollerance and scrub them from the list of possible solutions


% display(GenAllSols) %Display the results


%% Now look at how sensitive the solutions by looking at the partial derivative at the point of fminsearch solutions generated above
% This is quick and dirty for just two lenses

ploss = @(q_in,q_out,SystemElementsParameters) 1-modeovlp(q_out,LMsystemQTransform(SystemElementsParameters,q_in)); % Construct a minimizable function for overlap of the propergated beam and the desired beam. Note that anonymous functions may have some efficiency issues in Matlab still.


for ii = 1:length(GenAllSols)
SystemElementsParameters = reshape(GenAllSols(ii,1:4),[2,2]); % Reshape line of solution lest to feed into propergation function
delta = 0.01;
GradCompute = [...
ploss(q_in,q_out,SystemElementsParameters+[delta 0;0 0])./delta,...
ploss(q_in,q_out,SystemElementsParameters-[delta 0;0 0])./delta,...
ploss(q_in,q_out,SystemElementsParameters+[0 0;delta 0])./delta,...
ploss(q_in,q_out,SystemElementsParameters-[0 0;delta 0])./delta];
FullSolWtGradients(ii,:) = [GenAllSols(ii,:) GradCompute];
end


% Display all the final results in a pretty table
array2table(FullSolWtGradients,...
    'VariableNames',{'z1','z2','f1','f2','ploss','z1plossGradneg','z1plossGradpos','z2plossGradneg','z2plossGradpos'})

















% %% Setup for plotting solutions
% %This module is messy and needs some tiding, but as of July 12, 2016 it
% %works.
% zScan = linspace(z_in,z_out,1000); % Generate z axis values to plot upon
% 
% SolSorted = sortrows([z_sol GenPairLensList]); % Sort the solution into order in which lenses are layed down
% %Could add a f = infinity lens to the above set to generate the beam
% %propergation before the first lens
% 
% qinPlot(1) = q_in; %Define solution up to first lens
% for ii = 1:size(SolSorted,1) %Loop over list of lens and find the index of zScan value that matches the lens position so that correct beam parameters are computed at each point along the optical plain
%     indexRangeLensWise(ii,1) = find(zScan>SolSorted(ii,1),1);
%     qinPlot(ii+1) = LMsystemQTransform(SolSorted(1:ii,:),q_in);
% end
% 
% indexRangeLensWiseFull = [0;indexRangeLensWise;length(zScan)]; % Concatinate with the start and end points so the plotting solution can be spliced together in sections
% qCompute = zeros(size(zScan)); % Pre generate for speed
% for ii = 2:(size(indexRangeLensWiseFull,1))
%     qCompute(indexRangeLensWiseFull(ii-1)+1:indexRangeLensWiseFull(ii)) = qinPlot(ii-1) + zScan(indexRangeLensWiseFull(ii-1)+1:indexRangeLensWiseFull(ii));
% end
% 
% 
% %Now plot the solutions
% w = sqrt(lambda./pi./imag(-1./qCompute)); %Compute the beam width at as a function of z displacement along the optical axis
% figure(1)
% plot(zScan,w)

