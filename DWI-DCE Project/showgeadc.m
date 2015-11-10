%% Show the ADC MAp
% Make the ADC images from GE software
realFolder = [pwd '\DWI-DCE Project\Data\0618\SE4\'];
imgLists = dir(realFolder);
imgLists = imgLists(3:end);
nameByOrder = sort_nat({imgLists.name});
num = numel(imgLists);

for i = 1:num
    fileName = [realFolder nameByOrder{i}];
    a = dicominfo(fileName);
    storeOrder(i) = num+1-a.('InstanceNumber');
%     storeOrder(i)                 For check the corresponing index
%     a.('SliceLocation')           For check the position
end

adcGEImg = zeros(256,256,'int16');
for i = 1:num
    j = i;
    tempNum = find(storeOrder == j); 
    fileName = [realFolder, nameByOrder{tempNum}];
    adcGEImg = dicomread(fileName);
end
