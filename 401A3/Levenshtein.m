function [SE IE DE LEV_DIST] =Levenshtein(hypothesis,annotation_dir)
% Input:
%	hypothesis: The path to file containing the the recognition hypotheses
%	annotation_dir: The path to directory containing the annotations
%			(Ex. the Testing dir containing all the *.txt files)
% Outputs:
%	SE: proportion of substitution errors over all the hypotheses
%	IE: proportion of insertion errors over all the hypotheses
%	DE: proportion of deletion errors over all the hypotheses
%	LEV_DIST: proportion of overall error in all hypotheses


%read hypothesis

SE = 0; 
IE = 0; 
DE = 0; 
LEV_DIST = 0; 
addpath(genpath('bnt/')); 
fid = fopen(hypothesis); 
tline = fgetl(fid); 
arr = {}; 
ind = 0; 
while ischar(tline)
    ind = ind + 1; 
    tline = fgetl(fid); 
    new = strsplit(' ', tline); 
    arr{ind}{1} = new{2}; 
    arr{ind}{2} = strjoin(new{3:length(new)}, ' '); 
    

end 
fclose(fid);

%new struct to store reference and predicted 

utterances = dir(annotation_dir); 
utterances = utterances(~ismember({utterances.name},{'.','..'}));
%reading utterances from file 
for j = 1: numel(utterances) 
        [patstr, name, ext] = fileparts(utterances(j).name); 
        if strcmp(ext, '.txt') && strncmpi(name, 'unkn', 4)
            fid = fopen([annotation_dir '/' utterances(j).name]);    
            tline = fgetl(fid);  
            fclose(fid); 
        end 
        
        %look for reference
        new_line = strsplit(' ', tline); 
        for i=1:length(arr)
            if strcmp(arr{i}{1}, new_line{1}{2})
                hyp = arr{i}{2}; 
            else
                display('cannot find match reference')
            end 
        end 
        
        hyp = strsplit(' ', hyp); 
        ref = new_line{1}{3:length(new_line)}; 
        
        M = length(hyp); 
        N = length(ref); 
        
        R = zeros(N+1, M+1); 
        B = zeros(N+1, M+1); 
        
        R = R*Inf; 
        R(0, 0) = 0; 
        
        for i=2:N
            for j=2:M
                dtemp = R(i-1,j-1) + 1;
                if strcmp(ref{i}, hyp{j})
                    result = 1; 
                else 
                    result = 0; 
                end 
                stemp = R(i-1, j-1) + result; 
                
                itemp = R(i, j-1) + 1; 
                R(i, j) = min([dtemp, stemp, itemp]); 
                
                if R(i, j) == dtemp
                    % up 
                    B(i, j) = 1; 
                elseif R(i, j) == itemp
                    % left 
                    B(i, j) = 2; 
                else 
                    % up-left 
                    B(i, j) = 3;       
                end 
            end 
        end 
        
        LEV_DIST = 100*R(N, M)/N; 
        
        
end 
