% Distortion
function [J] = distortion(data)

Y = -1/2;

Dis(1) = 0;

for iter = 1:8
    [Idx, C, sumd, D] = kmeans(data, iter);
    Dis(iter+1) = sum(min(D,[],2))^(-0.5);    
    J(iter) = Dis(iter+1) - Dis(iter);
end

