function decimalValues = binarytodecimal(inputFile,plotFlag)
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
    % Plot the recovered decimal values
    figure;
    stem(decimalValues, 'filled', 'LineWidth', 1.5);
    xlabel('Sample Index');
    ylabel('Amplitude');
    title('Recovered Decimal Values from Q7 Binary');
    grid on;
end
