clc
clear
close all

% Parameters
dataRate = 2.5e6;                
M = 2;                 
symbolRate = dataRate / M; % Symbol rate (symbols per second)

samplesPerSymbol = 8;
rolloff = 0.35;
span = 6;
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
rrcFilter = rcosdesign(rolloff, span, samplesPerSymbol);

% Apply pulse shaping
shapedSignal = conv(upsampledSymbols, rrcFilter, 'same');

% Time vector
numSamples = length(shapedSignal);
timeVector = (0:numSamples-1) * Ts; % Time vector in seconds

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

% Display results
disp(['Data Rate: ' num2str(dataRate / 1e6) ' Mbps']);
disp(['Symbol Rate: ' num2str(symbolRate / 1e6) ' MSymbols/sec']);
disp(['Sampling Frequency: ' num2str(Fs / 1e6) ' MHz']);
disp(['Estimated 99% Bandwidth: ' num2str(bandwidth / 1e6) ' MHz']);

% Plot
figure;
figure(1)
subplot(2,1,1)
plot(timeVector * 1e6, real(shapedSignal));
title('Pulse Shaped Signal (Real Part)');
xlabel('Time (\mus)'); ylabel('Amplitude');
subplot(2,1,2)
plot(timeVector * 1e6, imag(shapedSignal));
title('Pulse Shaped Signal (Imaginary)');
xlabel('Time (\mus)'); ylabel('Amplitude');

figure(2)
plot(frequencies / 1e6, 10*log10(powerSpectralDensity));
title('Power Spectral Density');
xlabel('Frequency (MHz)'); ylabel('Power (dB)');
grid on;

samplDownUp = upsample(downsampledSignal,samplesPerSymbol);
figure(3)
subplot(2,1,1)
plot(timeVector * 1e6,real(filteredSignal));hold on
stem(timeVector * 1e6,real(samplDownUp),'r');
stem(timeVector * 1e6,real(upsampledSymbols),'g');hold off
title('Demodulated signal Sampled (Real');
xlabel('Amplitude'); ylabel('Time (\mus)');
subplot(2,1,2)
plot(timeVector * 1e6,imag(filteredSignal));hold on
stem(timeVector * 1e6,imag(samplDownUp),'r');
stem(timeVector * 1e6,imag(upsampledSymbols),'g');hold off
title('Demodulated signal Sampled (Imaginary');
xlabel('Amplitude'); ylabel('Time (\mus)');

diff = samplDownUp-upsampledSymbols;
figure(4)
subplot(2,1,1)
stem(timeVector * 1e6, real(diff));
title('Error in Demodulated Symbols(Real)');
xlabel('Amplitude'); ylabel('Samples');
subplot(2,1,2)
stem(timeVector * 1e6, imag(diff));
title('Error in Demodulated Symbols(Imaginary)');
xlabel('Amplitude'); ylabel('Samples');


figure(5)
plot(real(downsampledSignal),imag(downsampledSignal));
title('Demodulated Symbols');
xlabel('Real Part'); ylabel('Imaginary Part');
