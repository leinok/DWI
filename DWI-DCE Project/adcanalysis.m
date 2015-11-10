% -------------------------------------------------------------------------
% DWI-DCE Project. Investigate various technique factors.
%
% Some statistical values about adc map
% Inputs:
% - realAdcMap: the interested adc map.
% - BW: BW is used to show the ROI mask.
% Outputs:
% - Info: struct
% -- Lei Yang
% -------------------------------------------------------------------------
function [Info] = adcanalysis(realAdcMap, BW)
    
indices = find(BW==1);
ttemp = realAdcMap(indices);
ttemp1 = ttemp(find(ttemp>0));      % Remove the unreasonable data
Info.avg = mean(ttemp1);
Info.var = var(ttemp1, 1);

% Optional
Info.max = max(ttemp);
Info.min = min(ttemp);
Info.nTotal = length(ttemp);
Info.nMinus = length(find(ttemp <= 0));


% hist(Temp(Temp~=0));      

end
