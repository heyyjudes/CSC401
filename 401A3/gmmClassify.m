train = '/u/cs401/speechdata/Training';
test = '/u/cs401/speechdata/Testing';
e = 100; 
max_itr = 20; 
M = 50; 
D = 14; 

model = gmmTrain(train, max_itr, e, M); 
%model = load('gmms.mat'); 
%model = model.gmms; 

%read target labels
fileID = fopen('TestingIDs1-15.txt');

formatSpec = '%s';
N = 3;
C_text = textscan(fileID,formatSpec,N,'Delimiter',':');
C_data0 = textscan(fileID,  '%d : %s : %s'); 
unknown = C_data0{1};
unknown_file = C_data0{2}; 

fclose(fileID); 
%reading utterances from file 
speakers = dir(test);
speakers_mfcc = {}; 

num = 1; 
for j = 1: numel(speakers)
    [patstr, name, ext] = fileparts(speakers(j).name); 
    if strcmp(ext, '.mfcc') 
       speakers_mfcc{num} = speakers(j).name; 
       num = num + 1; 
    end 
end 
corr = 0; 
for j = 1: numel(speakers_mfcc)
    x_test = []; 
    fid = fopen([test  '/' speakers_mfcc{j}]);  
    %read mfcc 
    x_test = fscanf(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f', [14 Inf]); 
    x_test = x_test'; 
    fclose(fid); 
    display(speakers_mfcc{j})
    
    L = zeros(length(model), 1); 
    
    for i = 1:length(x_test)
    likelihood = zeros(M, length(model)); 
    x_i = x_test(i, :)'; 
    for s = 1:length(model)
        for m = 1:M
            mean_m = model(s).means(:, m);
            cov_m = model(s).cov(:,:,m);
            inv_cov_m = inv(cov_m);

            likelihood(m, s) = model(s).weights(m)/((2*pi)^D * sqrt(det(cov_m))) * exp(-1/2*(x_i - mean_m)'*inv_cov_m*(x_i - mean_m));
        end
     

        L(s) = L(s) + log(sum(likelihood(:, s)));
     end

    end
    [sortedX, sortingIndicies] = sort(L, 'descend'); 
    maxValue = sortedX(1:5); 
    
   
    num = regexp(speakers_mfcc{j}, '[0-9]+', 'match');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %writing to file for Question 2.2  %
    %commented out for final submission%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %unkn_str = ['unkn_' num{1} '.lik'];
    %wrfileID = fopen(unkn_str, 'w');
    %nbytes = fprintf(wrfileID, '%5d \n', maxValue); 
    %fclose(wrfileID); 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %calculating accuracy for part3    %
    %commented out for final submission%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    num = str2num(num{1}); 
    if num < 16 
        if strcmp(model(sortingIndicies(1)).name, unknown_file{num}) 
            corr = corr + 1; 
        end 
    end 
    
    
end 
display(['Accuracy: ' num2str(1.0*corr/15)])




