% -------------------------------------------------------------------------
% DWI-DCE Project. Investigate various technique factors.
%
% Show the serial dwi data
% Input:
% imageFolder: the folder which DWIMatrix stores.
%
% -- Example:
%  showserialdwi('\DWI-DCE Project\Data\1048950\0217\IRDWI\');
% -------------------------------------------------------------------------
function showserialdwi(imageFolder)

imageData = [imageFolder 'DWIMatrix'];
load(imageData);
figure('Name', 'Show the whole serial data', 'NumberTitle', 'off');
set(gcf, 'Toolbar','none', 'Menubar', 'none');   
scrSize = get(0, 'ScreenSize'); 
set(gcf, 'Units', 'pixels','position', scrSize); 

i = 1;
while i < lengthSerial+1
    for j = 1:nDataSets
        subplot(1,nDataSets,j), imshow(imageMatrix(:,:,i,j), [0 1000]);
        title(['#' num2str(i) '-DWI with bValue' num2str(bValueArray(j))]);
    end
	k = waitforbuttonpress; % 0 if it detects a mouse button click
    if k == 0 && i > 1
       i = i - 1;
    else 
       i = i + 1;
    end
end

end

