% load statisData1
% load statisData2
% clear
load pixeldata/p5IVIMInter1
load pixeldata/p5IVIMBase1

i = 1;
% M = De(:,2);
% T = De(:,1);
M = p5IVIMInter1(:,i) ;
M(find(M<1e-10)) = [];
T = p5IVIMBase1(:,i) ;
T(find(T<1e-10)) = [];
Maverage = mean(M);
Taverage = mean(T);

SMT = sqrt(var(M)+var(T));

t = (Taverage - Maverage) / SMT;


pvalue = 2*(1 - tcdf(abs(t), (length(M)+length(T)-2)))



