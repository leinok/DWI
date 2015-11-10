% The previous monn-exponential should add one parameters like:
% --Example:
% getcoefficient(3);

function [R] = getcoefficient(num)

R = [];  % In case the user closes the GUI.

nameMatrix = cell(1,num);
for i = 1:num
    nameMatrix{i} = ['Input #'  num2str(i) 'weight'];
end
designmatrix = repmat([1 30], num, 1);
x = inputdlg(nameMatrix,'Customrized weighting', designmatrix); 
if ~isempty(x)

    for i = 1:num
        R(i) = str2double(x{i});
    end
end

end
%        