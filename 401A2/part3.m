
%% Toy example 
%LM = lm_train('/u/cs401/A2_SMT/data/Toy', 'e', 'hanson_toy.mod');
%done = 'done training'
%pp = perplexity(LM, '/u/cs401/A2_SMT/data/Toy', 'e', 'smooth', 0.3) 


%% English Training
warning('off','all')
%LM = lm_train('/u/cs401/A2_SMT/data/Hansard/Testing/', 'e', 'hanson_eng.mod');
%done = 'done training'
LM = importdata('hanson_eng.mod');
pp0 = perplexity(LM, '/u/cs401/A2_SMT/data/Hansard/Testing/', 'e', '', 0) 
pp1 = perplexity(LM, '/u/cs401/A2_SMT/data/Hansard/Testing/', 'e', 'smooth', 0.1) 
pp2 = perplexity(LM, '/u/cs401/A2_SMT/data/Hansard/Testing/', 'e', 'smooth', 0.2) 
pp6 = perplexity(LM, '/u/cs401/A2_SMT/data/Hansard/Testing/', 'e', 'smooth', 0.6) 
pp9 = perplexity(LM, '/u/cs401/A2_SMT/data/Hansard/Testing/', 'e', 'smooth', 0.9) 

%% French Training 
warning('off','all')
LM = lm_train('/u/cs401/A2_SMT/data/Hansard/Testing/', 'f', 'hanson_fr.mod');
done = 'done training'
LM = importdata('hanson_fr.mod'); 
pp0 = perplexity(LM, '/u/cs401/A2_SMT/data/Hansard/Testing/', 'e', '', 0) 
pp1 = perplexity(LM, '/u/cs401/A2_SMT/data/Hansard/Testing/', 'e', 'smooth', 0.1) 
pp2 = perplexity(LM, '/u/cs401/A2_SMT/data/Hansard/Testing/', 'e', 'smooth', 0.2) 
pp6 = perplexity(LM, '/u/cs401/A2_SMT/data/Hansard/Testing/', 'e', 'smooth', 0.6) 
pp9 = perplexity(LM, '/u/cs401/A2_SMT/data/Hansard/Testing/', 'e', 'smooth', 0.9) 