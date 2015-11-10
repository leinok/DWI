% Show the 6 adc methods, mid-treatment distribution
%
function [outputs] = stat(fileName)
close all;
mydata = load([pwd, fileName]);

inIndex = [1 2 3 4 5 6 8];
x = ones(8, 1);
y = 2*ones(8, 1);

miny = 10000;
maxy = 0;

for i = 1:6
    ax(i) = subplot(2,3,i);
    base = mydata.BaseMean(:,i);
    treat = mydata.TreatMean(:,i);
    plot(x(inIndex), base(inIndex),'bo', y(inIndex), treat(inIndex), 'bo');
    labels = cellstr( num2str(inIndex') );
    text(x(inIndex), base(inIndex), labels,'color',[.9 .1 .1], 'verticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    text(y(inIndex), treat(inIndex), labels,'color',[.9 .1 .1], 'verticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    title(mydata.name(i));
    temp = [base(inIndex);treat(inIndex)];
    if min(temp) <= miny
        miny = min(temp);
    end

    if max(temp) >= maxy
        maxy = max(temp);
    end

end
    linkaxes(ax, 'xy');
    set(ax(1),'yLim',[miny maxy]);

end