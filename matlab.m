clc;
close all;

%numBits  = 100;
% Opening input data from RTL
% dataBits = valuesScript('RTL_data/message_input_newone.dat');
% dataBits = zeros(numBits,1);
%% Input datag
% Values from RTL
dataBits = valuesScript('/home/vicky007/Downloads/inp_bin_expanded2_full_converted.dat'); 
dataBits12 = dataBits(:);  % Convert to column vector

%% Modulator and demodulator declaration
dqpskMod = comm.DQPSKModulator('BitInput', true,'PhaseRotation', 5*pi/4); % start fron pi/4 
dqpskDemod = comm.DQPSKDemodulator('BitOutput', true,'PhaseRotation', 5*pi/4);

% Modulate the data
modSymbols = dqpskMod(dataBits12);

% Save modulated symbols to a file
save('modulatedSymbols.mat', 'modSymbols');

% Getting JK Values from RTL
j_RTL = binarytodecimal('/home/vicky007/Documents/j_values_top.dat', 0);
k_RTL = binarytodecimal('/home/vicky007/Documents/k_values_top.dat', 0);

rtl_modsymbols = j_RTL + 1i*k_RTL;

% Difference between those
conc = [modSymbols rtl_modsymbols];
diff = modSymbols - rtl_modsymbols;

% -------- Function Definition --------
function decimalValues = binarytodecimal(inputFile, plotFlag)
    fid_in = fopen(inputFile, 'r');
    if fid_in == -1
        error('Failed to open the input file.');
    end
    decimalValues = [];
    wordLength = 16;  
    scaleFactor = 2^14;  

    while ~feof(fid_in)
        binaryLine = strtrim(fgetl(fid_in)); 
        intValue = bin2dec(binaryLine);  
        if intValue >= 2^(wordLength - 1)  
            intValue = intValue - 2^wordLength;
        end
        decimalValue = double(intValue) / scaleFactor;
        decimalValues = [decimalValues; decimalValue];
    end
    fclose(fid_in);

    if plotFlag
        figure;
        stem(decimalValues, 'filled', 'LineWidth', 1.5);
        xlabel('Sample Index');
        ylabel('Amplitude');
        title('Recovered Decimal Values from Q7 Binary');
        grid on;
    end
end

function data_bits = valuesScript(inputFilePath)
    res = [];
    fileID = fopen(inputFilePath, 'r');
    if fileID == -1
        error('Failed to open the input file.');
    end
    while ~feof(fileID)
        line = fgetl(fileID); % Read a line
        if ischar(line)
            line = strtrim(line);  % Remove whitespace
            % Reverse the string
            reversed_line = line(end:-1:1);
            res = [res, reversed_line];  % Append reversed bits
        end
    end
    fclose(fileID);

    % Convert characters '0'/'1' to numeric bits 0/1
    data_bits = double(res) - double('0');
end

