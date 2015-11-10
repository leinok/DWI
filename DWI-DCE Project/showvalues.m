% -------------------------------------------------------------------------
% DWI-DCE Project. Investigate various technique factors.
%
% Text the values on the plot
% Input:
% - Info: the information structure.
% - x : x coordinate, the number of columns.
% - y : y coordinate, the number of rows.
%   optional inputs
% - i: For the purpose of color in text
% - otherAxes: Handle for text
%
% -- Example:
%  showvalues(Info, 10, 10);
% -------------------------------------------------------------------------
function tHandle = showvalues(Info, x, y, i, otherAxes )
    
    color = [1 1 0;1 0 1;0 1 1;1 0 0;0.5 0.2 0.3;0.8 0.1 0.1];
    message = sprintf('avg = %f\ns.d. = %f\nMinus = %dnTotal = %d', Info.avg, sqrt(Info.var), Info.nMinus, Info.nTotal);  % Show mean and variance
    
    if nargin > 3
        tHandle = text(x, y, message,'EdgeColor','blue', 'background',color(i,:), 'Fontsize', 12, 'parent', otherAxes);
        draggable(tHandle);
    else
        i = 1;
        tHandle = text(x, y, message,'EdgeColor','blue','background',color(i,:), 'color', [0.9 0.05 0.05], 'Fontsize', 12);
        draggable(tHandle);
    end
%   waitforbuttonpress();         % wait for key press or click the button
end

