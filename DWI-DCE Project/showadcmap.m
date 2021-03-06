% -------------------------------------------------------------------------
% DWI-DCE Project. Investigate various technique factors.
%
% Genetate and show the adc map
% Input:
% imageFolder: the folder which DWIMatrix stores.
%
% -- Example:
%  showserialdwi('\DWI-DCE Project\Data\1048950\0217\IRDWI\');
% -- Lei Yang
% -------------------------------------------------------------------------
function showadcmap( imageFolder )

imageData = [imageFolder 'DWIMatrix'];
load(imageData);
scrSize = get(0, 'ScreenSize');
combOrder = combnk(1:nDataSets, 2) % Currently we just consider all 2 combinations
numOfCombinations = size(combOrder, 1);

adcMap = zeros(height, width);                   % ADC map
yMatrix = zeros(nDataSets, width*height);

% Speed up the polyfit calculations
bValueMatrix = repmat(bValueArray',1,height*width);

figure('Name', 'Show of adc map', 'NumberTitle', 'off');
set(gcf, 'Toolbar','none', 'Menubar', 'none');
% Show the adc map
for i = 1:lengthSerial
    
    for j = 1:nDataSets
        yMatrix(j,:) =  reshape(imageMatrix(:,:,i,j), 1, width*height);
    end
    
    yMatrix = log(double(yMatrix));
    [C] = polyfitMatrix(bValueMatrix, yMatrix, 1);
    adcMap = reshape(-C(2,:), height, width);
     set(gcf, 'Units', 'pixels','position', scrSize);
    imshow(adcMap*200,'InitialMagnification','fit'), title(['ADC using all bValues, #' num2str(i)]);
    k = waitforbuttonpress;
    
% Draw the elliptical ROI
    h = imellipse;
    BW = h.createMask;
    RoiInfo = adcanalysis(adcMap, BW);            
    [indRow, indCol] = find(BW==1);
    x = max(indCol); y = max(indRow);
    showvalues(RoiInfo, x, y);
    
% Sho all adc mapps corresponing all combinations of bValues    
    for j = 1:numOfCombinations
        bPartValueMatrix = bValueMatrix(combOrder(j,:),:);
        yPartMatrix = yMatrix(combOrder(j,:),:);
        
        adc = (yPartMatrix(1,:)-yPartMatrix(2,:))./...
            (bPartValueMatrix(2,:)-bPartValueMatrix(1,:));
        
        adcMap = reshape(adc, height, width);
        imshow(adcMap*200);
        title(['adc map from combination of ' mat2str(bValueArray(combOrder(j,:)))]);
    end
end    

end

