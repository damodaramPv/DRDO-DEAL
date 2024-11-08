clc;
clear;
close all;

dataBits = valuesScript('RTL_data/message_input_newone.dat'); 

% Create DQPSK Modulator and Demodulator objects
dqpskMod = comm.DQPSKModulator('BitInput', true,'PhaseRotation', 5*pi/4);
dqpskDemod = comm.DQPSKDemodulator('BitOutput', true,'PhaseRotation', 5*pi/4);

% Modulate the data
modSymbols = dqpskMod(dataBits);

% Save modulated symbols to a file
save('modulatedSymbols.mat', 'modSymbols');

% Getting JK Values from RTL and converting binary to decimal using binarytodecimal
j_RTL = binarytodecimal('RTL_data/j_values3.dat', 0);  % Set plotFlag to 0 (no plot)
k_RTL = binarytodecimal('RTL_data/k_values3.dat', 0);  % Set plotFlag to 0 (no plot)

% Combine j and k RTL values into complex numbers
rtl_modsymbols = j_RTL + 1i * k_RTL;

% Difference between the modulated symbols and RTL values
conc = [modSymbols rtl_modsymbols];
diff = modSymbols - rtl_modsymbols;

conc2 = [modSymbols(1:31) rtl_modsymbols(2:32)];
diff2 = conc2(:,1) - conc2(:,2);

% Create a stem plot
figure;
stem(real(conc2(:, 1)),'o', 'DisplayName', 'Inbulit DQPSK') ;% Stem plot for the 1st column
hold on; % Hold on to add the next plot to the same graph
stem(real(conc2(:, 2)), 'x', 'DisplayName', 'RTL DQPSK'); % Stem plot for the 2nd column

xlabel('Index');
ylabel('Real Part');
title('Inbuilt vs RTL - Real Part');
legend; % Display legend
grid on; % Optional: Add grid for better visualization
hold off;

figure(2);
stem(imag(conc2(:, 1)),'o', 'DisplayName', 'Inbulit DQPSK') ;% Stem plot for the 1st column
hold on; % Hold on to add the next plot to the same graph
stem(imag(conc2(:, 2)), 'x', 'DisplayName', 'RTL DQPSK'); % Stem plot for the 2nd column

xlabel('Index');
ylabel('Imaginary Part');
title('Inbuilt vs RTL - Imaginary Part');
legend; % Display legend
grid on; % Optional: Add grid for better visualization
hold off;
