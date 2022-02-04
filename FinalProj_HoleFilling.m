clear;
clc;
close all;

%% PART 1 - SINGLE IMAGE HOLE FILLING

% NOTE - If you are using the mex files on GS during the development of your
% code, make sure your refer to the README

%% STEP 1 - Read in the image with the hole region 
% Read in the image, convert to RGBA with holes denoted by 0 alpha.
% Identify the region and size of the hole.
imageNoAlpha = imread('wall.jpg');
% figure
% imshow(image)

%% STEP 2 - Downsample image
% Iteratively downsample image till the dimension of the path is around the dimension
% of the hole. Store images at these multiple scales

%% STEP 3 - Perform Hole filling
% Perform hole filling at each scale, starting at the coarsest. Use
% repeated search and vote steps (refer to HW8 and the final project 
% descriptions) at each scale till values within the hole have converged.
% Pixels in the hole region are the targets, patches outside the hole are
% the source.
% Upsample the resulting image, and blend it with the original downsampled
% image at the same scale, to refine the values outside the hole.

% Parameters
numScales = 10;                 % number of scales


img_resize = imresize(imageNoAlpha, 1/numScales);
dim = size(img_resize);
img_resize = double(img_resize);
I = zeros(dim(1),dim(2),4);
I(:,:,1:3) = img_resize;
I(:,:,4) = ones(dim(1),dim(2),1);
for i = 1:dim(1)
    for j = 1:dim(2)
        if I(i,j,1) < 40 && I(i,j,2) > 170  && I(i,j,3) < 40
            I(i,j,4) = 0;
        end
    end
end

[all_row,all_col] = find(I(:,:,4) == 0);
first_row = min(all_row); first_col = min(all_col);
center_row = first_row+ceil(max(all_row) - min(all_row))/2;
center_col = first_col+ceil(max(all_col) - min(all_col))/2;

alpha = I(:,:,4);
I = I(:,:,1:3);
patch_size = 11;
patch_length = floor(patch_size/2);
target_patch = I(center_row-patch_length:center_row+patch_length,center_col-patch_length:center_col+patch_length,:); %extract patch from image
    figure; imshow(uint8(target_patch));
% [new_target,target2source,source2target]=my_search_vote_func(uint8(I),uint8(target_patch),10,patch_size,patch_size);
[new_target, target2source, source2target] = search_vote_func(uint8(I),uint8(target_patch),10);
    figure; imshow(uint8(new_target));
I(center_row-patch_length:center_row+patch_length,center_col-patch_length:center_col+patch_length,:) = new_target;
    figure; imshow(uint8(I))

for scaleCount = numScales:-1:1 %9 to 1
    img_resize = double(imresize(imageNoAlpha, 1/scaleCount));
%     imwrite(uint8(img_resize),strcat("images/output_downscaled_by",num2str(scaleCount))+".jpg");
    dim = size(img_resize);
    I = zeros(dim(1),dim(2),4); %img_resize with alpha values
    I(:,:,1:3) = img_resize;
    I(:,:,4) = ones(dim(1),dim(2),1);
    for i = 1:dim(1)
        for j = 1:dim(2)
            if I(i,j,1) < 30 && I(i,j,2) > 200  && I(i,j,3) < 30
                I(i,j,4) = 0;
            end
        end
    end
    
    [all_row,all_col] = find(I(:,:,4) == 0);
    first_row = min(all_row); first_col = min(all_col);
    last_row = max(all_row); last_col = max(all_col);
    center_row = first_row+ceil(max(all_row) - min(all_row))/2;
    center_col = first_col+ceil(max(all_col) - min(all_col))/2;
    next_patch_size = max(abs(last_row - first_col),abs(last_col - first_col));
    next_patch_length = floor(next_patch_size/2);
    if ~mod(next_patch_size,2)
        next_patch_size = next_patch_size +1;
    end
    
    target_patch = imresize(new_target,[next_patch_size next_patch_size]); %upsample new_target, set as target_patch
%     [new_target,target2source,source2target]=my_search_vote_func(img_resize,target_patch,10,next_patch_size,next_patch_size);
    [new_target, target2source, source2target] = search_vote_func(uint8(img_resize),uint8(target_patch),10);
    I = I(:,:,1:3);
    I(center_row-next_patch_length:center_row+next_patch_length,center_col-next_patch_length:center_col+next_patch_length,:) = new_target;
    figure; imshow(uint8(I))
%     imwrite(uint8(I),strcat("images/patchedoutput_downscaled_by",num2str(scaleCount))+".jpg");
end