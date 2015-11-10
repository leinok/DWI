% IVIM experiments: sub-pixel rigid registration
% --
% Example:
% load('DWI-DCE Project\Data\1053563\0304\RFOV\DWIMatrix');
% img1 = imageMatrix(105:156,100:151,5,4);
% img2 = imageMatrix(105:156,100:151,5,5);
% output = rigid_subpixel(img1, img2);

function [output] = rigid_subpixel(img1, img2)
    addpath(genpath('efficient_subpixel_registration'));
    [para Greg] = dftregistration(fft2(img1),fft2(img2),100);
    output = abs(ifft2(Greg));
end