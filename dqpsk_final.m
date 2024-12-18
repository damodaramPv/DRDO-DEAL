clc
clear
close all

%% Parameters Declaration
dataRate = 2.5e6;                
M = 2;                 
symbolRate = dataRate / M;
samplesPerSymbol = 4;
rolloff = 0.35;
span = 5;
% Sampling frequency
Fs = symbolRate * samplesPerSymbol;
Ts = 1 / Fs;

%% Input data
% Values from RTL
dataBits = valuesScript('RTL_data/message_input_newone.dat'); 

% Values from MATLAB
% dataBits = randi([0,1], 512, 1);

numBits = length(dataBits);
numSymbols = numBits/M;

%% Time vector decalration
numSamples = numSymbols*samplesPerSymbol;
timeVector = (0:numSamples-1) * Ts; % Time vector in seconds

%% Modulator and demodulator declaration
dqpskMod = comm.DQPSKModulator('BitInput', true,'PhaseRotation', 5*pi/4); % start fron pi/4 
dqpskDemod = comm.DQPSKDemodulator('BitOutput', true,'PhaseRotation', 5*pi/4);

%% Modulation
modSymbols = dqpskMod(dataBits);

figure(1)
subplot(2,1,1)
stem(real(modSymbols));
title('Modulated Symbols (Real)');
xlabel('Index'); ylabel('Amplitude');
subplot(2,1,2)
stem(imag(modSymbols));
title('Modulated Symbols(Imaginary)');
xlabel('Index'); ylabel('Amplitude');
%% Upsampling 
upsampledSymbols = upsample(modSymbols, samplesPerSymbol); % sps = 4

figure(2)
subplot(2,1,1)
stem(timeVector * 1e6,real(upsampledSymbols));
title('Upsampled Modulated Symbols (Real)');
xlabel('Time (\mus)'); ylabel('Amplitude');
subplot(2,1,2)
stem(timeVector * 1e6,imag(upsampledSymbols));
title('Upsampled Modulated Symbols(Imaginary)');
xlabel('Time (\mus)'); ylabel('Amplitude');
%% Pulse shaping
rrcFilter = rcosdesign(rolloff, span, samplesPerSymbol);

shapedSignal = conv(upsampledSymbols, rrcFilter, 'same'); % taking the middle part

figure(3)
subplot(2,1,1)
plot(timeVector * 1e6, real(shapedSignal));
title('Pulse Shaped Signal (Real Part)');
xlabel('Time (\mus)'); ylabel('Amplitude');
subplot(2,1,2)
plot(timeVector * 1e6, imag(shapedSignal));
title('Pulse Shaped Signal (Imaginary)');
xlabel('Time (\mus)'); ylabel('Amplitude');

%% Bandwidth
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

figure(6)
plot(frequencies / 1e6, 10*log10(powerSpectralDensity));
title('Power Spectral Density');
xlabel('Frequency (MHz)'); ylabel('Power (dB)');
grid on;

%% Filtering
% Filter the received signal with the same RRC filter
filteredSignal = conv(shapedSignal, rrcFilter, 'same');

figure(4)
subplot(2,1,1)
plot(timeVector * 1e6, real(filteredSignal));
title('Pulse Shaped Signal (Real Part)');
xlabel('Time (\mus)'); ylabel('Amplitude');
subplot(2,1,2)
plot(timeVector * 1e6, imag(filteredSignal));
title('Pulse Shaped Signal (Imaginary)');
xlabel('Time (\mus)'); ylabel('Amplitude');

%% Downsample to symbol rate
downsampledSignal = filteredSignal(1:samplesPerSymbol:end);

figure(5)
subplot(2,1,1)
stem(real(downsampledSignal));
title('Upsampled Modulated Symbols (Real)');
xlabel('Index'); ylabel('Amplitude');
subplot(2,1,2)
stem(imag(downsampledSignal));
title('Upsampled Modulated Symbols(Imaginary)');
xlabel('Index'); ylabel('Amplitude');

%% Demodulation
demodBits = dqpskDemod(downsampledSignal);

% Bit error rate
[numErros, ber] = biterr(dataBits, demodBits);
disp(['Number of Errors: ' num2str(numErros)]);
disp(['Bit Error Rate: ' num2str(ber) ]);
%% RTL Checking RRC Filtered Values

rtl_RRC_i = importdata('C:\Users\panna\OneDrive\Desktop\Study\comms pro\Drdo\RTL_data\RTL_RRC_i_d.mat');
rtl_RRC_q = importdata('C:\Users\panna\OneDrive\Desktop\Study\comms pro\Drdo\RTL_data\RTL_RRC_q_d.mat');

rtl_RRC_i_tr = rtl_RRC_i(19:146); % trucating initial values
rtl_RRC_q_tr = rtl_RRC_q(19:146);

figure(6)
subplot(2,1,1)
plot(timeVector * 1e6,real(rtl_RRC_i_tr),'ro-','LineWidth', 1.25); hold on
plot(timeVector * 1e6,real(shapedSignal),'bo-','LineWidth', 1.25); 
title('Tx after RRC (Real)');
xlabel('Time (\mus)'); ylabel('Amplitude'); hold off 

subplot(2,1,2)
plot(timeVector * 1e6,real(rtl_RRC_q_tr),'ro-','LineWidth', 1.25); hold on
plot(timeVector * 1e6,imag(shapedSignal),'bo-','LineWidth', 1.25); 
title('Tx after RRC (Real)');
xlabel('Time (\mus)'); ylabel('Amplitude'); hold off 

%% RTL Checking Matched Filtered Values

rtl_Matched_i = importdata('C:\Users\panna\OneDrive\Desktop\Study\comms pro\Drdo\RTL_data\RTL_Matched_i_d.mat');
rtl_Matched_q = importdata('C:\Users\panna\OneDrive\Desktop\Study\comms pro\Drdo\RTL_data\RTL_Matched_q_d.mat');

rtl_Matched_i_tr = rtl_Matched_i(14:141);
rtl_Matched_q_tr = rtl_Matched_q(14:141);

figure(7)
subplot(2,1,1)
plot(timeVector * 1e6,real(rtl_Matched_i_tr),'ro-','LineWidth', 1.25); hold on
plot(timeVector * 1e6,real(filteredSignal),'bo-','LineWidth', 1.25); 
title('Rx after Matched Filter (Imaginary)');
xlabel('Time (\mus)'); ylabel('Amplitude'); hold off 

subplot(2,1,2)
plot(timeVector * 1e6,real(rtl_Matched_q_tr),'ro-','LineWidth', 1.25); hold on
plot(timeVector * 1e6,imag(filteredSignal),'bo-','LineWidth', 1.25); 
title('Rx after Matched Filter (Imaginary)');
xlabel('Time (\mus)'); ylabel('Amplitude'); hold off 

%% Dowmsampling RTL Values

downsampledSignal_RTL = rtl_Matched_i_tr(1:samplesPerSymbol:end) + 1j*rtl_Matched_q_tr(1:samplesPerSymbol:end);

figure(8)
subplot(2,1,1)
stem(real(downsampledSignal_RTL));
title('Dowmsampled Modulated Symbols (Real)');
xlabel('Index'); ylabel('Amplitude');
subplot(2,1,2)
stem(imag(downsampledSignal_RTL));
title('Dowmsampled Modulated Symbols(Imaginary)');
xlabel('Index'); ylabel('Amplitude');

%% Error of demodulation symbols in RTL

errSymbols_RTL = downsampledSignal - downsampledSignal_RTL;

disp(['Mean error in demodulated symbols in RTL: ' num2str(abs(mean(errSymbols_RTL))*100) '%']);

figure(9)
subplot(2,1,1)
stem(real(errSymbols_RTL));
title('Error in Demodulated Symbols in RTL (Real)');
xlabel('Index'); ylabel('Amplitude');
subplot(2,1,2)
stem(imag(errSymbols_RTL));
title('Error in Demodulated Symbols in RTL (Real)');
xlabel('Index'); ylabel('Amplitude');

%% Demodulation of RTL symbols
demodBits_RTL = dqpskDemod(downsampledSignal_RTL);

% Bit error rate
[numErros_RTL, ber_RTL] = biterr(dataBits, demodBits_RTL);
disp(['Number of Errors in RTL: ' num2str(numErros_RTL)]);
disp(['Bit Error Rate in RTL: ' num2str(ber_RTL)]);

%% constellation symbols in MATLAB

figure(10)
plot(real(downsampledSignal),imag(downsampledSignal));
title('Demodulated Symbols');
grid on;
xlabel('Real Part'); ylabel('Imaginary Part');

%% constellation symbols in MATLAB

figure(11)
plot(real(downsampledSignal),imag(downsampledSignal));
title('Demodulated Symbols');
grid on;
xlabel('Real Part'); ylabel('Imaginary Part');
