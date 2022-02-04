function output = voteNNF( source,target,ann,bnn,patch_size_r,patch_size_c)
    [row_src, col_src, channel_src] = size(source);
    [row_tgt, col_tgt, channel_tgt] = size(target);
    patch_length_r = floor(patch_size_r/2);
    patch_length_c = floor(patch_size_c/2);
    output = zeros(row_tgt,col_tgt,channel_tgt);
    
    length_src1=row_src-2*patch_length_r-1;
    length_src2=col_src-2*patch_length_c-1;
    length_tgt1=row_tgt-2*patch_length_r-1;
    length_tgt2=col_tgt-2*patch_length_c-1;
    num_patches_S = (length_src1)*(length_src2);
    num_patches_T = (length_tgt1)*(length_tgt2);
    
    completeness = zeros(row_tgt, col_tgt, channel_tgt);
    completeness_nor = zeros(row_tgt, col_tgt, channel_tgt);
    
    coherence = zeros(row_tgt, col_tgt, channel_tgt);
    coherence_nor = zeros(row_tgt, col_tgt, channel_tgt);
    
    for channel = 1:channel_src
        for m = patch_length_r+1:row_src-patch_length_r     
            for n = patch_length_c+1:col_src-patch_length_c
                patch = double(source(m-patch_length_r:m+patch_length_r,n-patch_length_c:n+patch_length_c,channel));
                patch_T = [ann(m-patch_length_r,n-patch_length_c,1) ann(m-patch_length_r,n-patch_length_c,2)];
                for i = 1:patch_size_r
                    for j = 1:patch_size_c
                        completeness(patch_T(1)-patch_length_r+i-1,patch_T(2)-patch_length_c+j-1,channel) = completeness(patch_T(1)-patch_length_r+i-1,patch_T(2)-patch_length_c+j-1,channel) + patch(i,j);
                        completeness_nor(patch_T(1)-patch_length_r+i-1,patch_T(2)-patch_length_c+j-1,channel) = completeness_nor(patch_T(1)-patch_length_r+i-1,patch_T(2)-patch_length_c+j-1,channel)+1;
                    end
                end
            end
        end
    end
    
    for channel = 1:channel_tgt
        for m = 1:row_tgt-2*patch_length_r
            for n = 1:col_tgt-2*patch_length_c
                patch = double(source(bnn(m,n,1)-patch_length_r:bnn(m,n,1)+patch_length_r,bnn(m,n,2)-patch_length_c:bnn(m,n,2)+patch_length_c,channel));
                for i = 1:patch_size_r
                    for j = 1:patch_size_c
                        coherence(m+i-1,n+j-1,channel) = coherence(m+i-1,n+j-1,channel)+ patch(i,j);
                        coherence_nor(m+i-1,n+j-1,channel) = coherence_nor(m+i-1,n+j-1,channel)+1;
                    end
                end
            end
        end
    end
    
    for channel = 1:channel_tgt
        for m = 1:row_tgt
            for n = 1:col_tgt
                num=1/num_patches_S*completeness(m,n,channel)+1/num_patches_T*coherence(m,n,channel);
                den=(completeness_nor(m,n,channel)/num_patches_S)+(coherence_nor(m,n,channel)/num_patches_T);
                output(m,n,channel) = (num)/(den);
            end
        end
    end
    output = uint8(output);
end