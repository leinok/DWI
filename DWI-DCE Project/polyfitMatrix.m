% -------------------------------------------------------------------------
% DWI-DCE Project. Investigate various technique factors.
%
% Speed up the multiple polyfit  y = c2(0)+c2(1)*x^1+c2(2)*x^2+....
% Inputs:
% - 'x': x inputs.
% - 'y': y inputs.
% - 'n': the order of polynomial function
% Outputs:
% - 'c2': the polynomical coefficients.
% -- Lei Yang
% -------------------------------------------------------------------------
function [outPut] = polyfitMatrix(x,y,n)
% x and y is matrix.
m = size(x,2);

outPut = zeros(n+1,m);

% Comment these if the x is not the same
M = repmat(x(:,1),1,n+1);
M = bsxfun(@power,M,0:n);
         
for k = 1:m
    if length(find(isinf(y(:,k))==1)) > 0
       outPut(:,k) = [0 0];
    else
       % Uncomment these if the x is not the same
       % M = repmat(x(:,k),1,n+1);
       % M = bsxfun(@power,M,0:n);
       outPut(:,k) = M\y(:,k);
    end
end


end
