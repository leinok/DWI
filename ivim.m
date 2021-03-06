% Add some constraints to the bi-exponential fitting
% S(b)/S(0) = f*exp(-(D+D*)b) + (1-f)*exp(-Db)
% Try to use lsqcuvefit function
% ydata should be double, and do some preprocessing about the original
% value ydata = double(ydata)/double(ydata(1));
% figureFlag: 1 show plot, 0 show nothing
% -- Example
%   ydata = [562 390 381 328 207];
%   ydata = double(ydata)/double(ydata(1))
%   ivim(ydata, 1)
% -- Lei Yang

function [outputs, x1, y1] = ivim(ydata, figureFlag, range, IP, ID, IF)
constraintFlag = 0;
if nargin > 2
    constraintFlag = 1;
end
if nargin > 3
    weights = [1 1 1 1 1];
end
outputs = [0 0 0];
x1 = 0:1:800;
y1 = x1;

xdata = [0 30 60 100 600];
% diffusion initial
if ydata(4) <= ydata(5)
    return;
end
dInitial = ID;
pInitial = IP-ID;

f = @(x,xdata) x(1)*exp(-(x(2)+x(3))*xdata) + (1-x(1))*exp(-x(3)*xdata);
fw = @(x, xdata) weights.*f(x, xdata);
% constraintFlag = 0;
x0 = [0.3;pInitial;dInitial];
% Initial value will be changable
if constraintFlag == 1

    lb = [IF*(1 - range) pInitial*(1 - range) dInitial*(1 - range)];
    ub = [IF*(1 + range) pInitial*(1 + range) dInitial*(1 + range)];
else
    lb = [0 0 0];
    ub = [1 1 1];
end

options = optimset('TolFun', 1e-16, 'Tolx', 1e-16, 'Display', 'off');

x = lsqcurvefit(fw, x0, xdata, ydata', lb, ub, options);
outputs = x;
% if x(1) > 0.01
    outputs(2) = x(2)+x(3);
% end

y1 = f(x,x1);

if figureFlag == 1
    figure
    plot(x1,y1);
    % plot(x1,y2,'g');
    hold on;
    plot(xdata, ydata, 'r*');
    xlabel('b-values');
    ylabel('log(S/S0)');
    hold on;

    y2 = (1-x(1))*exp(-x(3)*x1);
    plot(x1, y2, 'r');
    y3 = x(1)*exp(-(x(2)+x(3))*x1);
    plot(x1, y3,'r');
end

end
