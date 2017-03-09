%
% evalAlign
%
%  This is simply the script (not the function) that you use to perform your evaluations in 
%  Task 5. 

% some of your definitions
trainDir     = '/u/cs401/A2_SMT/data/Hansard/Training/';
testDir      = '/u/cs401/A2_SMT/data/Hansard/Testing/';
fn_LME       = 'LME_eng.mod';
fn_LMF       = 'LMF_fre.mod';
lm_type      =  'smooth';
delta        = 0.1;
vocabSize    = TODO; 
numSentences = 1000;
maxIter = 5; 

% Train your language models. This is task 2 which makes use of task 1
LME = lm_train( trainDir, 'e', fn_LME );
LMF = lm_train( trainDir, 'f', fn_LMF );

% Train your alignment model of French, given English 
AMFE = align_ibm1( trainDir, numSentences, maxIter, '1000_ibm.model');

%reading french and english files
%reading French file for translation fre{} 
lines = textread([testDir, 'Task5.f'], '%s','delimiter','\n'); 
fre = {}; 

for l = 1:length(lines)
    processedLine = preprocess(lines{l}, 'f');
    %creating cell array entry of words of english sentence i 
    fre{l} = strsplit(' ', processedLine); 
end 

%reading Hanson english translation
han_eng = {}; 
lines = textread([testDir, 'Task5.e'], '%s','delimiter','\n'); 
for l = 1:length(lines)
    processedLine = preprocess(lines{l}, 'e');
    %creating cell array entry of words of english sentence i 
    han_eng{l} = strsplit(' ', processedLine); 
end 

%readign google translation
goog_eng = {}; 
lines = textread([testDir, 'Task5.google.e'], '%s','delimiter','\n'); 
for l = 1:length(lines)
    processedLine = preprocess(lines{l}, 'e');
    %creating cell array entry of words of english sentence i 
    goog_eng{l} = strsplit(' ', processedLine); 
end 


% Decode the test sentence 'fre'
eng = decode( fre, LME, AMFE, 'smooth', delta, vocabSize );

% BLEU Analysis
for n=1:3
    for i=1:length(fre)
        sent = eng{1}{i}; 
        han_sent = han_eng{1}{i}; 
        goog_sent = goog_eng{1}{i}; 
        
        c_i = length(sent); 
        
        if abs(c_i-length(goog_sent)) > abs(c_i-length(han_sent))
            r_i = length(han_sent); 
        else 
            r_i = length(goog_sent); 
        end
        brev = r_i/c_i; 
        
        %numtiply percison by brevity penalty 
        if brev < 1
            BP = 1; 
        else 
            BP = exp(1-brev); 
        end 
        
        %unigram percision
        u_count = 0; 
        %bigram percision
        b_count = 0; 
        for w=1:length(sent)
            mat_h = any(ismember(han_sent, sent{w})); 
            mat_g = any(ismember(han_sent, sent{w})); 
            if mat_h || mat_g
                u_count = u_count + 1; 
                bigram = [sent{w}, sent{w+1}]; 
                if ismember(bigram, han_sent) || ismember(bigram, goog_sent)
                    bigram_
                end 
                    
            end 
        end 
         
        %bigram percision
        
        %trigram percison 
    end 
end 


[status, result] = unix('')