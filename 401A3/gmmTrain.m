function gmms = gmmTrain( dir_train, max_iter, epsilon, M )
% gmmTain
%
%  inputs:  dir_train  : a string pointing to the high-level
%                        directory containing each speaker directory
%           max_iter   : maximum number of training iterations (integer)
%           epsilon    : minimum improvement for iteration (float)
%           M          : number of Gaussians/mixture (integer)
%
%  output:  gmms       : a 1xN cell array. The i^th element is a structure
%                        with this structure:
%                            gmm.name    : string - the name of the speaker
%                            gmm.weights : 1xM vector of GMM weights
%                            gmm.means   : DxM matrix of means (each column 
%                                          is a vector
%                            gmm.cov     : DxDxM matrix of covariances. 
%                                          (:,:,i) is for i^th mixture

gmms = {};  
D = 14; 

speakers = dir(dir_train);
speakers = speakers(~ismember({speakers.name},{'.','..'}));

for s = 1: numel(2) 
    gmms(s).name = speakers(s).name; 
    gmms(s).weights = ones(1, M)*1/M; 

    gmms(s).cov = ones(D, D, M);  
    for m = 1:M            
        gmms(s).cov(:, :, m) = diag(diag(gmms(s).cov(:, :, m))); 
    end 
    
    x_train = []; 
    utterances = dir([dir_train '/' speakers(s).name]); 
    for j = 1: numel(utterances)
        [patstr, name, ext] = fileparts(utterances(j).name); 
        if strcmp(ext, '.mfcc') 
            fid = fopen([dir_train  '/' speakers(s).name '/' utterances(j).name]);  
            %read mfcc 
            mfcc = fscanf(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f', [14 Inf]); 
            mfcc = mfcc'; 
            if isempty(x_train) 
                % first mfcc
                x_train = mfcc; 
            else
                % add to existing mfcc 
                x_train = cat(1, x_train, mfcc); 
            end 
        end
    end
    
    gmms(s).means = x_train(20:20+M-1, :)'; 
    
    i = 0; 
    prev_L = -Inf; 
    improvement = Inf; 
    while i <= max_iter && improvement >= epsilon
        %logb over all training examples
        temp_weights = zeros(1, M); 
        temp_mu = zeros(D, M); 
        temp_sigma = zeros(D, M); 
        L = 0; 
        for t = 1:10
        %for t = 1:length(x_train)
        % compute likelihood
         % calculate probability
            % find all log_b for each m 
            x_t = x_train(t, :)'; 
            log_b = zeros(M, 1); 
            
            for m=1:M
  
                sigma_sq = diag(gmms(s).cov(:, :, m).^2); 
                mean_m = gmms(s).means(:, m); 
                % sum of mean sq/variance sq         
                norm_term = sum((mean_m.^2)./(2*(sigma_sq))) + D/2*log(2*pi)+ 1/2*log(prod(sigma_sq, 1)); 
                % adding log_2 constant 
                % norm_term = norm_term + D/2*log(2*pi); 
                % add log of product of variance
                % norm_term = norm_term + 1/2*log(prod(sigma_sq, 1));
                
  %             exmaple_term = 0; 
                example_term = sum(0.5*(x_t.^2)./sigma_sq - (x_t).*mean_m./sigma_sq);
                %example_term = sum(example_term,1); 
                log_b(m, 1) = - example_term - norm_term; 
                
            end 
            
            %calculate each p_m 
            log_wb = log(gmms(s).weights') + log_b;
            
            P = zeros(M, 1); 
            for m=1:M 
                P(m) = exp(log_wb(m))./sum(exp(log_wb)); 
            end    
            L = L + sum(log(P))    
            temp_weights = temp_weights + P'; 
            for m = 1:M
            temp_mu(:, m) = temp_mu(:, m) + P(m).*x_t; 
            temp_sigma(:, m) = temp_sigma(:, m) + P(m).*x_t.^2;
            end
            
        end 
        
        gmms(s).weights = (temp_weights/length(x_train));  
        for m =1:M
        gmms(s).means(:, m) = (temp_mu(:, m)./temp_weights(m));  
        temp_sigma(:, m) = (temp_sigma(:, m)./temp_weights(m) - gmms(s).means(:, m).^2)';            
        gmms(s).cov(:, :, m) = sqrt(diag(temp_sigma(:, m))); 
        end 
         
        
        L = L/length(x_train) 
        

        % improvement and update prev L 
        improvement = L - prev_L
        

        prev_L = L; 

        i = i + 1; 
    end 
    
end 


       