% The function handle that represents the model
% Just used in our case
% testImgs are the dwi images from the same location which corresponding to different b values
function [output] = ivimmatrix(testImgs);

height = size(testImgs, 1);
width = size(testImgs, 2);

xdata = [0 30 60 100 600]';
% The function handle that represents the model
f = @(x,xdata) x(1)*exp(-(x(2)+x(3))*xdata) + (1-x(1))*exp(-x(3)*xdata);
% Starting from the arbitrary guess a0 = [2;2;2]
x0 = [0.2;0.019;0.001];
lb = [0 0 0];
ub = [1 1 1];
options = optimset('TolFun', 1e-16, 'Tolx', 1e-16);

ydataMatrix = zeros(5,height*width);
for iter = 1:5
    ydataMatrix(iter,:) = reshape(testImgs(:,:,iter), 1,height*width);
end
zerocheck = all(ydataMatrix,1);
curvePara = zeros(3,width*height);

tic
for iter = 1:height*width
    if zerocheck(iter) == 1
        ydata = ydataMatrix(:,iter);
        ydata = ydata/ydata(1);
        curvePara(:,iter) = lsqcurvefit(f, x0, xdata, ydata, lb, ub, options);  
    end
end
toc

output = curvePara;
output(2,:) = output(2,:)+output(3,:);
end