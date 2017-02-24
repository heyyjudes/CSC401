outSentence = cat_test

for ending = {'n''t', '''ve', '''ll', '''re', '''s', '''d', '''m', '''all'}
           outSentence = regexprep(outSentence, ending, ' $0')
end 
