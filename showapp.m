% App for show the pixel's information and plot
% Need some documents in DWI-DCE project folder 
% addpath(genpath('DWI-DCE Project'));
% Input:
% varargin: should combined with my data matrix(:,:,ith,:)
% -- Lei Yang
function showapp(varargin)
    hf = figure('color', 'k','pointer', 'arrow','Menubar', 'none', 'toolbar','none', 'colormap', gray(256), 'visible', 'on', 'numbertitle', 'off','WindowScrollWheelFcn',@resize);     
    plot_fh = figure('Color', 'c', 'Menubar','none', 'Toolbar', 'none', 'Numbertitle', 'off', 'visible','off'); 
    plotData = guidata(plot_fh);
    plotData.ax_handle = axes('parent', plot_fh);
    plotData.wCoeff = [1 1 1 1 1];
  
    ht = uitoolbar('parent', hf);           % Handle of toolbar
                         
    data = guidata(hf);
    
    htt = [];                               % Handle of toggle tool
    hpt = [];
    htt(end+1) = uitoggletool(ht,'CData',localLoadIconCData('plot1.png',[pwd '/']),...
                         'TooltipString','Show Plotting', 'OnCallback',{@plotfigure, hf, plot_fh}, 'OffCallback', {@closeplot, hf, plot_fh});

    htt(end+1) = uitoggletool(ht, 'CData', localLoadIconCData('HDF_grid.gif'), 'TooltipString', 'Weighting Coefficients', ...
                         'OnCallback', {@getweight, hf, plot_fh}, 'OffCallback', {@setbackweight, hf, plot_fh});
    htt(end+1) = uitoggletool(ht, 'CData', localLoadIconCData('tool_shape_rectangle.png'), 'TooltipString', 'ROI registration', ...
         'OnCallback', {@roiregistration, hf, plot_fh}, 'OffCallback', {@roibacktofig, hf, plot_fh} );
    htt(end+1) = uitoggletool(ht, 'CData', localLoadIconCData('tool_ellipse.gif'), 'TooltipString', 'ROI ADC', ...
         'OnCallback', {@roiadc, hf, plot_fh}, 'OffCallback', {@roiadcback, hf, plot_fh} );
     
     
    hpt(end+1) = uipushtool(ht,'CData',localLoadIconCData('file_save.png'),'TooltipString','Save ROI',...
                         'ClickedCallback',{@saveRegROI, hf, plot_fh});    
    hpt(end+1) = uipushtool(ht,'CData',localLoadIconCData('file_open.png'),'TooltipString','Open ROI',...
                         'ClickedCallback',{@openRegROI, hf, plot_fh});                    
    hpt(end+1) = uipushtool(ht,'CData',localLoadIconCData('view_zoom_out.gif'),'TooltipString','Delete opened ROI',...
                         'ClickedCallback',{@deleteROI, hf, plot_fh});
                     
    data.realData = squeeze(varargin{1});
    data.img = data.realData(:,:,2);
    data.width = size(data.img, 2);
    data.length = size(data.img, 1);
    
    data.weights = [1 1 1 1 1];
    data.ax_handle = axes('parent', hf,'Position',[0 0 1 1],'ALimMode','manual','TickDirMode','manual','XTickMode','manual','YTickMode','manual','ZTickMode','manual','XTickLabelMode','manual','YTickLabelMode','manual','ZTickLabelMode','manual','SelectionHighlight','off','Visible','off','DrawMode','fast','YDir','reverse','ClimMode','auto','DataAspectRatioMode','manual','PlotBoxAspectRatioMode','manual','NextPlot','add');           
    data.imghandle = image('parent', data.ax_handle, 'EraseMode','normal','CDataMapping','scaled','Clipping','off','SelectionHighlight','off');
    set(data.imghandle, 'CData', data.img, 'Clipping', 'on');
    set(hf,'Units','normalized','Units','pixels', 'visible', 'on');   
   
    data.regData = data.realData;
    
    l=get(hf,'Position');
    m=l(3)/l(4);
    if data.width/data.length>m
                        n=round((data.length-data.width*m)/2);
                        set(data.ax_handle,'Xlim',[1+n data.length-n],'Ylim',[1 data.width]);
            else
                        n=round((data.width-data.length*l(4)/l(3))/2);
                        set(data.ax_handle,'Xlim',[1 data.length],'Ylim',[1+n data.width-n]);
            end
            
    temp = get(data.ax_handle, 'XLim');
    data.left = max(temp(1), 1);
    data.right = min(temp(2), data.width);
    
    temp = get(data.ax_handle, 'YLim');
    data.top = max(temp(1), 1);
    data.bottom = min(temp(2), data.length);
    
    set(hf,'WindowButtonMotionFcn',@showpixel);
	data.rect_handle = [];
    data.ellipse_handle = [];
    guidata(hf,data);
    guidata(plot_fh, plotData);
return;

function plotfigure(varargin)
    figure_handle = varargin{3};
    plot_handle = varargin{4};
%     plot(d.ax_handle, rand(1,20), rand(1,20), 'r-'), grid on;
    set(figure_handle, 'WindowButtonMotionFcn', {@showplot, plot_handle});
return;

function showpixel(handle, ~)
D = guidata(handle);
p = get(D.ax_handle, 'CurrentPoint');
x = round(p(1,2));
y = round(p(1,1));

if x > 0 & x < D.width & y > 0 & y < D.length
    set(handle,'Name',sprintf(['Pixel Value         [' num2str(x) ', ' num2str(y) '] = ' num2str(D.img(x,y))]));
else
    set(handle,'Name','Out of Image');
end 
return;

function showplot(handle, ~, phandle)
D = guidata(handle);
p = get(D.ax_handle, 'CurrentPoint');
x = round(p(1,2));
y = round(p(1,1));
pD = guidata(phandle);
set(phandle, 'visible', 'on');
xdata = [0 30 60 100 600];
ydata = zeros(1, 5);
if x > 0 & x < D.width & y > 0 & y < D.length
    set(handle,'Name',sprintf(['Pixel Value         [' num2str(x) ', ' num2str(y) '] = ' num2str(D.img(x,y))]));
    for i = 1:5
        ydata(i) = D.regData(x,y,i);
    end
    zerocheck = all(ydata);
    ydata = double(ydata)/double(ydata(1));
    if zerocheck == 1
        range = 0.2;
        [output, x1, y1] = ivim(ydata, 0, range, pD.wCoeff);
        plot(pD.ax_handle, x1, y1), grid on;
        hold(pD.ax_handle, 'on');
        plot(pD.ax_handle, xdata, ydata, 'r*');
        y2 = (1-output(1))*exp(-output(3)*x1);
        plot(pD.ax_handle, x1, y2, 'r');
        y3 = output(1)*exp(-output(2)*x1);
        plot(pD.ax_handle, x1, y3,'r');
        ylim(pD.ax_handle, [0 1.5]);
        hold(pD.ax_handle, 'off');
        set(phandle, 'Name', ['Bi-Exponential with coeff' mat2str(pD.wCoeff) ',range' num2str(range)]);
    else
        set(handle,'Name','Zero pixel exist in current point');
    end
else
    set(handle,'Name','Out of Image');
end 
return;

function closeplot(varargin)
    figure_handle = varargin{3};
    plot_handle = varargin{4};
    set(figure_handle, 'WindowButtonMotionFcn', @showpixel);
    set(plot_handle, 'visible', 'off');
return;

function resize(fhandle,e)
D=guidata(fhandle);
x=get(D.ax_handle,'XLim');
y=get(D.ax_handle,'YLim');
p=(x(1)+x(2))/2;
q=(y(1)+y(2))/2;
if e.VerticalScrollCount>0
            n=(x(2)-x(1))*0.55;
            m=(y(2)-y(1))*0.55;

elseif e.VerticalScrollCount<0
            n=(x(2)-x(1))*0.45;
            m=(y(2)-y(1))*0.45;

end
            a=p-n;
            b=p+n;
            c=q-m;
            d=q+m;
            D.left=max(a,1);
            D.right=min(b,D.width);
            D.top=max(c,1);
            D.bottom=min(d,D.length);
            set(D.ax_handle,'XLim',[a b],'YLim',[c d]);
guidata(fhandle,D);
return;

function getweight(varargin)
    fhandle = varargin{3};
    plot_handle = varargin{4};
    pData = guidata(plot_handle);
    temp = getcoefficient(5);    
    if ~isempty(temp)
        pData.wCoeff = temp;
    end
    guidata(plot_handle, pData);
return;

function setbackweight(varargin)
    fhandle = varargin{3};
    plot_handle = varargin{4};
    pData = guidata(plot_handle);
    pData.wCoeff = [1 1 1 1 1];
    guidata(plot_handle, pData);
return;

function roiregistration(varargin)
    fhandle = varargin{3};
    plot_handle = varargin{4};
    Data = guidata(fhandle);
    pData = guidata(plot_handle);
    
    Data.rect_handle = imrect(Data.ax_handle);
    position = wait(Data.rect_handle);
    position = round(position);
    setColor(Data.rect_handle,'red');
    set(get(Data.rect_handle,'Children'),'HitTest','off')
     figure('Name', 'Original sequences ROIs');
    for i = 1:5
        realImgs(:,:,i) = Data.realData(position(2):position(2)+position(4),...
            position(1):position(1)+position(3),i);
        subplot(1,5,i), imshow(realImgs(:,:,i), [0 1000]);
    end
    
% 
% % Register images
     figure('Name', 'Registered sequences ROIs');
    regImgs = realImgs;
    for i = 1:5
        if i ~= 2
            regImgs(:,:,i) = rigid_subpixel(realImgs(:,:,2), realImgs(:,:,i));
        end 
        subplot(1,5,i), imshow(regImgs(:,:,i), [0 1000]);
    end
    reg = regImgs(:,:,1);
    real = realImgs(:,:,1);
% aims to show the registration do have effects.
%     figure, subplot(1,2,1), imshow(reg, [0 1000]);
%         subplot(1,2,2), imshow(real, [0 1000]);
% save('reg1', 'reg', 'real');
%   
for i = 1:5
    Data.regData(position(2):position(2)+position(4),...
            position(1):position(1)+position(3),i) = regImgs(:,:,i);
end



guidata(fhandle, Data);

%  para = ivimmatrix(realImgs);
% para_reg = ivimmatrix(regImgs);

return;

function roibacktofig(varargin)
fhandle = varargin{3};
Data = guidata(fhandle);
if ~isempty(Data.rect_handle)
    delete(Data.rect_handle);
    Data.rect_handle = [];
end
Data.regData = Data.realData;
guidata(fhandle, Data);
return;

function roiadc(varargin)
fhandle = varargin{3};
plot_handle = varargin{4};
Data = guidata(fhandle);
pData = guidata(plot_handle);
Data.ellipse_handle = imellipse(Data.ax_handle);
position = wait(Data.ellipse_handle);
position = round(position);
setColor(Data.ellipse_handle,'red');

guidata(fhandle, Data);

return;

function roiadcback(varargin)
fhandle = varargin{3};
Data = guidata(fhandle);
if ~isempty(Data.ellipse_handle)
    delete(Data.ellipse_handle);
    Data.ellipse_handle = [];
end
guidata(fhandle, Data);
return;

function saveRegROI(varargin);
fhandle = varargin{3};
plot_handle = varargin{4};
Data = guidata(fhandle);
pData = guidata(plot_handle);

roiFolder = [pwd, '/DWI-DCE Project/Results-RFOV/RFROI/'];
allFileLists = dir(roiFolder);   
allFileLists = allFileLists(3:end);        % The first 2 are '.' and '..'
numFiles = numel(allFileLists);    

try
   defaultname = [roiFolder, num2str(numFiles+1), '.txt']   
   [filename, pathname, index] = uiputfile(defaultname,'Save ROI');
    if index ~= 0 
        fid1=fopen([pathname, filename],'at');
        roiPosition = round(getPosition(Data.rect_handle));
        fprintf(fid1, '%5f %5f %5f %5f\n', [roiPosition(1) roiPosition(2) roiPosition(3) roiPosition(4)]');
        roiPosition = round(getPosition(Data.ellipse_handle));
        fprintf(fid1, '%5f %5f %5f %5f\n', [roiPosition(1) roiPosition(2) roiPosition(3) roiPosition(4)]');
    end
  
catch
end

return;

function openRegROI(varargin)
fhandle = varargin{3};
plot_handle = varargin{4};
Data = guidata(fhandle);
pData = guidata(plot_handle);
roiFolder = [pwd, '/DWI-DCE Project/Results-RFOV/RFROI/'];
defaultname = [roiFolder, '*.txt'];
[filename,pathname,~] = uigetfile(defaultname);
try
    fileID = fopen([pathname, filename],'r');
    C_data = textscan(fileID,'%f %f %f %f','CollectOutput',1);
    pM = C_data{1};
      regPosition = pM(1,:);
      roiPosition = pM(2,:);
      if ~isempty(Data.rect_handle)
          delete(Data.rect_handle);
          Data.rect_handle = [];
          delete(Data.ellipse_handle);
          Data.ellipse_handle = [];
      end
      Data.rect_handle = imrect(Data.ax_handle, regPosition);
      setColor(Data.rect_handle,'red');
      set(get(Data.rect_handle,'Children'),'HitTest','off')
      Data.ellipse_handle = imellipse(Data.ax_handle, roiPosition);
      bw = createMask(Data.ellipse_handle);
    for i = 1:5
        realImgs(:,:,i) = Data.realData(regPosition(2):regPosition(2)+regPosition(4),...
            regPosition(1):regPosition(1)+regPosition(3),i);
    end
    
    regImgs = realImgs;
    for i = 1:5
        if i ~= 2
            regImgs(:,:,i) = rigid_subpixel(realImgs(:,:,2), realImgs(:,:,i));
        end
    end    
%   
for i = 1:5
    Data.regData(regPosition(2):regPosition(2)+regPosition(4),...
            regPosition(1):regPosition(1)+regPosition(3),i) = regImgs(:,:,i);
end

bw = bw(regPosition(2):regPosition(2)+regPosition(4),...
            regPosition(1):regPosition(1)+regPosition(3));
ivimstatistic(realImgs, bw);  % IVIM analysis
% fprintf('Now the register');
% ivimstatistic(regImgs, bw);
       
catch
    disp('Error in statistics computation');
end
guidata(fhandle, Data);
return;

function deleteROI(varargin)
fhandle = varargin{3};
plot_handle = varargin{4};
Data = guidata(fhandle);
pData = guidata(plot_handle);

      if ~isempty(Data.rect_handle)
          delete(Data.rect_handle);
          Data.rect_handle = [];

      end

      if ~isempty(Data.ellipse_handle)
          delete(Data.ellipse_handle);
          Data.ellipse_handle = [];
      end
guidata(fhandle, Data);
return;
