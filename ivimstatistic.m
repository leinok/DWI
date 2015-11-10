% Used in showapp, for statistics of several model
% 1), [0 30 60 100] mono-exponential
% 2), [100 600] mono-exponential (2-points)
% 3), bi-exponential fitting
function [output] = ivimstatistic(imgs, BW)
indices = find(BW==1);
matrixpatient = zeros(length(indices),4);

bValues = [0 30 60 100 600];                % Fixed in this experiment
[height, width, N] = size(imgs);
% 1
bValueArray = [0 30 60 100 600];
bValueMatrix = repmat(bValueArray',1,height*width);               % Speed up the polyfit calculations
yMatrix = zeros(5, width*height);
for j = 1:5
    yMatrix(j,:) =  reshape(imgs(:,:,j), 1, width*height);
end
 ind = find(yMatrix == 0);
yMatrixlog = log(double(yMatrix));                               % Be careful about the case of log(0)
yMatrixlog(ind) = 0;
    
[C1] = polyfitMatrix(bValueMatrix, yMatrixlog(1:5,:), 1);
% exp(C1(1,:)) is intensity of S0;

adc_monoP = reshape(-C1(2,:), height, width);              % 2nd All B-values
matrixpatient(:,1) = adc_monoP(indices)*1e6;
RoiInfo1 = adcanalysis(adc_monoP, BW);  
RoiInfo1.avg*1e6
sqrt(RoiInfo1.var)*1e6

bValues = [0 30 60 100 600];                % Fixed in this experiment
[height, width, N] = size(imgs);
% 1
bValueArray = [0 30 60 100];
bValueMatrix = repmat(bValueArray',1,height*width);               % Speed up the polyfit calculations
yMatrix = zeros(5, width*height);
for j = 1:5
    yMatrix(j,:) =  reshape(imgs(:,:,j), 1, width*height);
end
 ind = find(yMatrix == 0);
yMatrixlog = log(double(yMatrix));                               % Be careful about the case of log(0)
yMatrixlog(ind) = 0;
    
[C1] = polyfitMatrix(bValueMatrix, yMatrixlog(1:4,:), 1);
% exp(C1(1,:)) is intensity of S0;

adc_monoP = reshape(-C1(2,:), height, width);              % 2nd All B-values
RoiInfo1 = adcanalysis(adc_monoP, BW);  
RoiInfo1.avg*1e6
sqrt(RoiInfo1.var)*1e6
%2
C2 = (yMatrixlog(4,:)-yMatrixlog(5,:))./500;
SH = yMatrixlog(4,:) - (1/5)*(yMatrixlog(5,:)-yMatrixlog(4,:));

adc_monoD = reshape(C2, height, width);              % 2nd All B-values
RoiInfo2 = adcanalysis(adc_monoD, BW); 
RoiInfo2.avg*1e6
sqrt(RoiInfo2.var)*1e6

%3
range = 0.2;
ydata = zeros(1, 5);

ivimData = zeros(length(find(BW==1)),3);
kk = 1;

fraction = 1 - exp(SH)./exp(C1(1,:));
% We have yMatrix

pVector = zeros(1, height*width);
dVector = zeros(1, height*width);
fVector = zeros(1, height*width);


BW1 = reshape(BW, 1, height*width);
for i = 1:height*width
    if BW1(i) == 1
        ydata = yMatrix(:,i);
        zerocheck = all(ydata);
        if zerocheck == 1 && C2(i) > 0 && -C1(2,i) > C2(i)
           kk = kk+1;
           range = 0.2;
           [output, x1, y1] = ivim(ydata, 0, range, -C1(2,i), C2(i), fraction(i));
           pVector(i) = output(2);
           dVector(i) = output(3);
           fVector(i) = output(1);
           ivimData(kk,:) =  output';
        end 
    end
end

pImg = reshape(pVector, height, width);
dImg = reshape(dVector, height, width);
fImg = reshape(fVector, height, width);

matrixpatient(:,2) = pVector(indices)*1e6;
matrixpatient(:,3) = dVector(indices)*1e6;
matrixpatient(:,4) = fVector(indices);

final = ivimData(1:kk,:);
mean(final).*[1, 1e6, 1e6]
sqrt(var(final,1)).*[1, 1e6, 1e6]
end