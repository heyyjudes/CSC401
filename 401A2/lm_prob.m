function logProb = lm_prob(sentence, LM, type, delta, vocabSize)
%
%  lm_prob
% 
%  This function computes the LOG probability of a sentence, given a 
%  language model and whether or not to apply add-delta smoothing
%
%  INPUTS:
%
%       sentence  : (string) The sentence whose probability we wish
%                            to compute
%       LM        : (variable) the LM structure (not the filename)
%       type      : (string) either '' (default) or 'smooth' for add-delta smoothing
%       delta     : (float) smoothing parameter where 0<delta<=1 
%       vocabSize : (integer) the number of words in the vocabulary
%
% Template (c) 2011 Frank Rudzicz

  logProb = -Inf;

  % some rudimentary parameter checking
  if (nargin < 2)
    disp( 'lm_prob takes at least 2 parameters');
    return;
  elseif nargin == 2
    type = '';
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  end
  if (isempty(type))
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  elseif strcmp(type, 'smooth')
    if (nargin < 5)  
      disp( 'lm_prob: if you specify smoothing, you need all 5 parameters');
      return;
    end
    if (delta <= 0) or (delta > 1.0)
      disp( 'lm_prob: you must specify 0 < delta <= 1.0');
      return;
    end
  else
    disp( 'type must be either '''' or ''smooth''' );
    return;
  end

  words = strsplit(' ', sentence); 
  logProb = 0; 
  % TODO: the student implements the following
  total_bi = vocabSize; 
  for w=1:(length(words)-1)
      curr = char(words(w)); 
      next = char(words(w+1)); 
      if isfield(LM.bi, curr) 
          if isfield(LM.bi.(curr), next)  
            currProb = (LM.bi.(curr).(next) + delta)/(LM.uni.(curr) + delta*total_bi);  
          else 
            currProb = delta;
          end 
      else 
          currProb = delta;  
      end 
      %adding log probabilities same as taking log after multiplying
      %probabilities
      logProb = logProb + log2(currProb); 
  end 
      
return 