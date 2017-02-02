import sys
import csv
import re
import HTMLParser
import NLPlib
import itertools


tagger = NLPlib.NLPlib()
error_list = []
def twtt1(input_str):
    ''' this function uses regular expression to remove html tags and attributes'''
    clean_txt = re.compile(r'<[^>]+>')
    new_str = clean_txt.sub('', input_str)
    return new_str

def twtt2(input_str):
    '''this function uses HTMLParser to change html character codes to ascii'''
    h = HTMLParser.HTMLParser()
    try:
        new_str = h.unescape(input_str)
    except UnicodeDecodeError:
        print 'cannot decode this file', input_str
        error_list.append(input_str)
    return input_str

def twtt3(input_str):
    '''this function removes URLS by splitting string and looking for URL beginnings'''
    arr = input_str.split(" ")
    for token in arr:
        if token.startswith("www") or token.startswith("http"):
            arr.remove(token)
    new_str = " ".join(arr)
    return new_str

def twtt4(input_str):
    '''remove usernames and hashtags at the first character of user names'''
    clean_txt = re.compile(r'#')
    new_str = clean_txt.sub('', input_str)
    clean_txt = re.compile(r'@')
    new_str = clean_txt.sub('', new_str)
    return new_str

def twtt5(input_str):
    '''split into sentences separated by newline characters'''
    #check for period,
    clean_txt = re.compile(r'(?<!\w\.\w.)(?<![A-Z][a-z]\.)(?<=\.|\?|\!)\s')
    new_str = clean_txt.sub('\n', input_str)
    #remove duplicate new lines
    clean_txt = re.compile(r'\n\b\n')
    new_str = clean_txt.sub('\n', new_str)
    return new_str

def twtt7(input_str):
    '''separate clitics and punctuation by spaces'''
    output_arr = []
    sentences = input_str.split("\n")
    for sent in sentences:
        #finds all words and punctuation
        tokens = re.findall(r"[\w']+|[-.,!?;*%&<:()\"\\]+", sent)
        new_sent = []
        #contraction endings to look for
        last_three = ["t", "ve", "ll", "re"]
        last_two = ["s", "d", "m"]
        last_four = ["all"]
        for word in tokens:
            contract_split = word.split("'")
            if len(contract_split) > 1 :
                #adding .lower() also check for all caps endings
                if contract_split[-1].lower() in last_two:
                    new_sent.append(word[:-2])
                    new_sent.append(word[-2:])
                elif contract_split[-1].lower() in last_three:
                    new_sent.append(word[:-3])
                    new_sent.append(word[-3:])
                elif contract_split[-1].lower() in last_four:
                    new_sent.append(word[:-4])
                    new_sent.append(word[-4:])
                #to check fro possessive on plurals
                elif contract_split[-2].lower().endswith('s') and contract_split[-1] == "":
                    new_sent.append(word[:-1])
                    new_sent.append(word[-1:])
                else:
                    word_tokens = re.findall(r"[\w']+|['\"]+", word)
                    new_sent = new_sent + word_tokens
            else:
                new_sent.append(word)
        sent_str = " ".join(new_sent)
        output_arr.append(sent_str)
    new_str = "\n".join(output_arr)
    return new_str

def twtt8(input_str):
    '''tag each word with part of speech'''

    sent_arr = input_str.split("\n")
    new_str_arr = []
    for sent in sent_arr:
        if len(sent) > 2:
            output_tokens = []
            tokens = sent.split(" ")
            tags = tagger.tag(tokens)
            for i in range(0, len(tokens)):
                new_token = tokens[i] + '/' + tags[i]
                output_tokens.append(new_token)
            new_sent = " ".join(output_tokens)
            new_str_arr.append(new_sent)
    new_str = "\n".join(new_str_arr)
    return new_str


def twtt9(input_str, polar):
    header_str = '<A=' + polar + '>\n'
    new_str = header_str+input_str
    return new_str





if __name__ == "__main__":
    #input_path = sys.argv[1]
    #student_id = sys.argv[2]
    #output_file = sys.argv[3]
    student_id = 999735764
    index_start = (int(student_id)%80)*10000
    input_path = '/u/cs401/A1/tweets/training.1600000.processed.noemoticon.csv'
    output_file = 'train.twt'
    #not implemented student number part
    my_tweets = []	
    with open(input_path, 'rb') as f:
        reader = csv.reader(f)
        for row in itertools.islice(reader, index_start, index_start + 10000):
            my_tweets.append(row)
        for row in itertools.islice(reader, index_start, index_start + 10000):
          my_tweets.append(row)
    out_f = open(output_file, 'w')  
    #with open(output_file, 'w') as outf:
    i=0
    for row in my_tweets:
        final_str = twtt1(row[5])
        final_str = twtt2(final_str)
        final_str = twtt3(final_str)
        final_str = twtt4(final_str)
        final_str = twtt5(final_str)
        final_str = twtt7(final_str)
        final_str = twtt8(final_str)
        final_str = twtt9(final_str, row[0])
        out_f.write(final_str)
        print i
        i+=1
    print error_list
    print 'done'




