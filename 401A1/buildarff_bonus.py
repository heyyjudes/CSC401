import sys
import re
import argparse
import nltk
#wordlist_url = 'Wordlists/'
wordlist_url = '/u/cs401/Wordlists/'
import csv

#global porter stemmer
porter = nltk.PorterStemmer()
def feat1(input_str):
    keywords = open(wordlist_url + 'First-person').read().splitlines()
    keywords = [z.lower() for z in keywords]
    count = 0
    sentences = input_str.split("\n")
    for sent in sentences:
        tokens = sent.split(" ")
        for token in tokens:
            token_arr = token.split("/")
            test_token = token_arr[0].lower()
            if test_token in keywords:
                count += 1
    return count

def feat2(input_str):
    keywords = open(wordlist_url + 'Second-person').read().splitlines()
    keywords = [z.lower() for z in keywords]
    count = 0
    sentences = input_str.split("\n")
    for sent in sentences:
        tokens = sent.split(" ")
        for token in tokens:
            token_arr = token.split("/")
            test_token = token_arr[0].lower()
            if test_token in keywords:
                count += 1
    return count

def feat3(input_str):
    keywords = open(wordlist_url + 'Third-person').read().splitlines()
    keywords = [z.lower() for z in keywords]
    count = 0
    sentences = input_str.split("\n")
    for sent in sentences:
        tokens = sent.split(" ")
        for token in tokens:
            token_arr = token.split("/")
            test_token = token_arr[0].lower()
            if test_token in keywords:
                count += 1
    return count

def feat4(input_str):
    ''' counting coordinating conjunctions CC tags'''
    tag = "CC"
    count = 0
    sentences = input_str.split("\n")
    for sent in sentences:
        tokens = sent.split(" ")
        for token in tokens:
            token_arr = token.split("/")
            if len(token_arr) > 1:
                if token_arr[1] == tag:
                    count += 1
    return count

def feat5(input_str):
    ''' counting past tense verbs VBD'''
    tag = "VBD"
    count = 0
    sentences = input_str.split("\n")
    for sent in sentences:
        tokens = sent.split(" ")
        for token in tokens:
            token_arr = token.split("/")
            if len(token_arr) > 1:
                if token_arr[1] == tag:
                    count += 1
    return count

def feat6(input_str):
    ''' counting future tense key words and compositions'''
    tag = "VB"
    keywords = ["'ll", "will", "gonna"]
    count = 0
    sentences = input_str.split("\n")
    for sent in sentences:
        tokens = sent.split(" ")
        for i in range(0, len(tokens)):
            token_arr = tokens[i].split("/")
            if len(token_arr) > 1:
                test_token = token_arr[0].lower()
                if test_token in keywords:
                    count += 1
                elif i < len(tokens) - 2:
                    #checking for going + to + VB case
                    if test_token == "going" and tokens[i+1].split("/")[0] == "to" and tokens[i+2].split("/")[1] == tag:
                        count +=1
    return count

def feat7(input_str):
    ''' counting commas using tags'''
    tag = ","
    count = 0
    sentences = input_str.split("\n")
    for sent in sentences:
        tokens = sent.split(" ")
        for token in tokens:
            token_arr = token.split("/")
            if len(token_arr) > 1:
                if token_arr[1] == tag:
                    count += 1
    return count

def feat8(input_str):
    ''' counting counting colons and semi colons'''
    tags = [";", ":"]
    count = 0
    sentences = input_str.split("\n")
    for sent in sentences:
        tokens = sent.split(" ")
        for token in tokens:
            token_arr = token.split("/")
            if len(token_arr) > 1:
                #check actually sentence to avoid tagging errors
                if token_arr[0] in tags:
                    count += 1
    return count

def feat9(input_str):
    ''' counting dashes'''
    tag = "-"
    count = 0
    sentences = input_str.split("\n")
    for sent in sentences:
        tokens = sent.split(" ")
        for token in tokens:
            token_arr = token.split("/")
            if len(token_arr) > 1:
                #dashes are not tagged by penn part of speech punctuation
                if token_arr[0] == tag:
                    count += 1
    return count

def feat10(input_str):
    ''' counting dashes using tags'''
    tags = ["(", ")"]
    count = 0
    sentences = input_str.split("\n")
    for sent in sentences:
        tokens = sent.split(" ")
        for token in tokens:
            token_arr = token.split("/")
            if len(token_arr) > 1:
                if token_arr[1] in tags:
                    count += 1
    return count

def feat11(input_str):
    ''' counting ellipses'''
    tag = "..."
    count = 0
    sentences = input_str.split("\n")
    for sent in sentences:
        tokens = sent.split(" ")
        for token in tokens:
            token_arr = token.split("/")
            if len(token_arr) > 1:
                #dashes are not tagged by penn part of speech punctuation
                if token_arr[0] == tag:
                    count += 1
    return count

def feat12(input_str):
    ''' counting common nouns using tags'''
    tags = ["NN", "NNS"]
    count = 0
    sentences = input_str.split("\n")
    for sent in sentences:
        tokens = sent.split(" ")
        for token in tokens:
            token_arr = token.split("/")
            if len(token_arr) > 1:
                if token_arr[1] in tags:
                    count += 1
    return count

def feat13(input_str):
    ''' counting proper nouns using tags'''
    tags = ["NNP", "NNPS"]
    count = 0
    sentences = input_str.split("\n")
    for sent in sentences:
        tokens = sent.split(" ")
        for token in tokens:
            token_arr = token.split("/")
            if len(token_arr) > 1:
                if token_arr[1] in tags:
                    count += 1
    return count

def feat14(input_str):
    ''' counting adverbs using tags'''
    tags = ["RB", "RBR", "RBS"]
    count = 0
    sentences = input_str.split("\n")
    for sent in sentences:
        tokens = sent.split(" ")
        for token in tokens:
            token_arr = token.split("/")
            if len(token_arr) > 1:
                if token_arr[1] in tags:
                    count += 1
    return count

def feat15(input_str):
    ''' counting wh-words using tags'''
    tags = ["WDT", "WP", "WRB", "WP$"]
    count = 0
    sentences = input_str.split("\n")
    for sent in sentences:
        tokens = sent.split(" ")
        for token in tokens:
            token_arr = token.split("/")
            if len(token_arr) > 1:
                if token_arr[1] in tags:
                    count += 1
    return count

def feat16(input_str):
    '''counting slangs with slang wordlist '''
    keywords = open(wordlist_url + 'Slang').read().splitlines()
    keywords = [z.lower() for z in keywords]
    count = 0
    sentences = input_str.split("\n")
    for sent in sentences:
        tokens = sent.split(" ")
        for token in tokens:
            token_arr = token.split("/")
            test_token = token_arr[0].lower()
            if test_token in keywords:
                count += 1
    return count

def feat17(input_str):
    '''countind number of words ALL in uppercase'''
    count = 0
    sentences = input_str.split("\n")
    for sent in sentences:
        tokens = sent.split(" ")
        for token in tokens:
            token_arr = token.split("/")
            if token_arr[0].isupper() and len(token_arr[0]) >= 2:
                count+=1
    return count

def feat18(input_str):
    '''finding average length of sentence'''
    length = 0
    sentences = input_str.split("\n")
    for sent in sentences:
        tokens = sent.split(" ")
        length += len(tokens)
    length /= len(sentences)*1.0
    return length

def feat19(input_str):
    '''finding average length of sentences without punctuation'''
    length = 0
    sentences = input_str.split("\n")
    for sent in sentences:
        #looking for words only before the /tag
        tokens = re.findall(r"[\w]+/", sent)
        length += len(tokens)
    length /= len(sentences)*1.0
    return length

def feat20(input_str):
    '''counting number of sentences'''
    length = 0
    sentences = input_str.split("\n")
    for sent in sentences:
        length += 1
    return length

def build_dic_anew():
    '''building dictionary for ANEW WORDS'''
    input_file = csv.DictReader(open('Ratings_Warriner_et_al.csv', 'r'))
    condensed_dict = {}
    for row in input_file:
        keyword = porter.stem(row["Word"]).lower()
        condensed_dict[keyword] = (float(row["V.Mean.Sum"]), float(row["A.Mean.Sum"]), float(row["D.Mean.Sum"]))
    return condensed_dict

def feat_anew(input_str, dict):
    '''calcualte average valance, dominance and affect of tweets'''
    anew_count = total_count = avg_val = avg_aff = avg_dom = 0
    sentences = input_str.split("\n")
    for sent in sentences:
        tokens = sent.split(" ")
        for token in tokens:
            token_arr = token.split("/")
            test_token = porter.stem(token_arr[0]).lower()
            if test_token in dict:
                val, aff, dom = dict[test_token]
                anew_count+=1
                avg_val += val
                avg_aff += aff
                avg_dom += dom
            total_count += 1
    if anew_count > 0:
        avg_val = avg_val/anew_count
        avg_aff = avg_aff/anew_count
        avg_dom = avg_dom/anew_count
    else:
        avg_val = 0
        avg_aff = 0
        avg_dom = 0
    return avg_val, avg_aff, avg_dom


def create_arff(input_arr_pos, input_arr_neg, labels, output_file, relation, num=10000):
    input_arr = input_arr_pos[:num] + input_arr_neg[:num]
    with open(output_file, 'w') as f:
        f.write('@relation ' + relation + '\n')
        for att in labels:
            f.write('@attribute ' + att + " numeric\n")
        f.write('@attribute class {pos, neg}' + '\n\n')
        f.write('@data' + '\n')
        print len(input_arr)
        for row in input_arr:
            row = [str(z) for z in row]
            row_str = ",".join(row)
            f.write(row_str + '\n')

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('input_file')
    parser.add_argument('output_file')
    parser.add_argument('twt_limit', nargs='?')
    #for cross validation files
    parser.add_argument('folds', nargs='?')
    args = parser.parse_args()
    input_path = args.input_file
    output_file = args.output_file
    twt_limit = 10000
    if args.twt_limit:
        twt_limit = int(args.twt_limit)
        if twt_limit >= 20000:
            twt_limit = 10000

    with open(input_path, 'rb') as f:
        feat_strs = ["1st_person", "2nd_person", "3nd_person", "coord_conj", "past_verb", " future_verb", " comma", \
                     "colon", "dash", "parenthesis", "ellipses", "common_noun", " proper_nouns", "adverbs", "wh_words",\
                    "slang", "upper", "all_length", "no_punc_length", "num_of_sent", "val", "aff", "dom"]
        tweets = f.readlines()
        input_str = "".join(tweets)
        tweets = re.split(r'<A=[0-4]>', input_str)
        labels = re.findall(r'<A=[0-4]>', input_str)
        tweets = tweets[len(tweets)-len(labels):] #removing first space after split
        feature_vecs_pos = []
        feature_vecs_neg = []
        anew_dict = build_dic_anew()
        for i in range(0, len(tweets)):
            curr_tweet = tweets[i].lstrip("\r\n")
            feat_arr = []
            feat_arr.append(feat1(curr_tweet))
            feat_arr.append(feat2(curr_tweet))
            feat_arr.append(feat3(curr_tweet))
            feat_arr.append(feat4(curr_tweet))
            feat_arr.append(feat5(curr_tweet))
            feat_arr.append(feat6(curr_tweet))
            feat_arr.append(feat7(curr_tweet))
            feat_arr.append(feat8(curr_tweet))
            feat_arr.append(feat9(curr_tweet))
            feat_arr.append(feat10(curr_tweet))
            feat_arr.append(feat11(curr_tweet))
            feat_arr.append(feat12(curr_tweet))
            feat_arr.append(feat13(curr_tweet))
            feat_arr.append(feat14(curr_tweet))
            feat_arr.append(feat15(curr_tweet))
            feat_arr.append(feat16(curr_tweet))
            feat_arr.append(feat17(curr_tweet))
            feat_arr.append(feat18(curr_tweet))
            feat_arr.append(feat19(curr_tweet))
            feat_arr.append(feat20(curr_tweet))
            val, aff, dom = feat_anew(curr_tweet, anew_dict)
            feat_arr.append(val)
            feat_arr.append(aff)
            feat_arr.append(dom)

            if labels[i][3] == '0':
                feat_arr.append("neg")
                feature_vecs_neg.append(feat_arr)
                #breaking when we have reached limit
                if len(feature_vecs_neg) >= twt_limit and len(feature_vecs_pos) >= twt_limit:
                    break
            elif labels[i][3] == '4':
                feat_arr.append("pos")
                feature_vecs_pos.append(feat_arr)
                #breaking when we have reached limit
                if len(feature_vecs_neg) >= twt_limit and len(feature_vecs_pos) >= twt_limit:
                    break
        if args.folds:
            num_splits = int(args.folds)
            size = twt_limit / num_splits
            output_str = 'cv' + str(i)+'_'+output_file
            while num_splits > 0:
                beg = (num_splits-1)*size
                end = (num_splits-1)*size+size
                output_str = 'cv' + str(num_splits) + '_' + output_file
                print 'creating split beg: ', beg, ' end: ', end, ' to arff file', output_str
                cross_pos = feature_vecs_pos[:beg] + feature_vecs_pos[end:]
                cross_neg = feature_vecs_neg[:beg] + feature_vecs_neg[end:]
                create_arff(cross_pos, cross_neg, feat_strs, output_str, 'sentiment_cv', size*9)
                num_splits -= 1

        else:
            create_arff(feature_vecs_pos, feature_vecs_neg, feat_strs, output_file, 'sentiment', twt_limit)

    print 'done'
