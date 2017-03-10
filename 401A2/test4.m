%%Setting parameters 

trainDir     = '/u/cs401/A2_SMT/data/Hansard/Training/';
numSentences = 10000;
maxIter = 5; 
display('beginning training') 

%% part 1 1k 
numSentences = 1000; 
MFE = align_ibm1( trainDir, numSentences, 10, '1000x10_ibm.model');
display('done 1000')

%% part 2 10k 
numSentences = 10000;
AMFE = align_ibm1( trainDir, numSentences, maxIter, '10000_ibm.model');
display('done 10000')

%% part 3 15k 
numSentences = 15000; 
AMFE = align_ibm1( trainDir, numSentences, maxIter, '15000_ibm.model');
display('done 15000')

%% part 4 30k
numSentences = 30000; 
AMFE = align_ibm1( trainDir, numSentences, maxIter, '30000_ibm.model');
display('done 30000')