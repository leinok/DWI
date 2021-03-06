%--------------------------------------------------------------------------
% Image IVIM analysis
% Investigate registration, and bi-exponential analysis
%               S(b)/S(0)  =  f*exp(-b*D(p)) + (1-f)*exp(-b*D)
% We would have 2 analysis methods.
% The 1st is calculate the average value of ROI, and get a curve fit of the
% corresponding data (No need for registration)
% While the 2nd is registration and calculation every single point, we can
% also see the map
% -- Lei Yang
%--------------------------------------------------------------------------
function [outputs] = ivimanalysis(dataFolder, iNum)

load([dataFolder, 'DWIMatrix']);
msgbox('Select ROI to decrease the calculation time');
imshow(imageMatrix(:,:,iNum,2), [0 1000]);
h = imrect;
position = wait(h);
position = round(position);

height = position(4)+1;
width = position(3)+1;
% Test images
figure;
for i = 1:5
    realImgs(:,:,i) = imageMatrix(position(2):position(2)+position(4),...
        position(1):position(1)+position(3),iNum,i);
    subplot(1,5,i), imshow(realImgs(:,:,i), [0 1000]);
end

% Register images
regImgs = realImgs;
figure;
for i = 1:5
    if i ~= 2
        regImgs(:,:,i) = rigid_subpixel(realImgs(:,:,2), realImgs(:,:,i));
    end 
    subplot(1,5,i), imshow(regImgs(:,:,i), [0 1000]);
end


para = ivimmatrix(realImgs);
para_reg = ivimmatrix(regImgs);


roiWindow = CIVIMAnalyze(realImgs, curvePara); % all the adc except for the GE

end
