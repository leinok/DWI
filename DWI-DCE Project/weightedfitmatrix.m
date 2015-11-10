%--------------------------------------------------------------------------
% DWI-DCE Project. Speed up the Linear fitting(weighted fitting)
% Parameters:
% 'x': x is a vector.
% 'y': y ia a matrx(with 3*(number of pixel in the image)).
% 'w': the weighting coefficients vector.
% Outputs:
% 'c2': the polynomical coefficients.
% --Lei Yang
%--------------------------------------------------------------------------
function [ results ] = weightedfitmatrix( x, yMatrix, w )
m = size(yMatrix,2);
wMatrix = repmat(w, 1, m);
xMatrix = repmat(x, 1, m);
if nargin == 2
    w = [1 1 1]'
end
stdv = sqrt(1./w);
S = sum(w);
Sx = sum(w.*x);
Sxx= sum(w.*x.^2);
Delta = S*Sxx - (Sx)^2;
SxxMatrix = repmat(Sxx, 1, m);
SxMatrix =  repmat(Sx, 1, m);

Sy = sum(wMatrix.*yMatrix);
Sxy= sum(wMatrix.*xMatrix.*yMatrix);
a = (SxxMatrix.*Sy - SxMatrix.*Sxy)./Delta;
b = (S*Sxy - Sx*Sy)./Delta;
results = b;
end

