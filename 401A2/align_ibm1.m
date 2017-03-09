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
      display(iter)
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
  % preallocate for faster run time
  eng{1, numSentences} = [] ;  
  i = 1; 
  DD        = dir( [ mydir, filesep, '*', 'e'] );
  for iFile=1:length(DD)

  lines = textread([mydir, filesep, DD(iFile).name], '%s','delimiter','\n');

    for l=1:length(lines)
        if i > numSentences 
            break; 
        end 
        processedLine = preprocess(lines{l}, 'e');
        %creating cell array entry of words of english sentence i 
        eng{i} = strsplit(' ', processedLine); 
        i = i + 1; 
    end 
        
  end 

  % collecting french sentences
  % preallocate for faster runtime 
  fre{1, numSentences} = [] ; 
  i = 1; 
  DD = dir( [ mydir, filesep, '*', 'f'] );
  for iFile=1:length(DD)

  lines = textread([mydir, filesep, DD(iFile).name], '%s','delimiter','\n');
    
    for l=1:length(lines)
        if i > numSentences 
            break; 
        end 
        processedLine = preprocess(lines{l}, 'f');
        %creating cell array entry of words of french sentence i 
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
    %using 
    AM = struct(); % AM.(english_word).(foreign_word)
    
    AM.('SENTSTART').('SENTSTART') = 1; 
    %AM.('SENTSTART').('COUNTTT') = 1; 
    AM.('SENTEND').('SENTEND') = 1; 
    %AM.('SENTEND').('COUNTTT') = 1; 
    
    %skipping sentstart and sentend 
    for i=1:(length(eng))
        eng_sent = eng(i); 
        fre_sent = fre(i);
        
        %eng_sent is 1x8 cell we want the second dimension
        for w=2:(length(eng_sent{1})-1)
            %we want to access the wth column of the first and only row 0f
            %eng_sent 
            eng_word = char(eng_sent{1}{w}); 
            if isfield(AM, eng_word) == false
                AM.(eng_word) = struct();
                %AM.(eng_word).('COUNTTT') = 0; 
            end 
            
            for j=2:(length(fre_sent{1})-1)
            %we want to access the wth column of the first and only row 0f
            %eng_sent 
                fre_word = char(fre_sent{1}{j}); 
                %keeping count of total words that could align with eng
                %word 
                %AM.(eng_word).('COUNTTT') = AM.(eng_word).('COUNTTT') + 1; 
                if isfield(AM.(eng_word), fre_word)
                    AM.(eng_word).(fre_word) = AM.(eng_word).(fre_word) + 1; 
                else 
                    AM.(eng_word).(fre_word) = 1; 
                end  
            end                            
        end 
    end
    
    en_fields = fieldnames(AM); 
    
    for i = 1:numel(en_fields)
            en = en_fields{i}; 
            fr_fields = fieldnames(AM.(en)); 
            %constant to divide all elements of en by total fn count 
            %norm = AM.(en).('COUNTTT');
            norm = length(fr_fields); 
            for j = 1:numel(fr_fields)
                fr = fr_fields{j}; 
                AM.(en).(fr) = 1/norm; 
            end 
    end 
end

function t = em_step(t, eng, fre)
% 
% One step in the EM algorithm.
%
  %initializing tcount(f, e) with all zeros 
tcount = struct(t); 
  t_fields = fieldnames(tcount); 
  for i = 1:numel(fieldnames(tcount))
      en = t_fields{i};  
      for j = 1:numel(fieldnames(tcount.(en)))
          fr = fieldnames(tcount.(en)); 
          tcount.(en).(fr{j}) = 0; 
      end 
  end 
  disp(length(eng))
  disp(length(fre))
  %initalizing total 1-D struct with all zeros 
  total = struct(t);
  t_fields = fieldnames(tcount); 
  for i = 1:numel(fieldnames(tcount))
      total.(t_fields{i}) = 0; 
  end
  %for each sentence pair in training

  for i=1:length(eng)
      eng_sent = eng(i);
      fre_sent = fre(i); 
      eng_dict = {}; 
      fre_dict = {}; 
      
      %building frequency count 
      for e=2:(length(eng_sent{1})-1)
          eng_word = char(eng_sent{1}{e}); 
          if isfield(eng_dict, eng_word)
              eng_dict.(eng_word) = eng_dict.(eng_word) + 1; 
          else 
              eng_dict.(eng_word) = 1; 
          end 
      end 
      
      for f=2:(length(fre_sent{1})-1)
          fre_word = char(fre_sent{1}{f}); 
          if isfield(fre_dict, fre_word)
              fre_dict.(fre_word) = fre_dict.(fre_word) + 1; 
          else 
              fre_dict.(fre_word) = 1; 
          end 
      end 
        
      if isempty(eng_dict)
          display('stopp'); 
      end 
      
      %for each sentence pair in training 
      f_fields = fieldnames(fre_dict);
      for f=1:numel(f_fields)
          denom_c = 0; 
          fre_word = f_fields{f}; 
          e_fields = fieldnames(eng_dict); 
          for e=1:numel(e_fields)
              eng_word = e_fields{e}; 
              %assume bigram already in AM model 
              P_ef = t.(eng_word).(fre_word); 
              denom_c = denom_c + P_ef*fre_dict.(fre_word);
          end 
          for e=1:numel(e_fields)
              eng_word = e_fields{e}; 
              %assume bigram already in AM model 
              P_ef = t.(eng_word).(fre_word); 
              tcount.(eng_word).(fre_word) = tcount.(eng_word).(fre_word) + P_ef*fre_dict.(fre_word)*eng_dict.(eng_word)/denom_c; 
              total.(eng_word) = total.(eng_word) + P_ef*fre_dict.(fre_word)*eng_dict.(eng_word)/denom_c;
          end 
      end      
  end 
  
  %maximization(f, e) with all zeros 
  for i = 1:numel(fieldnames(tcount))
      en = t_fields{i};  
      for j = 1:numel(fieldnames(tcount.(en)))
          fr = fieldnames(tcount.(en)); 
          t.(en).(fr{j}) = tcount.(en).(fr{j})/total.(en); 
      end 
  end  
      
end


