% -------------------------------------------------------------------------
% DWI-DCE Project. Investigate various technique factors.
%
% ROI class definition. 
% Input:
% - dataFolder: the folder which DWIMatrix stores.
% - interestedNum: single image number
%
% -- Example:
%  singledwianalysis('\DWI-DCE Project\Data\1048950\0217\IRDWI\', 28);
% -- Lei Yang	
% -------------------------------------------------------------------------
classdef CROIAnalyze < handle

    properties
        pID         % Patient ID
        pDate       % Date of data
        iNumber     % image number
        image       % image to work on, obj.image = theImageToWorkOn
        roi         % the generated ROI mask (logical)
                    % roi image
        adcMaps
        comName     
        comNumber   % control the number of automatic acex (all bs, 2 bs)
        copiedNum
        bValues
        yMatrix
        labels      % Connected component labens (multi ROI)
        number      % how many ROIs there are
        texts = {};
        figh = 300; % initial figure height - your image is scaled to fit.
                    % On change of this the window gets resized
    end

    properties(Access=private)
        % UI stuff
        
        guifig      % mainwindow
        imax        % holds working area which corresponding to the GE adc
        adcAxes     % Show the generated adc
        weightedAxes% Show the different weighting coefficients
        weightcoef
        
        imag        % image to work on
        adcPlots
        
        tl          % userinfo bar
  
        figw        % initial window height, this is calculated on load
        hwar = 1.5; % aspect ratio

        % Class stuff
        loadmask    % mask loaded from file
        mask        % mask defined by shapes
        current     %  which shape is selected
        shapes = {};% holds all the shapes to define the mask.
        copiedShapes = {}; % should stay the same with shapes.

        % load/save information
        filename
        pathname
    end

    %% Public Methods
    methods 

        function this = CROIAnalyze(adcMatrix, iStruct, combinationName, numOfADC, ...
                bValueArray, yMatrix)
        % constructor
            % make sure the window appears "nice" (was hard to find this
            % aspect ratio to show a well aligned UI ;)

            theImage = adcMatrix(:,:,1);
            this.iNumber = iStruct.serialNum;
            this.pID = iStruct.mrn; 
            this.pDate = iStruct.date;
            this.figw = this.figh*this.hwar;
            
            this.comName = combinationName;
            this.comNumber = numOfADC;
            % invoke the UI window
            this.createWindow;
            
            this.bValues = bValueArray;
            this.yMatrix = yMatrix;
            this.weightcoef = [1 1 1];
            for i = 1:this.comNumber
                 this.adcMaps{i} = adcMatrix(:,:,i+1);      % The first one is GE adc
            end
            % load the image
            if nargin > 0
                this.image = theImage;

            else
                this.image = ones(100,100);
            end        

           
            % predefine class variables
            this.current = 1;
            this.shapes = {}; % no shapes at start
            this.copiedShapes = {};
            this.filename = 'mymask'; % default filename
            this.pathname = pwd;      % current directory
        end

        function delete(this)
        % destructor
            delete(this.guifig);
        end 

        function set.image(this,theImage)
        % set method for image. uses grayscale images for region selection
            if size(theImage,3) == 3
                this.image = im2double(rgb2gray(theImage));
            elseif size(theImage,3) == 1
                this.image = im2double(theImage);
            else
                error('Unknown Image size?');
            end
            this.resetImages;
            this.resizeWindow;
        end

        function set.figh(this,height)
            this.figh = height;
            this.figw = this.figh*this.hwar;
            this.resizeWindow;
        end

        function [roi, labels, number] = getROIData(this,varargin)
        % retrieve ROI Data
            roi = this.roi;
            labels = this.labels;
            number = this.number;
        end
    end

    % private used methods
    methods(Access=private)
        % general functions -----------------------------------------------
        function resetImages(this)
            this.newROI;

            % load images
            this.imag = imshow(this.image*200, 'parent',this.imax);
            
            for i = 1:this.comNumber
                this.adcPlots(i) = imshow(this.adcMaps{i}*200, 'parent', this.adcAxes(i));
            end
            

            % set masks to blank
            this.loadmask = zeros(size(this.image));
        end

        function updateROI(this, a)
            set(this.tl,'String','ROI not saved/applied','Visible','on','BackgroundColor',[255 182 193]./256);
            this.mask = this.loadmask | zeros(size(this.image)) ;
            for i=1:numel(this.shapes)
               BWadd = this.shapes{i}.createMask(this.imag);
               this.mask = this.mask | BWadd;
            end
%             set(this.adcMap1,'CData',this.image.*this.mask);
        end

        function newShapeCreated(this)
            set(this.shapes{end},'Tag',sprintf('imsel_%.f',numel(this.shapes)));
            this.shapes{end}.addNewPositionCallback(@this.updateROI);
            this.updateROI;
        end
        
       % CALLBACK FUNCTIONS
       % window/figure
        function winpressed(this,~,~,type)
            SelObj = get(gco,'Parent');
            Tag = get(SelObj,'Tag');
            if and(~isempty(SelObj),strfind(Tag,'imsel_'))
                this.current = str2double(regexp(Tag,'\d','match'));
                for i=1:numel(this.shapes)
                   if i==this.current
                       setColor(this.shapes{i},'red');
                   else
                       setColor(this.shapes{i},'blue');
                   end
                end
            end
        end

        function closefig(this,~,~)
            delete(this);
        end;

        % button callbacks ------------------------------------------------
        function polyclick(this, ~,~)
            this.shapes{end+1} = impoly(this.imax);
            this.newShapeCreated; % add tag, and callback to new shape
        end

        function elliclick(this, ~,~)
            this.shapes{end+1} = imellipse(this.imax);
            this.newShapeCreated; % add tag, and callback to new shape
        end

        function freeclick(this,~,~)
            this.shapes{end+1} = imfreehand(this.imax);
            this.newShapeCreated; % add tag, and callback to new shape
        end

        function rectclick(this,~,~)
            this.shapes{end+1} = imrect(this.imax);
            this.newShapeCreated; % add tag, and callback to new shape
        end

        function deleteclick(this,~,~)
        % delete currently selected shape
            if ~isempty(this.current) && this.current > 0
                n = findobj(this.imax, 'Tag',['imsel_', num2str(this.current)]);
                delete(n);
                % renumbering of this.shapes: (e.g. if 3 deleted: 4=>3, 5=>4,...
                for i=this.current+1:numel(this.shapes)
                    set(this.shapes{i},'Tag',['imsel_', num2str(i-1)]);
                end
                this.shapes(this.current)=[];
                this.current = numel(this.shapes);
                this.updateROI;
            else
                disp('first select a shape to remove');
            end
            if ~isempty(this.copiedShapes)
                
                for i = this.copiedNum:-1:1
                    for j = this.comNumber:-1:1
                        indexNum = (i-1)*this.comNumber+j;
                        n1 = findobj(this.adcAxes(j), 'Tag', num2str(indexNum));
                        delete(n1);
                        this.copiedShapes(indexNum) = [];
                    end
                end
                
                
            end
             if ~isempty(this.texts)
                numTexts = (this.comNumber+1)*this.copiedNum;
                for i = numTexts:-1:1
                    delete (this.texts{i});
                    this.texts{i} = [];
                end
             end
        end

        function copyclick(this, ~, ~, varargin)
            set(this.tl,'String','ROI applied','Visible','on','BackgroundColor','g');
            this.roi = this.mask;
            [this.labels, this.number] = bwlabel(this.mask); 

            num = numel(this.shapes);
            this.copiedNum = num;
            
            for i = 1:num
                roiPosition = getPosition(this.shapes{i});
                bw = createMask(this.shapes{i});
                [indRow, indCol] = find(bw==1);
                indices = find(bw==1);
                
                data = zeros(length(indRow), 4);
                xx = max(indCol); yy = max(indRow);
                %
                matrixpatient = zeros(length(indices),4);
                %
                for j = 1:this.comNumber
                    if j <=4
                    data(:,j) = this.adcMaps{j}(indices);
                    end
                    indexNum = (i-1)*this.comNumber+j;
                    this.copiedShapes{indexNum} = imellipse(this.adcAxes(j), roiPosition);            
                    set(this.copiedShapes{indexNum}, 'Tag',num2str(indexNum));
                    RoiInfo = adcanalysis(this.adcMaps{j}, bw);
                    tmp = this.adcMaps{j}(indices);
                    matrixpatient(:,j) = tmp;
                    this.texts{indexNum+num} = showvalues(RoiInfo, xx+20, yy, i, this.adcAxes(j));                   
                end
                 [indx indy] = find(data <= 0)
                 data(indx, :) = [];
                 
                RoiInfo = adcanalysis(this.image, bw);
                this.texts{i} = showvalues(RoiInfo, xx+20, yy, i, this.imax);
            end
            
        end
         
        function renewweighted(this, ~, ~, varargin)
            temp = getcoefficient(3);                
            if ~isempty(temp)
                this.weightcoef = temp
                slope = weightedfitmatrix(this.bValues', this.yMatrix, this.weightcoef');
                this.adcMaps{end} = reshape(-slope, size(this.image,1), size(this.image,2));
                this.adcPlots(end) = imshow(this.adcMaps{end}*200, 'parent', this.adcAxes(end));
                uicontrol('tag','txtmap3','style','text','string',mat2str(this.weightcoef),'units','normalized',...
                        'Fontsize',12,'position',[0.87 0.5 0.1 0.02], ...
                        'BackgroundColor',[0.0 0.8 1.0]);
            else
            end
        end
        
        function saveROI(this, ~,~)
            try

                roiFolder = [pwd, '\DWI-DCE Project\Results-IRDWI\ROI\'];
                statFolder = [pwd, '\DWI-DCE Project\Results-IRDWI\Statistics\'];
                name{1} = [statFolder, 'GE'];
                name{2} = [statFolder, 'ALL'];
                name{3} = [statFolder, '0&200'];
                name{4} = [statFolder,'0&800'];
                name{5} = [statFolder,'200&800'];
                allFileLists = dir([roiFolder '/*.txt']);   
%                 allFileLists = allFileLists(3:end);        % The first 2 are '.' and '..'
                numFiles = numel(allFileLists);     
                defaultname = [roiFolder, num2str(numFiles+1), '.txt']
                [this.filename, this.pathname, index] = uiputfile(defaultname,'Save ROI');
                set(this.tl,'String',['ROI saved: ' this.filename],'Visible','on','BackgroundColor','g');
                if index ~= 0 
                    maxNum = this.copiedNum;               % Number of shapes;
                    fid1=fopen([this.pathname, this.filename],'at');
                    statName = strrep([this.pathname, this.filename], 'ROI', 'Statistics')
                    fid2=fopen(statName,'at');
                    for i = 1:maxNum 
                        roiPosition = getPosition(this.shapes{i});
                        fprintf(fid1, '%5f %5f %5f %5f\n', [roiPosition(1) roiPosition(2) roiPosition(3) roiPosition(4)]');
                        bw = createMask(this.shapes{i});
                        save('ROI', 'bw');
                        RoiInfo = adcanalysis(this.image, bw);
                        M(1) = RoiInfo.avg;
                        SD(1) = sqrt(RoiInfo.var);
                        for j = 1:this.comNumber
                            RoiInfo = adcanalysis(this.adcMaps{j}, bw);  
                            M(j+1) = RoiInfo.avg;
                            SD(j+1) = sqrt(RoiInfo.var);
                        end
                        fprintf(fid2, 'Mean %5f %5f %5f %5f %5f %5f\n',M);
                        fprintf(fid2, 'SD   %5f %5f %5f %5f %5f %5f\n',SD);
                        fprintf(fid2, 'SD   %5f %5f %5f %5f %5f %5f\n',SD);
                    for k = 1:5
                        A = {this.pID,this.pDate,M(k),SD(k)};      
                        if ~exist([name{k}, '.xls'])
                            xlswrite(name{k}, A)
                        else
                            xlsappend(name{k}, A);
                        end
                    end
                    
                    end
                    fclose(fid1);
                    fclose(fid2);
                end
            catch
                % aborted
            end
        end

        function openROI(this, ~,~)
        % load Mask from File
          this.newROI; % delete stuff
          roiFolder = [pwd, '/DWI-DCE Project/Results-IRDWI/ROI/'];
          defaultname = [roiFolder, '*.txt'];
          [this.filename,this.pathname,~] = uigetfile(defaultname);
          try
              fileID = fopen([this.pathname, this.filename],'r');
              C_data = textscan(fileID,'%f %f %f %f','CollectOutput',1);
              pM = C_data{1};
              num = size(pM,1);
              for i = 1:num
                      roiPosition = pM(i,:);
                      this.shapes{end+1} = imellipse(this.imax, roiPosition);
                      this.newShapeCreated;
              end             
%               b = load([this.pathname,this.filename],'-mat');
%               if size(b.logicmask)~=size(this.image)
%                   set(this.tl,'String',['Size not matching! ' this.filename],'Visible','on','BackgroundColor','r');
%               else
%                   this.loadmask = b.logicmask;
%                   this.updateROI;
%                   set(this.tl,'String',['Current: ' this.filename],'Visible','on','BackgroundColor','g');
%               end
          catch
              % aborted
          end
        end

        function newROI(this, ~,~)
            this.mask = zeros(size(this.image));
            this.loadmask = zeros(size(this.image));
            % remove all the this.shapes
            for i=1:numel(this.shapes)
                delete(this.shapes{i});
            end
            this.current = 1; % defines the currently selected shape - start with 1
            this.shapes = {}; % reset shape holder
            this.updateROI;
        end

        % UI FUNCTIONS ----------------------------------------------------
        function createWindow(this, w, h)


              figureName = sprintf('ROI-Analyzer-#%d, %d, %d',[this.pID this.pDate this.iNumber]);
              this.guifig=figure('MenuBar','none','Resize','on','Toolbar','none','Name',figureName, ...
                'NumberTitle','off','Color','white', 'units','normalized','outerposition',[0 0 1 1],...
                'CloseRequestFcn',@this.closefig, 'visible','off');

            % buttons
            buttons = [];
            buttons(end+1) = uicontrol('Parent',this.guifig,'String','Polygon',...
                                       'units','normalized',...
                                       'Position',[0.01 0.8 0.1 0.15], ...
                                       'Callback',@(h,e)this.polyclick(h,e));
            buttons(end+1) = uicontrol('Parent',this.guifig,'String','Ellipse',...
                                       'units','normalized',...
                                       'Position',[0.01 0.68 0.1 0.15],...
                                       'Callback',@(h,e)this.elliclick(h,e));
            buttons(end+1) = uicontrol('Parent',this.guifig,'String','Freehand',...
                                       'units','normalized',...
                                       'Position',[0.01 0.56 0.1 0.15],...
                                       'Callback',@(h,e)this.freeclick(h,e));
            buttons(end+1) = uicontrol('Parent',this.guifig,'String','Rectangle',...
                                       'units','normalized',...
                                       'Position',[0.01 0.44 0.1 0.15],...
                                       'Callback',@(h,e)this.rectclick(h,e));
            buttons(end+1) = uicontrol('Parent',this.guifig,'String','Delete',...
                                       'units','normalized',...
                                       'Position',[0.01 0.32 0.1 0.15],...
                                       'Callback',@(h,e)this.deleteclick(h,e));
            buttons(end+1) = uicontrol('Parent',this.guifig,'String','Copy',...
                                       'units','normalized',...
                                       'Position',[0.01 0.20 0.1 0.15],...
                                       'Callback',@(h,e)this.copyclick(h,e));
            buttons(end+1) = uicontrol('Parent',this.guifig,'String','Weighted Calculation',...
                                       'units','normalized',...
                                       'Position',[0.01 0.08 0.1 0.15],...
                                       'Callback',@(h,e)this.renewweighted(h,e));
                                   

            % axes
            this.imax = axes('parent',this.guifig,'units','normalized','position',[0.05 0.55 0.42 0.42]);
            this.adcAxes(1) = axes('parent',this.guifig,'units','normalized','position',[0.35 0.55 0.42 0.42]);
            this.adcAxes(2) = axes('parent', this.guifig, 'units', 'normalized', 'position', [0.65 0.55 0.42 0.42]);
            this.adcAxes(3) = axes('parent', this.guifig, 'units', 'normalized', 'position', [0.05 0.07 0.42 0.42]);
            this.adcAxes(4) = axes('parent', this.guifig, 'units', 'normalized', 'position', [0.35 0.07 0.42 0.42]);
            this.adcAxes(5) = axes('parent', this.guifig, 'units', 'normalized', 'position', [0.65 0.07 0.42 0.42]);

            linkaxes([this.imax this.adcAxes(1) this.adcAxes(2) this.adcAxes(3) this.adcAxes(4) this.adcAxes(5)]);
            % create toolbar
            this.createToolbar(this.guifig);

            % add listeners
            set(this.guifig,'WindowButtonDownFcn',@(h,e)this.winpressed(h,e,'down'));
            set(this.guifig,'WindowButtonUpFcn',@(h,e)this.winpressed(h,e,'up')) ;

            
            % axis titles
            uicontrol('tag','txtimax','style','text','string','GE adc','units','normalized',...
                        'Fontsize',10, 'position',[0.2 0.975 0.1 0.02], ...
                        'BackgroundColor','r');
            uicontrol('tag','txtimax','style','text','string','All B-Values','units','normalized',...
                        'Fontsize',10,'position',[0.51 0.975 0.1 0.02], ...
                        'BackgroundColor','g');
            uicontrol('tag','txtmap1','style','text','string',this.comName(1,:),'units','normalized',...
                        'Fontsize',10,'position',[0.81 0.975 0.1 0.02], ...
                        'BackgroundColor','g');
%                     
            uicontrol('tag','txtmap2','style','text','string',this.comName(2,:),'units','normalized',...
                        'Fontsize',10, 'position',[0.2 0.5 0.1 0.02], ...
                        'BackgroundColor','g');
                    
            uicontrol('tag','txtmap3','style','text','string',this.comName(3,:),'units','normalized',...
                        'Fontsize',10,'position',[0.51 0.5 0.1 0.02], ...
                        'BackgroundColor','g');
                     
            uicontrol('tag','txtmap3','style','text','string','weighted','units','normalized',...
                        'Fontsize',10,'position',[0.79 0.5 0.06 0.02], ...
                        'BackgroundColor',[0.0 0.8 1.0]);
            % file load info
            this.tl = uicontrol('tag','txtfileinfo','style','text','string','','units','normalized',...
                        'position',[0.18 0.01 0.81 0.05], ...
                        'BackgroundColor','g','visible','off');
        end

        function resizeWindow(this)
            [h,w]=size(this.image);
            f = w/h;
            this.figw = this.figh*this.hwar*f;

            set(this.guifig,'position',[0 0 this.figw this.figh]);
            movegui(this.guifig,'center');
            set(this.guifig,'visible','on');

        end

        function tb=createToolbar(this, fig)
            tb = uitoolbar('parent',fig);

            hpt=[];
            hpt(end+1) = uipushtool(tb,'CData',localLoadIconCData('file_new.png'),...
                         'TooltipString','New ROI',...
                         'ClickedCallback',...
                         @this.newROI);
            hpt(end+1) = uipushtool(tb,'CData',localLoadIconCData('file_open.png'),...
                         'TooltipString','Open ROI',...
                         'ClickedCallback',...
                         @this.openROI);
            hpt(end+1) = uipushtool(tb,'CData',localLoadIconCData('file_save.png'),...
                         'TooltipString','Save ROI',...
                         'ClickedCallback',...
                         @this.saveROI);      

            %---
            hpt(end+1) = uitoggletool(tb,'CData',localLoadIconCData('tool_zoom_in.png'),...
                         'TooltipString','Zoom In',...
                         'ClickedCallback',...
                         'putdowntext(''zoomin'',gcbo)',...
                        'Separator','on');
            hpt(end+1) = uitoggletool(tb,'CData',localLoadIconCData('tool_zoom_out.png'),...
                         'TooltipString','Zoom Out',...
                         'ClickedCallback',...
                         'putdowntext(''zoomout'',gcbo)');
            hpt(end+1) = uitoggletool(tb,'CData',localLoadIconCData('tool_hand.png'),...
                         'TooltipString','Pan',...
                         'ClickedCallback',...
                         'putdowntext(''pan'',gcbo)');
        end
        
    end  % end private methods
end
