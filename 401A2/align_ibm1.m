function AM = align_ibm1(trainDir, numSentences, maxIter, fn_AM)
%
%  align_ibm1
% 
%  This function implements the training of the IBM-1 word alignment algorithm. 
%  We assume that we are implementing P(foreign|english)
%
%  INPUTS:
%
%       dataDir      : (directory name) The top-level directory containing 
%                                       data from which to train or decode
%                                       e.g., '/u/cs401/A2_SMT/data/Toy/'
%       numSentences : (integer) The maximum number of training sentences to
%                                consider. 
%       maxIter      : (integer) The maximum number of iterations of the EM 
%                                algorithm.
%       fn_AM        : (filename) the location to save the alignment model,
%                                 once trained.
%
%  OUTPUT:
%       AM           : (variable) a specialized alignment model structure
%
%
%  The file fn_AM must contain the data structure called 'AM', which is a 
%  structure of structures where AM.(english_word).(foreign_word) is the
%  computed expectation that foreign_word is produced by english_word
%
%       e.g., LM.house.maison = 0.5       % TODO
% 
% Template (c) 2011 Jackie C.K. Cheung and Frank Rudzicz
  
  global CSC401_A2_DEFNS
  
  AM = struct();
  
  % Read in the training data
  [eng, fre] = read_hansard(trainDir, numSentences);

  % Initialize AM uniformly 
  AM = initialize(eng, fre);

  % Iterate between E and M steps
  for iter=1:maxIter,
    AM = em_step(AM, eng, fre);
  end

  % Save the alignment model
  save( fn_AM, 'AM', '-mat'); 

  end





% --------------------------------------------------------------------------------
% 
%  Support functions
%
% --------------------------------------------------------------------------------

function [eng, fre] = read_hansard(mydir, numSentences)
%
% Read 'numSentences' parallel sentences from texts in the 'dir' directory.
%
% Important: Be sure to preprocess those texts!
%
% Remember that the i^th line in fubar.e corresponds to the i^th line in fubar.f
% You can decide what form variables 'eng' and 'fre' take, although it may be easiest
% if both 'eng' and 'fre' are cell-arrays of cell-arrays, where the i^th element of 
% 'eng', for example, is a cell-array of words that you can produce with
%
%         eng{i} = strsplit(' ', preprocess(english_sentence, 'e'));
%
  %eng = {};
  %fre = {};

  % TODO: your code goes here.
  % collecting english sentences
  eng = {}; 
  i = 0; 
  DD        = dir( [ testDir, filesep, '*', 'e'] );
  for iFile=1:length(DD)

  lines = textread([testDir, filesep, DD(iFile).name], '%s','delimiter','\n');

    for l=1:length(lines)

        processedLine = preprocess(lines{l}, 'e');
        eng{i} = strsplit(' ', processedLine); 
        i = i + 1; 
    end
  end
  
    % collecting english sentences
  fre = {}; 
  i = 0; 
  DD = dir( [ testDir, filesep, '*', 'f'] );
  for iFile=1:length(DD)

  lines = textread([testDir, filesep, DD(iFile).name], '%s','delimiter','\n');

    for l=1:length(lines)

        processedLine = preprocess(lines{l}, 'f');
        fre{i} = strsplit(' ', processedLine); 
        i = i + 1; 
    end
  end

end


function AM = initialize(eng, fre)
%
% Initialize alignment model uniformly.
% Only set non-zero probabilities where word pairs appear in corresponding sentences.
%
    AM = {}; % AM.(english_word).(foreign_word)

    % TODO: your code goes here
    for i=1:length(eng);
        eng_sent = eng(i); 
        french_sent = fre(i);
        for w=1:length(eng_sent)
            eng_word = char(eng_sent(w)); 
            if isfield(AM, eng_word) == false
                AM.(eng_word) = 1; 
            end 
            for j=1:length(fre_sent)
                fre_word = french_sent(j); 
                add_prob = 1/(length(eng_sent)); 
                if isfield(AM.(eng_word), fre_word)
                    AM.(eng_word).(fre_word) = AM.(eng_word).(fre_word) + add_prob; 
                else 
                    AM.(eng_word).(fre_word) = add_prob; 
                end 
            end 
        end 
    end 

end

function t = em_step(t, eng, fre)
% 
% One step in the EM algorithm.
%
  
  % TODOTODOTODOTODOTODOTODO 
  tcount = zeros(, length(t.fieldnames)); 
  total = zeros(length(eng)); 
  
  for i=length(eng)
      eng_sent = eng(i); 
      fre_sent = fre(i); 
      eng_dict = {}; 
      fre_dict = {}; 
      %building frequency count 
      for e=1:length(eng_sent)
          eng_word = char(eng_sent(e)); 
          if isfield(eng_dict, eng_word)
              eng_dict.(eng_word) = eng_dict.(eng_word) + 1; 
          else 
              eng_dict.(eng_word) = 1; 
          end 
      end 
      
      for f=1:length(fre_sent)
          fre_word = char(fre_sent(f)); 
          if isfield(fre_dict, fre_word)
              fre_dict.(fre_word) = fre_dict.(fre_word) + 1; 
          else 
              fre_dict.(fre_word) = 1; 
          end 
      end 
      
      %words non unique
      f_fields = fieldnames(fre_dict); 
      for f=1:numel(f_fields)
          denom_c = 0; 
          fre_word = fre_dict.(f_fields(f)); 
          e_fields = fieldnames(eng_dict); 
          for e=1:numel(e_field)
              eng_word = eng_dict.(e_fields(e)); 
              %assume bigram already in AM model 
              P_ef = t.(eng_word).(fre_word); 
              denom_c = denom_c + P_ef*fre_dict.(fre_word);
          end 
          for e=1:numel(e_field)
              eng_word = eng_dict.(e_fields(e)); 
              %assume bigram already in AM model 
              P_ef = t.(eng_word).(fre_word); 
              tcount(f, e) = tcount(f, e) + P_ef*fre_dict.(fre_word)*eng_dict.(eng_word)/denom_c; 
              total(e) = total(e) + P_ef*fre_dict.(fre_word)*eng_dict.(eng_word)/denom_c;
          end 
      end      
  end 
  
  for e=1:length(eng)
      for f=1:length(fre)
          
      
end


