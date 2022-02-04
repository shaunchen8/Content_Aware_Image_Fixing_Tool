function [ NNF ] = random_search(source,target,patch_size_r,patch_size_c,NNF,row_tgt,col_tgt)

[row_src, col_src, ~] = size(source);
patch_length_r = floor(patch_size_r/2);
patch_length_c = floor(patch_size_c/2);

%Sets parameters and data for random search operation:
k = 0;
q1 = [NNF(row_tgt,col_tgt,1) NNF(row_tgt,col_tgt,2)];
alpha = 0.5;

patch_T = target(row_tgt:row_tgt-1+patch_size_r,col_tgt:col_tgt-1+patch_size_c,:);
while alpha^k*row_src > patch_size_r && alpha^k*col_src > patch_size_c 
    
    %Performs operation by resizing window:
    window = floor([alpha^k*row_src alpha^k*col_src]);
    if k > 0
        edge_top = 1;
        edge_left = 1;
        not_center(1) = q1(1)-(floor(window(1)/2)+edge_top-1); 
        while not_center(1) > 0 && edge_top < row_src-window(1)
            edge_top = edge_top + 1;
            not_center(1) = q1(1)-(floor(window(1)/2)+edge_top-1);               
        end        
        not_center(2) = q1(2)-(floor(window(2)/2)+edge_left-1);  
        while not_center(2) > 0 && edge_left < col_src-window(2)
            edge_left = edge_left + 1;
            not_center(2) = q1(2)-(floor(window(2)/2)+edge_left-1); 
        end       
    else
        edge_left = 0;
        edge_top = 0; 
    end
    
    window_rand = [1+patch_length_r+edge_top window(1)-patch_length_r+edge_top; 1+patch_length_c+edge_left window(2)-patch_length_c+edge_left];
    row_rand = randi([window_rand(1,1) window_rand(1,2)]);
    col_rand = randi([window_rand(2,1) window_rand(2,2)]);
    patch_rand = source(row_rand-patch_length_r:row_rand+patch_length_r,col_rand-patch_length_c:col_rand+patch_length_c,1:3);
    L2norm = sum((patch_T-patch_rand).^2,'all');
    if L2norm < NNF(row_tgt,col_tgt,3) 
        NNF(row_tgt,col_tgt,1) = NNF(row_tgt,col_tgt+1,1);
        NNF(row_tgt,col_tgt,2) = NNF(row_tgt,col_tgt+1,2)-1;
        NNF(row_tgt,col_tgt,3) = L2norm;
    end
    k = k + 1;
end