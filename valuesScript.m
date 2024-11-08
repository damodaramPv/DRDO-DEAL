function data_bits = valuesScript(inputFilePath)
res = [];
fileID = fopen(inputFilePath, 'r');
if fileID == -1
    error('Failed to open the input file.');
end
while ~feof(fileID)
    line = fgetl(fileID); % Read a line from the file
    if ischar(line)       % Ensure the line is valid
        line = strtrim(line);            % Strip whitespace
        i = length(line) - 1;
        while i >= 1
            res = [res, line(i:i+1)];
            i = i - 2;
        end
    end
end
fclose(fileID);
data_bits = str2double(cellstr(res(:)));
