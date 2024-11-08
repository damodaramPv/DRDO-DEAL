clc
clear 
close all
% Parameters
numBits = 1000; % Number of bits to transmit
SNR = 10;       % Signal-to-noise ratio (in dB)

% Generate random bits
% dataBits = randi([0 1], numBits, 1); % Random binary data
dataBits = valuesScript('RTL_data/message_input_newone.dat');
% dataBits = zeros(numBits,1);

% Create DQPSK Modulator and Demodulator objects
dqpskMod = comm.DQPSKModulator('BitInput', true);
dqpskDemod = comm.DQPSKDemodulator('BitOutput', true);

% Modulate the data
modSymbols = dqpskMod(dataBits);

% Save modulated symbols to a file
save('modulatedSymbols.mat', 'modSymbols');

% Add AWGN noise to the modulated symbols
receivedSymbols = awgn(modSymbols, SNR, 'measured');

% Demodulate the received symbols
receivedBits = dqpskDemod(receivedSymbols);

% Compare the transmitted and received bits
numErrors = sum(dataBits ~= receivedBits);
ber = numErrors / numBits;
fprintf('Bit Error Rate (BER): %f\n', ber);

% Plot constellation diagram
scatterplot(receivedSymbols);
title('DQPSK Modulated Symbols (with AWGN)');
grid on;

% Save transmitted and received bits to files
save('transmittedBits.mat', 'dataBits');
save('receivedBits.mat', 'receivedBits');

% Optional: Check if all bits match
if numErrors == 0
    disp('All bits transmitted correctly!');
else
    disp(['Number of bit errors: ', num2str(numErrors)]);
end
