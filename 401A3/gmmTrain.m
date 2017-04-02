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

for s = 1: numel(speakers) 
    %initializing name and weights
    gmms(s).name = speakers(s).name; 
    gmms(s).weights = ones(1, M)*1/M; 
    gmms(s).cov = ones(D, D, M);  
    for m = 1:M            
        gmms(s).cov(:, :, m) = diag(diag(gmms(s).cov(:, :, m))); 
    end 
    
    x_train = []; 
    utterances = dir([dir_train '/' speakers(s).name]); 
    %reading utterances from file 
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
            fclose(fid); 
        end
    end
    
    %setting means as M Training examples
    while 1
        idx = randi([1,length(x_train)],M,1); % take M randnom samples from entire set
        if length(unique(idx)) == M % make sure samples are unique, otherwise draw again
            break;
        end
    end
    gmms(s).means = x_train(idx, :)';
    
    iter = 0; 
    prev_L = -Inf; 
    improvement = Inf; 
    N = length(x_train);
    while iter <= max_iter && abs(improvement) >= epsilon  
        display(['Current iteration: ' num2str(iter)]);
        
        % for computational efficiency
        inv_cov = zeros(D,D,M);
        for m = 1:M
            inv_cov(:,:,m) = inv(gmms(s).cov(:,:,m));
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % E-step: Compute probability for each point %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        prob = zeros(M,N);
        for i = 1:N
            x_i = x_train(i,:)';

            % compute probability for sample x_i to belong to component m
            for m = 1:M
                mean_m = gmms(s).means(:, m);
                cov_m = gmms(s).cov(:,:,m);
                inv_cov_m = inv_cov(:,:,m);

                prob(m,i) = gmms(s).weights(m)/((2*pi)^D * sqrt(det(cov_m))) * exp(-1/2*(x_i - mean_m)'*inv_cov_m*(x_i - mean_m));
            end

            % normalize probability
            prob(:,i) = prob(:,i)/sum(prob(:,i));
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % M-step: Maximize log likelihood %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        weights_new = mean(prob,2)';
        
        means_new = zeros(D,M);
        covs_new = zeros(D,D,M);
        for m = 1:M % update mean and covariance for each component
            mean_new = zeros(1,D);
            cov_new = zeros(D,D);
            
            mean_m = gmms(s).means(:, m)';
            
            for i = 1:N
                x_i = x_train(i, :);
                
                mean_new = mean_new + prob(m,i)*x_i;
                cov_new = cov_new + prob(m,i)*diag(diag((x_i - mean_m)'*(x_i - mean_m)));
            end
            
            % normalize mean and covariance
            means_new(:,m) = mean_new/sum(prob(m,:));
            covs_new(:,:,m) = cov_new/sum(prob(m,:));% + 1/lambda*eye(D); % optional, to avoid degeneracy
        end
        
        % store new stimates
        gmms(s).weights = weights_new;
        gmms(s).means = means_new;
        gmms(s).cov = covs_new;

        % improvement and update prev L
        L = 0;
        % compute log likelihood of dataset
        for i = 1:N
            x_i = x_train(i,:)';
            
            likelihood = zeros(M,1);
            for m = 1:M
                mean_m = gmms(s).means(:, m);
                cov_m = gmms(s).cov(:,:,m);
                inv_cov_m = inv_cov(:,:,m);

                likelihood(m) = gmms(s).weights(m)/((2*pi)^D * sqrt(det(cov_m))) * exp(-1/2*(x_i - mean_m)'*inv_cov_m*(x_i - mean_m));
            end
            
            L = L + log(sum(likelihood));
        end
        improvement = L - prev_L;
        prev_L = L;
        display(['Loglikelihood: ' num2str(L)])
        display(['Improvement: ' num2str(improvement)])
        
        % increase number of iterations
        iter = iter + 1;
        
        %%%%% FIX ME %%%%%%
        %improvement = 1; % sometimes (especially after a big step) we have an overshoot, but we don't want to quit our optimization yet.
    end 
    
end 


       
save('gmms', 'gmms'); 