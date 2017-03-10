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
delta        = 0; 
numSentences = 1000;
maxIter = 5; 
warning('off','all')

% Train your language models. This is task 2 which makes use of task 1
LME = lm_train( trainDir, 'e', fn_LME );
LMF = lm_train( trainDir, 'f', fn_LMF );

%load existing 
% LME = importdata(fn_LME); 
% LMF = importdata(fn_LMF); 

% Train your alignment model of French, given English 
AMFE = align_ibm1( trainDir, numSentences, maxIter, 'am.mat');


%reading french and english files
%reading French file for translation fre{} 
lines = textread([testDir, 'Task5.f'], '%s','delimiter','\n'); 
fre = {}; 

for l = 1:length(lines)
    fre{l} = preprocess(lines{l}, 'f');
    %creating cell array entry of words of english sentence i 
    %fre{l} = strsplit(' ', processedLine); 
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

vocabSize = length(fieldnames(LME)); 



%initializing result array (easy to calculate mean and var) 
%no specific output was specificed for result in handout 

result = zeros(3, 25); 

% BLEU Analysis

% This includes the SENTSTART and SENTEND markers in sentence
    for i=1:length(fre)
        display(i)
        % Decode the test sentence 'fre'
        sent = decode2(fre{i}, LME, AMFE, '', delta, vocabSize); 
        
        %split sentence into words 
        sent = strsplit(' ', sent); 
        han_sent = han_eng{i}; 
        goog_sent = goog_eng{i}; 
        
        %brevity calculation 
        
        %find reference that is closest in length 
        c_i = length(sent); 
        if abs(c_i-length(goog_sent)) > abs(c_i-length(han_sent))
            r_i = length(han_sent); 
        else 
            r_i = length(goog_sent); 
        end
        %calculate brevity
        brev = r_i/c_i; 
        
        %calculate brevity penalty 
        if brev < 1
            BP = 1; 
        else 
            BP = exp(1-brev); 
        end 
        
        %calcuate precision 
        
        %unigram percision
        u_count = 0; 
        %bigram percision
        b_count = 0; 
        %trigram percison 
        t_count = 0; 
        for w=1:length(sent)
            %check if unigram candidate is in references 
            mat_h = ismember(han_sent, sent{w}); 
            mat_g = ismember(goog_sent, sent{w}); 
            if any(mat_h) || any(mat_g)
                %if in sentence increment unigram count 
                u_count = u_count + 1; 
                bigram_add = 0; 
                trigram_add = 0; 
                
                %since unigram check for bigram occurance by going to
                %location of unigram and checking next word 
                for b=1:(length(mat_h)-1)
                    
                    %check hansard for bigrams
                    if mat_h(b) == 1 && b+1 < length(sent) && strcmp(han_sent{b+1},sent{b+1})
                        bigram_add = 1; 
                        %since bigram confirmed
                        %check for tri gram in hansard translation 
                        if b+2 < length(mat_h) && b+2 < length(sent) && strcmp(han_sent{b+2}, sent{b+2})
                            trigram_add = 1; 
                        end 
                    end 
                end 
                

                for b=1:(length(mat_g)-1)
                    %check google for bigram
                    
                    if mat_g(b) == 1 && b+1 < length(sent) && strcmp(goog_sent{b+1},sent{b+1})
                        bigram_add = 1; 
                        %check for google for trigrams
                        if b+2 < length(mat_g) && b+2 < length(sent) && strcmp(goog_sent{b+2},sent{b+2})
                            trigram_add = 1; 
                        end
                    end 
                end 
                
             %adding count for found bigram and trigram matches  
             %bigram or trigram match in any reference increases count by 1
             b_count = b_count + bigram_add; 
             t_count = t_count + trigram_add; 
            end
        end 
          %calcuate precision by dividing by total uni, bi and trigram
          %count
          u_count = u_count/length(sent); 
          b_count = b_count/(length(sent)-1); 
          t_count = t_count/(length(sent)-2); 
     
          %record results BLEU score 
          %uni precision 
          result(1, i) = BP*u_count; 
          %uni and bi precision 
          result(2, i) = BP*sqrt(u_count*b_count); 
          %uni, bi and tri precision
          result(3, i) = BP*nthroot(u_count*b_count*t_count, 3); 
    end      

%[status, result] = unix('')