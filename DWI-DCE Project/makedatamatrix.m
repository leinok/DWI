% -------------------------------------------------------------------------
% Generate images corresponding with bValues order.
%
% Parameters:
% 'dataPath': the folder which data are stored in current project.
% 'nDataSets': the number of sets of data serials.
% 'bValueArray': the corresponing bValues, just used in save this value.
% 'orderOfImg': the order which the image distributed in the data folder.
% Example:
%      path1 = [pwd, '\DWI-DCE Project\Data\DWI-5-16\'];
% 	   nDataSets = 3;
%      bValueArray = [0 200 800];
%      orderOfImg = [3 1 2];
%      makedatamatrix(path1, nDataSets, bValueArray, orderOfImg);
%
% N.B. For exported images, we should be very careful. They are always not the
% same order with the GE software without specific reasons.
% -- Lei Yang
% -------------------------------------------------------------------------

function makedatamatrix(dataPath, isADC, nDataSets, bValueArray, orderOfImg)

close all;
SPECIFIEDFIELD = 'InstanceNumber';
realPath = [dataPath];
allImageLists = dir(realPath);   
allImageLists = allImageLists(3:end);        % The first 2 are '.' and '..'
numFiles = numel(allImageLists);                    
nameByOrder = sort_nat({allImageLists.name});
if isADC == 1
    lengthSerial = numFiles;
else
    lengthSerial = numFiles/nDataSets;    
end

storeOrder = zeros(lengthSerial, 1);
for i = 1:numFiles
    fileName = [realPath,nameByOrder{i}];
    tempStructure = dicominfo(fileName);
    storeOrder(i) = tempStructure.(SPECIFIEDFIELD);
end

width = double(tempStructure.Width);
height = double(tempStructure.Height);
        
switch isADC
    case 1
        % Makeing ADC map
        GEAdc = zeros(height, width, lengthSerial,'uint16');
        wbHandle = waitbar(0, 'Transfer unordered GE adc into GEAdc matrix...');
        startTime = clock;
        for i = 1:lengthSerial
                tempNum = (find(storeOrder == i));    
                fileName = [realPath,  nameByOrder{tempNum}];
                img = dicomread(fileName);

                GEAdc(:,:,lengthSerial+1-i) = img;          % Reverse in this case.
                
                if i == 1
                    roughTime = etime(clock, startTime);
                    esttime = roughTime*lengthSerial;
                end
                waitbar(i/lengthSerial, wbHandle, ['remaining time =', ...
                num2str(esttime-etime(clock,startTime), '%4.1f'),'sec']);
                
        end
        delete(wbHandle);
        savedName = [dataPath, 'GEAdc.mat'];
        savedName = strrep(savedName, '\GEADC\','\');
        save(savedName, 'GEAdc');
    case 0
        % Making the original images
        if nargin < 5
            orderOfImg = 1:nDataSets;
        end

        imageMatrix = zeros(height, width, lengthSerial, nDataSets, 'uint16');

        wbHandle = waitbar(0, 'Transfer unordered raw images into image matrix...');
        startTime = clock;

        for i = 1:lengthSerial
            for j = 1:nDataSets
                tempNum = (storeOrder == (orderOfImg(j)-1)*lengthSerial+i);    
                fileName = [realPath,  nameByOrder{tempNum};];
                img = dicomread(fileName);
                a = dicominfo(fileName);
                a.('SliceLocation')
                imageMatrix(:,:,i,j) = img;
            end
            % Begin estimate remaining time
            if i == 1
                roughTime = etime(clock, startTime);
                esttime = roughTime*lengthSerial;
            end
            waitbar(i/lengthSerial, wbHandle, ['remaining time =', ...
                num2str(esttime-etime(clock,startTime), '%4.1f'),'sec']);
        end

        delete(wbHandle);
        savedName = [dataPath, 'DWIMatrix.mat'];
        savedName = strrep(savedName, '\DWI\','\');
        save(savedName, 'imageMatrix', 'nDataSets', 'bValueArray', ...
            'width', 'height', 'lengthSerial');

    otherwise
end

end

