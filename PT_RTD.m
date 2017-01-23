% PT_RTD computes the resistance of Platinum 100 Ohm RTD as a function of
% temperature

clear all % Clear the decks

% Standard 1PT100 parameters
A = 3.9083e-3; % [1/C]
B = -5.775e-7; % [1/C]
C = -4.183e-12;% [1/C]
R0 = 100; %[Ohm]

T = [-20:0.1:100];

Rt = zeros(size(T));
for n = 1:length(T)
    if T(n)<0
        Rt(n) = R0.*(1+A.*T(n)+B.*T(n).^2-C.*(T(n)-100).*T(n).^3);
    elseif T(n)>=0
        Rt(n) = R0.*(1+A.*T(n)+B.*T(n).^2);
    end
end

figure(1)
plot(T,Rt)
title('Temperature vs resistance 1PT100 type resistive sensor')
xlabel('Temperature [C]')
ylabel('Resistance [Ohm]')