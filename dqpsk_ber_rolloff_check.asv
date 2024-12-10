clear
close all
clc

num_symbols = 1024;   % Number of symbols

% SNR range (in dB)
rolloff = 0:0.05:1;

simulated_ber_dqpsk = zeros(1, length(rolloff));    
M = 2;
numBits = num_symbols *M;
dataBits = randi([0,1], numBits, 1);
% Loop over each SNR value
for i = 1:length(rolloff)
    rf = rolloff(i);  % Current SNR value

    ber_dqpsk = dqpsk_ber_rolloff(dataBits, rf);
    % Store the simulated BER
    simulated_ber_dqpsk(i) = ber_dqpsk;
end

% Plot the BER vs. SNR (both simulated and theoretical)
figure;
plot(rolloff, simulated_ber_dqpsk, 'bo-', 'LineWidth', 1); hold on;
% semilogy(snr_values, simulated_ber_qpsk, 'ro-', 'LineWidth', 1); grid on;

% Add plot labels, title, and legend
xlabel('rolloff');
ylabel('Bit Error Rate (BER)');
title('Simulated BER vs Rolloff factor');
% legend('DQPSK', 'QPSK');








function ber = dqpsk_ber_rolloff(dataBits,rolloff)
samplesPerSymbol = 8;       
span = 6;

% dataBits = valuesScript('RTL_data/message_input_newone.dat'); 


dqpskMod = comm.DQPSKModulator('BitInput', true,'PhaseRotation', 5*pi/4);
dqpskDemod = comm.DQPSKDemodulator('BitOutput', true,'PhaseRotation', 5*pi/4);

modSymbols = dqpskMod(dataBits);

% Upsample symbols
upsampledSymbols = upsample(modSymbols, samplesPerSymbol);

% Design RRC filter
rrcFilter = rcosdesign(rolloff, span, samplesPerSymbol);

% Apply pulse shaping
shapedSignal = conv(upsampledSymbols, rrcFilter, 'same');

rx = awgn(shapedSignal,5);

% Demodulation
% Filter the received signal with the same RRC filter
filteredSignal = conv(rx, rrcFilter, 'same');

% Downsample to symbol rate
downsampledSignal = filteredSignal(1:samplesPerSymbol:end);
demodBits = dqpskDemod(downsampledSignal);

[~, ber] = biterr(dataBits, demodBits);
end
