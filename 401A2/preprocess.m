          function outSentence = preprocess( inSentence, language )
%
%  preprocess
%
%  This function preprocesses the input text according to language-specific rules.
%  Specifically, we separate contractions according to the source language, convert
%  all tokens to lower-case, and separate end-of-sentence punctuation 
%
%  INPUTS:
%       inSentence     : (string) the original sentence to be processed 
%                                 (e.g., a line from the Hansard)
%       language       : (string) either 'e' (English) or 'f' (French) 
%                                 according to the language of inSentence
%
%  OUTPUT:
%       outSentence    : (string) the modified sentence
%
%  Template (c) 2011 Frank Rudzicz 

  global CSC401_A2_DEFNS
  
  % first, convert the input sentence to lower-case and add sentence marks 
  inSentence = [CSC401_A2_DEFNS.SENTSTART ' ' lower( inSentence ) ' ' CSC401_A2_DEFNS.SENTEND];

  % trim whitespaces down 
  inSentence = regexprep( inSentence, '\s+', ' '); 

  % initialize outSentence
  outSentence = inSentence; 

  % perform language-agnostic changes
  % TODO: your code here
  %    e.g., outSentence = regexprep( outSentence, 'TODO', 'TODO');
  
  %Separate sentence punctualtions (final punc, commas, semicolons,
  %parenthesises, mathematical operations and
  %quotations marks)
  outSentence = regexprep(inSentence, '[.,!"+-<>=?()]+', ' $&'); 
  
  %separate dashes between parentheses 
  %THIS WAS EXTREMELY UNCLEAR IN HANDOUT
  outSentence = regexprep(outSentence, '\<(-)\>', ' $1'); 
  
  switch language
   case 'e'
       % english case: separate possessives and clitics 
        for ending = {'n''t', '''ve', '''ll', '''re', '''s', '''d', '''m', '''all'}
                   outSentence = regexprep(outSentence, ending, ' $0'); 
        end 
    
   case 'f'
    % french case: 
    % separate definite article l'
    % separate single consonant words j' t' 
    % que separate qu' 
    % conjunctions puisqu'on -> puisqu' on 
    
        for ending = {'l''', 'j''', 't''', ' qu''', 'puisqu''', 'lorsqu'''}
               outSentence = regexprep(outSentence, ending, '$0 '); 
        end 
  end
  
    % trim whitespaces down again  
  outSentence = regexprep( outSentence, '\s+', ' ');  

  % change unpleasant characters to codes that can be keys in dictionaries
  outSentence = convertSymbols( outSentence );

