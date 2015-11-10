function save2excel(mean, sd, mrn, date)
name{1} = 'GE';
name{2} = 'ALL';
name{3} = '0&200';
name{4} = '0&800';
name{5} = '200&800';

for i = 1:5
    A = {mrn,date,mean(i),sd(i)};
    name = [pwd, '\DWI-DCE Project\Results\Statistics\', name{i}];
    xlswrite(name, A);
end

end