train = '/u/cs401/speechdata/Training';
e = 0.01; 
max_itr = 10; 
M = 8; 


model = gmmTrain(train, max_itr, e, M); 