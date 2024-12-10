clear
close all
clc

num_symbols = 1024;   % Number of symbols
k = 2;

% SNR range (in dB)
EbNo = -10:2:20;
snr_values = EbNo + 3 + 10*log10(k); % Converting Eb/No to SNR

simulated_ber_dqpsk = zeros(1, length(snr_values));    % Simulated BER
simulated_ber_qpsk = zeros(1, length(snr_values)); 
M = 2;
numBits = num_symbols *M;
dataBits = randi([0,1], numBits, 1);
% Loop over each SNR value
for i = 1:length(snr_values)
    snr_dB = snr_values(i);  % Current SNR value
    EbNo_i = EbNo(i);        % Current Eb/No Value

    ber_dqpsk = dqpsk_ber(dataBits, snr_dB);
    ber_qpsk = qpsk_ber(dataBits, snr_dB);
    % Store the simulated BER
    simulated_ber_dqpsk(i) = ber_dqpsk;
    simulated_ber_qpsk(i) = ber_qpsk;
end

% Plot the BER vs. SNR (both simulated and theoretical)
figure;
semilogy(snr_values, simulated_ber_dqpsk, 'bo-', 'LineWidth', 1); hold on;
% semilogy(snr_values, simulated_ber_qpsk, 'ro-', 'LineWidth', 1); grid on;

% Add plot labels, title, and legend
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('Simulated BER vs SNR');
% legend('DQPSK', 'QPSK');


function ber = qpsk_ber(dataBits,snr_dB)


% dataBits = valuesScript('RTL_data/message_input_newone.dat'); 

modSymbols = pskmod(dataBits,4,pi/4);
x = modSymbols;

signal_power = mean(abs(modSymbols).^2);
snr_linear = 10^(snr_dB / 10);
noise_power = signal_power / snr_linear;
noise = sqrt(noise_power) * (randn(size(x))+1i*rand(size(x)));

y = modSymbols + noise;

demodBits = pskdemod(y,4,pi/4);

[~, ber] = biterr(dataBits, demodBits);
end






function ber = dqpsk_ber(dataBits,snr_dB)


% dataBits = valuesScript('RTL_data/message_input_newone.dat'); 


dqpskMod = comm.DQPSKModulator('BitInput', true,'PhaseRotation', 5*pi/4);
dqpskDemod = comm.DQPSKDemodulator('BitOutput', true,'PhaseRotation', 5*pi/4);

modSymbols = dqpskMod(dataBits);
x = modSymbols;

signal_power = mean(abs(modSymbols).^2);
snr_linear = 10^(snr_dB / 10);
noise_power = signal_power / snr_linear;
noise = sqrt(noise_power) * (randn(size(x))+1i*rand(size(x)));

y = modSymbols + noise;

demodBits = dqpskDemod(y);

[~, ber] = biterr(dataBits, demodBits);
end
