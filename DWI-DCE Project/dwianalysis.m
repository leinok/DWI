% -------------------------------------------------------------------------
% DWI-DCE Project. Investigate various technique factors.
%
% Main Function
% 1 DWIMatrix, and 2 GEAdc
% Inputs: 
% - dataFolder :
% - iNum:
%
% -- Examples:
% dwianalysis('\DWI-DCE Project\Data\1048950\0217\IRDWI\', 28);
% -- Lei Yang
% -------------------------------------------------------------------------

function [outputs] = dwianalysis(dataFolder, iNum)

dataFolder = [pwd, dataFolder];

hasImgProcessingToolBox = license('test', 'image_toolbox');
if hasImgProcessingToolBox == 0
    message = sprintf('No Image Processing Toolbox Checked\n Continue anyway?');
	reply = questdlg(message, 'Toolbox missing', 'Yes', 'No', 'No');
	if strcmpi(reply, 'No')
		return;
	end
end

disp('0 -- show the serial raw dwi');
disp('1 -- show the serial adc map, mono-exponential curve fitting');
disp('2 -- analyze the adc in detail in specific image');
disp('3 -- analyze the adc in bi-exponential');
choice = input('What do you want to try in this experiment?\n');                   

switch choice
    case 0
        showserialdwi(dataFolder);
    case 1
        showadcmap(dataFolder);
    case 2       
        singledwianalysis(dataFolder, iNum);
    case 3       
        ivimanalysis(dataFolder, iNum);
    otherwise
        disp('not a choice with current number');
end

end

