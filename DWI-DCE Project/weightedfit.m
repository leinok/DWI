function Results=weightedfit(x,y,w)

x = x';
y = y';
if nargin==3
    w = w';
else
    w = [1 1 1]';
end
stdv = sqrt(1./w);
S = sum(w);
Sx = sum(w.*x);
Sy = sum(w.*y);
Sxx= sum(w.*x.^2);
Sxy= sum(w.*x.*y);
Delta = S*Sxx - (Sx)^2;
a = (Sxx*Sy - Sx*Sxy)./Delta;
b = (S*Sxy - Sx*Sy)./Delta;
fprintf('\n slope=%f Int=%f \n',b,a)
Results.slope=b;
Results.Intercept= a;
y_fit = a + b*x;

     clf;set(gcf,'color','w');
     h=errorbar(x,y,stdv,'rs','MarkerFaceColor','r');
     title(['Weighted fit with weighting coefficient ' mat2str(w)])
     
hold on; q=plot(x,y_fit,'b.--','linewidth',2);
xlabel('x (Column 1)')
ylabel('y (Column 2)')
legend([h(1),q(1)],'Data',sprintf('\nSlope=%f\nIntercept=%f\n',b,a),'location','Southeast') 


end
