dir_train = 'SmallTrain';
e = 0.01; 
max_itr = 20; 
M = 2; 
D = 14; 

addpath(genpath('bnt/BNT'))

%Final all Phonemes% 
phn = struct();
cp = 0; %current phoneme count
speakers = dir(dir_train);
speakers = speakers(~ismember({speakers.name},{'.','..'}));


%create dictionary to keep track of existing phonemes 
% phoneme_map = containers.Map(); 
for s = 1: numel(speakers) 

    utterances = dir([dir_train '/' speakers(s).name]); 
    utterances = utterances(~ismember({utterances.name},{'.','..'}));
    %reading utterances from file 
    for j = 1: numel(utterances)
        [patstr, name, ext] = fileparts(utterances(j).name); 
        
        if strcmp(ext, '.mfcc') 
            fid = fopen([dir_train  '/' speakers(s).name '/' utterances(j).name]);  
            %read mfcc 
            mfcc = fscanf(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f', [14 Inf]); 
            mfcc = mfcc'; 
            fclose(fid); 
        end

        %look for phonemes 
        open_str = [dir_train  '/' speakers(s).name '/' name '.phn']; 
        fid = fopen(open_str); 
        phlist = textscan(fid, '%d %d %s'); 
        fclose(fid); 
        for p = 2: length(phlist{1})-1
            
            %dividing index by 128 considering observation interval 
            ph_start = phlist{1}(p)/128 + 1; 
            ph_end = phlist{2}(p)/128; 
            %extracting phoneme from mfcc file
            data = mfcc(ph_start:ph_end, :); 
            
            %check if we already found phoneme
            if isfield(phn, phlist{3}{p})
             
                %add phoneme to existing data about phoneme 
                data_len = length(phn.(phlist{3}{p}).data); 
                phn.(phlist{3}{p}).data{data_len + 1} = data'; 
            else 
                %create new phoneme 
                phn.(phlist{3}{p}) = struct();  
                phn.(phlist{3}{p}).('data') = {}; 
                phn.(phlist{3}{p}).data{1} = data';
                %increment count of found phonemes
            end 
        end 
        
    end  
end 

phn_fields = fieldnames(phn); 
for i = 1:numel(phn_fields)
    field = char(phn_fields(i)); 
    phn.(field).('HMM') = initHMM(phn.(field).data, M, 3, 'kmeans');
    [HMM, LL] = trainHMM(phn.(field).HMM, phn.(field).data, 5); 
end 

save('phn', 'phn')