from scipy import stats
import re
import sys

def read_results(input_text):
    op = open(input_text, 'r')
    lines = op.readlines()
    acc = []
    a = []
    b = []
    for line in lines:
        line = line.rstrip("\n")
        a_val = re.findall(r"([0-9]+ +[0-9]+ \| +a = pos)", line)
        if len(a_val) > 0:
            a_list = re.findall(r"[0-9]+", a_val[0])
            a_list = [int(n) for n in a_list]
            a.append(a_list)
        b_val = re.findall(r"([0-9]+ +[0-9]+ \| +b = neg)", line)
        if len(b_val) > 0:
            b_list = re.findall(r"[0-9]+", b_val[0])
            b_list = [int(n) for n in b_list]
            b.append(b_list)

    for n in range(len(a)/2):
	i = n*2-1 
	print 'fold: ', i 
        percision = float(a[i][0])/(a[i][0] + a[i][1])
        print "percision: ", percision
        recall = float(a[i][0])/ (a[i][0] + b[i][0])
        print "recall: ", recall
        correct =  a[i][0] + b[i][1]
        total = a[i][0] + a[i][1]+b[i][0]+b[i][1]
        accuracy = float(correct)/total
	print accuracy
        acc.append(accuracy)

    return acc

if __name__ == "__main__":
    a = read_results(sys.argv[1])
    print 'length of first', len(a)
    b = read_results(sys.argv[2])
    print 'length of second', len(b)
    S = stats.ttest_rel(a,b)
    print S
