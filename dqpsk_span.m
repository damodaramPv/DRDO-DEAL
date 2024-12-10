clc
clear
close all


span = 2:1:100;
bw = [];
bitErr = [];

for i = 1:length(span)
% Parameters
dataRate = 2.5e6;                
M = 2;                 
symbolRate = dataRate / M; % Symbol rate (symbols per second)

samplesPerSymbol = 8;
rolloff = 0.35;
sp = span(i);
numSymbols = 1000;

% Sampling frequency
Fs = symbolRate * samplesPerSymbol;
Ts = 1 / Fs;

% dataBits = valuesScript('RTL_data/message_input_newone.dat'); 

dataBits = randi([0,1], 512, 1);
dqpskMod = comm.DQPSKModulator('BitInput', true,'PhaseRotation', 5*pi/4);
dqpskDemod = comm.DQPSKDemodulator('BitOutput', true,'PhaseRotation', 5*pi/4);

modSymbols = dqpskMod(dataBits);


% Upsample symbols
upsampledSymbols = upsample(modSymbols, samplesPerSymbol);

% Design RRC filter
rrcFilter = rcosdesign(rolloff, sp, samplesPerSymbol);

% Apply pulse shaping
shapedSignal = conv(upsampledSymbols, rrcFilter, 'same');

% Demodulation
% Filter the received signal with the same RRC filter
filteredSignal = conv(shapedSignal, rrcFilter, 'same');

% Downsample to symbol rate
downsampledSignal = filteredSignal(1:samplesPerSymbol:end);
demodSymbols = dqpskDemod(downsampledSignal);

% Calculate bandwidth
signalFFT = abs(fftshift(fft(shapedSignal)));  % FFT of the signal
frequencies = linspace(-Fs/2, Fs/2, length(signalFFT));
powerSpectralDensity = signalFFT.^2;

% Calculate 99% bandwidth
cumulativePower = cumsum(powerSpectralDensity) / sum(powerSpectralDensity);
lowerIndex = find(cumulativePower >= 0.005, 1);
upperIndex = find(cumulativePower >= 0.995, 1);
bandwidth = frequencies(upperIndex) - frequencies(lowerIndex);

bw = [bw bandwidth];
[~, ber] = biterr(dataBits, demodSymbols);
bitErr = [bitErr ber];
end

figure(1)
plot(span, bw);hold on;
disp(['Average Bandwidth: ' num2str(mean(bw)/1e6) ' MHz']);
title('Span vs Bandwidth');
xlabel('No. of symbols'); ylabel('Hz');
figure(2)
plot(span, bitErr);
title('Span vs Biterror rate');
xlabel('No. of symbols'); ylabel('BER');


