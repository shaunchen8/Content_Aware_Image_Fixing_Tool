function [ NNF ] = patchMatchNNF(source,target,patch_size_r,patch_size_c,NNFi)
    [row_src, col_src, ~] = size(source);
    [row_tgt, col_tgt, ~] = size(target);
    patch_length_r = floor(patch_size_r/2);
    patch_length_c = floor(patch_size_c/2);
    NNF = zeros(row_tgt-2*patch_length_r, col_tgt-2*patch_length_c,3);
    
    if size(NNFi) == 0
        for i = 1:row_tgt-2*patch_length_r
            for j = 1:col_tgt-2*patch_length_c
                NNF(i,j,1) = randi([patch_length_r+1 row_src-patch_length_r]);
                NNF(i,j,2) = randi([patch_length_c+1 col_src-patch_length_c]);
                patch_T = target(i:i-1+patch_size_r,j:j-1+patch_size_c,:); 
                patch_S = source(NNF(i,j,1)-patch_length_r:NNF(i,j,1)+patch_length_r,NNF(i,j,2)-patch_length_c:NNF(i,j,2)+patch_length_c,:);
                L2norm = sum((patch_T-patch_S).^2,'all'); %L2 norm
                NNF(i,j,3) = L2norm;
            end
        end   
    else
         NNF = NNFi;
    end
    
    for i = 1:row_tgt-2*patch_length_r
        for j = 1:col_tgt-2*patch_length_c        
            patch_T = target(i:i-1+patch_size_r,j:j-1+patch_size_c,:); 
            %pixel above nn
            if i > 1 && NNF(i-1,j,1)<row_src-patch_length_r
                patch_3 = source(NNF(i-1,j,1)-patch_length_r+1:NNF(i-1,j,1)+patch_length_r+1,NNF(i-1,j,2)-patch_length_c:NNF(i-1,j,2)+patch_length_c,:);
                L2norm = sum((patch_T-patch_3).^2,'all');
                if L2norm < NNF(i,j,3) 
                    NNF(i,j,1) = NNF(i-1,j,1)+1;
                    NNF(i,j,2) = NNF(i-1,j,2);
                    NNF(i,j,3) = L2norm;
                end
            end   
            %pixel left nn
            if j > 1 && NNF(i,j-1,2) < col_src-patch_length_c
                patch_2 = source(NNF(i,j-1,1)-patch_length_r:NNF(i,j-1,1)+patch_length_r,NNF(i,j-1,2)-patch_length_c+1:NNF(i,j-1,2)+patch_length_c+1,:);
    
                L2norm = sum((patch_T-patch_2).^2,'all');
                if L2norm < NNF(i,j,3) 
                    NNF(i,j,1) = NNF(i-1,j,1)+1;
                    NNF(i,j,2) = NNF(i-1,j,2);
                    NNF(i,j,3) = L2norm;
                end
            end   
            NNF = random_search(source,target,patch_size_r,patch_size_c,NNF,i,j);
        end
    end
    
    for i = row_tgt-2*patch_length_r:-1:1
        for j = col_tgt-2*patch_length_c:-1:1      
            patch_T = target(i:i-1+patch_size_r,j:j-1+patch_size_c,:);           
            %pixel below nn
            if i < row_tgt-2*patch_length_r && NNF(i+1,j,1)-1 > patch_length_r
                patch_3 = source(NNF(i+1,j,1)-patch_length_r-1:NNF(i+1,j,1)+patch_length_r-1,NNF(i+1,j,2)-patch_length_c:NNF(i+1,j,2)+patch_length_c,:);          
                L2norm = sum((patch_T-patch_3).^2,'all');
                if L2norm < NNF(i,j,3) 
                    NNF(i,j,1) = NNF(i-1,j,1)+1;
                    NNF(i,j,2) = NNF(i-1,j,2);
                    NNF(i,j,3) = L2norm;
                end
            end 
            %pixel right nn
            if j < col_tgt-2*patch_length_c && NNF(i,j+1,2)-1 > patch_length_c           
                patch_2 = source(NNF(i,j+1,1)-patch_length_r:NNF(i,j+1,1)+patch_length_r,NNF(i,j+1,2)-patch_length_c-1:NNF(i,j+1,2)+patch_length_c-1,:);
                L2norm = sum((patch_T-patch_2).^2,'all');
                    if L2norm < NNF(i,j,3) 
                        NNF(i,j,1) = NNF(i-1,j,1)+1;
                        NNF(i,j,2) = NNF(i-1,j,2);
                        NNF(i,j,3) = L2norm;
                    end
            end
            NNF = random_search(source,target,patch_size_r,patch_size_c,NNF,i,j);
        end
    end

end