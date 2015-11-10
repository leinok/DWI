% this is copied from matlabs uitoolfactory.m, to load the icons for the toolbar
% The previous Mino-exponential is supposed not to be effected.
function cdata = localLoadIconCData(varargin)
% Loads CData from the icon files (PNG, GIF or MAT) in toolbox/matlab/icons.
% filename = info.icon;
filename = varargin{1};

    % Load cdata from *.gif file
    persistent ICONROOT

        if nargin == 2
            rootname = varargin{2};
            ICONROOT = [rootname];
        else
            ICONROOT = fullfile(matlabroot,'toolbox','matlab','icons',filesep);
        end


    if length(filename)>3 && strncmp(filename(end-3:end),'.gif',4)
        [cdata,map] = imread([ICONROOT,filename]);
        % Set all white (1,1,1) colors to be transparent (nan)
        ind = map(:,1)+map(:,2)+map(:,3)==3;
        map(ind) = NaN;
        cdata = ind2rgb(cdata,map);

        % Load cdata from *.png file
    elseif length(filename)>3 && strncmp(filename(end-3:end),'.png',4)
        [cdata map alpha] = imread([ICONROOT,filename]);
        % Converting 16-bit integer colors to MATLAB colorspec
        cdata = double(cdata) / 65535.0;
        % Set all transparent pixels to be transparent (nan)
        cdata(alpha==0) = NaN;

        % Load cdata from *.mat file
    else
        temp = load([ICONROOT,filename],'cdata');
        cdata = temp.cdata;
    end
end