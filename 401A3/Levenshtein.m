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
num_ref = 30; 

addpath(genpath('/u/cs401/A3_ASR/code/FullBNT-1.0.7/')); 

fid = fopen(hypothesis); 
tline = fgetl(fid); 
arr = {}; 
ind = 0; 
while ischar(tline)
    ind = ind + 1;
    tline = regexprep(tline ,'[.,!"+-<>=?()]+','');
    new = strsplit(' ', tline); 
    arr{ind}= strjoin({new{3:length(new)}}, ' '); 
    tline = fgetl(fid); 
end 
fclose(fid);

%new struct to store reference and predicted 

utterances = dir(annotation_dir); 
utterances = utterances(~ismember({utterances.name},{'.','..'}));

SE_arr = zeros(num_ref, 1); 
IE_arr = zeros(num_ref, 1); 
DE_arr = zeros(num_ref, 1); 
LEV_DIST_arr = zeros(num_ref, 1);  
result_ind = 1; 

%reading utterances from file 
for k = 1: numel(utterances) 
        [patstr, name, ext] = fileparts(utterances(k).name); 
        if strcmp(ext, '.txt') && strncmpi(name, 'unkn', 4)
            fid = fopen([annotation_dir '/' utterances(k).name]);    
            tline = fgetl(fid);
            fclose(fid); 
            num = regexp(name, '[0-9]+', 'match');
            
            %look for reference
            tline = regexprep(tline ,'[.,!"+-<>=?()]+','');
            new_line = strsplit(' ', tline); 
            hyp = arr{str2num(num{1})}; 
            
            
            hyp = strsplit(' ', hyp); 
            ref = {new_line{3:length(new_line)}}; 
            
            M = length(hyp); 
            N = length(ref); 

            R = zeros(N+1, M+1); 
            B = cell(N+1, M+1); 

            R = R*Inf; 
            R(1, 1) = 0; 

            for i=2:N+1
                for j=2:M+1
                    dtemp = R(i-1,j) + 1;
                    if strcmp(ref{i-1}, hyp{j-1})
                        result = 0; 
                    else 
                        result = 1; 
                    end 
                    stemp = R(i-1, j-1) + result; 

                    itemp = R(i, j-1) + 1; 
                    R(i, j) = min([dtemp, stemp, itemp]); 

                    if R(i, j) == dtemp
                        % up 
                        B{i,j} = 'up'; 
                    elseif R(i, j) == itemp
                        % left 
                        B{i,j} = 'left'; 
                    else 
                        % up-left 
                        B{i,j} = 'up-left';       
                    end 
                end 
            end 
        %according to Serena we should return the decimal value of accuracy 
        LEV_DIST_arr(result_ind) = R(N+1, M+1)/N; 
        
        i = N+1; %ref 
        j = M+1; %hyp
        sub_err = 0; 
        del_err = 0; 
        ins_err = 0; 
        while i > 1 && j > 1; 
            if strcmp(B{i, j}, 'up-left')
                i = i - 1; 
                j = j - 1;
                if ~strcmp(ref{i}, hyp{j})
                    sub_err = sub_err + 1; 
                end 
            elseif strcmp(B{i, j}, 'left')
                j = j - 1 ; 
                ins_err = ins_err + 1; 
            else
                i = i - 1; 
                del_err = del_err + 1;
            end 
        end 
        %find deletion, substitution and insertion errors
        SE_arr(result_ind) = sub_err/N;  
        IE_arr(result_ind) = ins_err/N;   
        DE_arr(result_ind) = del_err/N;  
        result_ind = result_ind + 1; 
        end 
        
        
end 

SE = mean(SE_arr); 
IE = mean(IE_arr); 
DE = mean(DE_arr);
LEV_DIST = mean(LEV_DIST_arr);
