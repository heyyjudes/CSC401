dir_train = '/u/cs401/speechdata/Testing';

addpath(genpath('bnt/'))

str_arr = {'phn_m4d14n1h.mat', 'phn_m8d14n3h.mat', 'phn_m8d14n1h.mat'};

for mn = 1:numel(str_arr) 
    phn = load(str_arr{mn});
    phn = phn.phn; 
    %Final all Phonemes% 
    D = 14; 

    speakers = dir(dir_train);
    speakers = speakers(~ismember({speakers.name},{'.','..'}));
    total = 0; 
    correct = 0; 
    for s = 1: numel(speakers) 

            [patstr, name, ext] = fileparts(speakers(s).name); 

            if strcmp(ext, '.mfcc') 
                fid = fopen([dir_train  '/' speakers(s).name]);  
                %read mfcc 
                mfcc = fscanf(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f', [14 Inf]); 
                mfcc = mfcc(1:D, :); 
                mfcc = mfcc'; 
                fclose(fid); 

                display(speakers(s).name)
                %look for phonemes 
                open_str = [dir_train  '/' name '.phn']; 
                fid = fopen(open_str); 
                phlist = textscan(fid, '%d %d %s'); 
                fclose(fid); 
                for p = 2: length(phlist{1})-1

                    %dividing index by 128 considering observation interval 
                    ph_start = phlist{1}(p)/128 + 1; 
                    ph_end = phlist{2}(p)/128; 
                    %extracting phoneme from mfcc file
                    data = mfcc(ph_start:ph_end, :); 
                    %display actual target
                    %display(['Actual: ' char(phlist{3}{p})])

                    phn_fields = fieldnames(phn); 
                    Phn_prob = zeros(length(phn_fields), 1);
                    Phn_targ = {}; 

                    for i = 1:numel(phn_fields)
                        field = char(phn_fields(i)); 
                        try
                            LL = loglikHMM(phn.(field).HMM, data'); 
                        catch 
                            LL = -Inf; 
                        end 
                        Phn_prob(i) = LL;
                        Phn_targ{i} = field; 
                    end 

                    m_ind = argmax(Phn_prob); 
                    %display(['LL: ' int2str(Phn_prob(m_ind))]); 
                    %display(['Predicted: ' char(Phn_targ{m_ind})]); 
                    if strcmp(char(phlist{3}{p}), char(Phn_targ{m_ind}))
                        correct = correct + 1; 
                    end 
                    total = total +1; 
                end 
            end  
    end
    result = 1.0*correct/total; 
    display(['Accuracy: ' num2str(1.0*correct/total)]);
    save(['result_' str_arr{mn}], 'result');  
end