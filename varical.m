load statisData1
load statisData2
load numberMatrix % [all, 0-200, 0-800, 200-800]
load numberMatrixIVIM


% Baseline
% meanV = M_200800(:,2);
% sdV = M_200800(:,4);
% 
% i = 4;
% % W = numMatrixMuscleBaseline(:,i);
% W = numMatrixMuscleInter(:,i);
% W = W/sum(W);
% t = sum(W.*meanV);
% 
% y = sqrt(sum(W.*(sdV.^2 + (meanV).^2)) - (t).^2)




%IVIM

% Baseline
meanV = IVIMAll(:,2);
sdV = IVIMAll(:,4);

i = 1;
% W = numberIVIMBaseline(:,i);
W = numberIVIMInter(:,i);
W = W/sum(W);
t = sum(W.*meanV);

y = sqrt(sum(W.*(sdV.^2 + (meanV).^2)) - (t).^2)
