function [reference_size, feedback_size, output_size] = GetSizes(file_path, reference_name, feedback_name, output_name)
    
    % Retrieve input and output sizes from compiled .h file

    % file_path - Complete path to .h file (String)
    % reference_name, feedback_name, output_name - Given names on simulink program (String) 

    text = fileread(file_path);     % open file as string
    lines = regexp(text, '\n', 'split'); % split into lines

    % Lines that contains substring also contains input/output size
    substr_reference = " /* '<Root>/" + reference_name +"' */";
    substr_feedback = " /* '<Root>/" + feedback_name +"' */";
    substr_output = " /* '<Root>/" + output_name +"' */";

    substr_vec = [substr_reference substr_feedback substr_output];

    sizes = {0,0,0};
    
    for j=1:length(substr_vec) %
        for i=1:length(lines) %  Search every line
            if contains(string(lines(i)), substr_vec(j)) % Find line that contains input/output size
                sizes{j} = str2double(cell2mat(extractBetween(lines(i),"[","]"))); % Extract size from line
            end
        end    
    end

    [reference_size, feedback_size, output_size] = sizes{:};
end

