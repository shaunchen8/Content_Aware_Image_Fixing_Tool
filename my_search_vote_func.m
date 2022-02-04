function [res, ann, bnn] = my_search_vote_func(source, target, niters,m,n)

% img: Source image 
% res: Target image (input is initial estimate of target image and output is the target image after seach and vote operation.)
% niters: Number of iterations of search and vote to be performed
% ann: Nearest-Neighbour field (hxwx3, int32) mapping res -> img
% bnn: Nearest-Neighbour field (hxwx3, int32) mapping img -> res

% Please replace the nnmex and votemex after you have implemented your own
% searching and voting function for PatchMatch


%% Perform niters iterations of search and vote
for iter = 1:niters
    %% Searching for NNF
    if(iter==1)
        ann = patchMatchNNF(target, source, m,n,[]); 
        bnn = patchMatchNNF(source, target, m,n,[]);     
    else
        ann = patchMatchNNF(res, source, m,n,ann); 
        bnn = patchMatchNNF(source, res, m,n,bnn); 
    end

	%% Voting     
    res = double(voteNNF(source,target, ann, bnn,m,n));   
%   outPath = sprintf('%s/%s_%04d-%04d-Iter-%04d.png', j, k, iter);
%   imwrite(lab2rgb(double(res)), outPath);    
% 	fprintf(1,'%d ',iter);

end

