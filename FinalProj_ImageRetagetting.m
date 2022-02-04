clear;
clc;
close all;

%% PART 2 - IMAGE RETARGETTING
%%% Declaring parameters for the retargeting
minImgSize = 30;                % lowest scale resolution size for min(w, h)
scalingFactor = [1, 0.65];		% the ration of output image
numScales = 10;                 % number of scales (distributed logarithmically)

%% Preparing data for the retargeting
image = imread('SimakovFarmer.png');
[row, col, ~] = size(image);

size_tgt = scalingFactor .* [row, col];
imageLab = rgb2lab(image); % Convert the source and target Images
imageLab = double(imageLab)/255;

% Gradual Scaling - iteratively icrease the relative resizing scale between the input and
% the output (working in the coarse level).
%% STEP 1 - do the retargeting at the coarsest level

w_tgt=30;

%Downsample of original image:
w_new=47;
h_new=ceil(size_tgt(1)*w_tgt/size_tgt(2));

src_new=uint8(zeros([h_new,w_new,3]));

for i=1:h_new
    for j=1:w_new
        row_new=ceil(i*row/h_new);
        col_new=ceil(j*col/w_new);
        src_new(i,j,:)=image(row_new,col_new,:);
    end
end

%Gradual resizing step by doing the patch search and 
%vote (calling 'search_vote_func.m'):
target=src_new;

for s=w_new:-1:w_tgt
    tgt_i=imresize(target,[35 s],'bicubic');
    [target,~,~]=search_vote_func(src_new,tgt_i,10);
end

figure(1)
imshow(target);

%% STEP 2 - do resolution refinment 
% (upsample for numScales times to get the desired resolution)

[row_tgt,col_tgt]=size(target);
[row_src_new,col_src_new]=size(src_new);

tgt_ref=target;
src_i=image;
for i=1:numScales
    
    size_T_R=ceil((size_tgt(1)-row_tgt)/numScales*(i)+row_tgt);
    size_T_C=ceil((size_tgt(2)-col_tgt)/numScales*(i)+col_tgt);
    T_init=imresize(tgt_ref,[size_T_R size_T_C]);
    
    size_S_R=ceil((row-row_src_new)/numScales*(i)+row_src_new);
    size_S_C=ceil((col-col_src_new)/numScales*(i)+col_src_new);
    src_i=imresize(src_i,[size_S_R size_S_C]);
    
    [tgt_ref,~,~]=search_vote_func(src_i,T_init,10);
    figure
    imshow(tgt_ref)
end

figure(2)
imshow(tgt_ref);

%% STEP 3 - do final scale iterations
% (refine the result at the last scale)
[final_output,target2source,source2target]=search_vote_func(image,tgt_ref,10);

figure(3)
imshow(final_output);