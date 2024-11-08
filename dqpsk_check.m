clc
close all

numBits  = 100;
% Openin input data from RTL
% dataBits = valuesScript('RTL_data/message_input_newone.dat');
% dataBits = zeros(numBits,1);
dataBits = a;
% Create DQPSK Modulator and Demodulator objects
dqpskMod = comm.DQPSKModulator('BitInput', true);
dqpskDemod = comm.DQPSKDemodulator('BitOutput', true);

% Modulate the data
modSymbols = dqpskMod(dataBits);

% Save modulated symbols to a file
save('modulatedSymbols.mat', 'modSymbols');

% Getting JK Vales from RTL
j_RTL = binarytodecimal('RTL_data/j_values2.dat',0);
k_RTL = binarytodecimal('RTL_data/k_values2.dat',0);

rtl_modsymbols = j_RTL + 1i*k_RTL;

% Difference between those
conc = [modSymbols rtl_modsymbols];
diff = modSymbols - rtl_modsymbols;
df2 = conc(:,1) - conc(:,2);


