function showplus(varargin)
if (ischar(varargin{1}))&&(nargin>1) %%%
            try
                        if (nargout)
                                    [varargout{1:nargout}]=feval(varargin{:});
                        else
                                    feval(varargin{:});
                        end
            catch
                        fprintf('Error in show: %s\n',varargin{1});
                        disp(lasterr);
            end
else
            f=figure('DockControls','off','Resize','on','Color','k','Pointer','crosshair','Toolbar','none','WindowButtonDownFcn','show(''pr'', gcf, gca,1)','WindowButtonUpFcn','show(''re'', gcf, gca,1)','Colormap',gray(256),'WindowScrollWheelFcn',@wh);
%             D=guidata(f);
            D.im=varargin{1};
            D.ia=axes('Parent',f,'Position',[0 0 1 1],'ALimMode','auto','TickDirMode','manual','XTickMode','manual','YTickMode','manual','ZTickMode','manual','XTickLabelMode','manual','YTickLabelMode','manual','ZTickLabelMode','manual','SelectionHighlight','off','Visible','off','DrawMode','fast','YDir','reverse','ClimMode','auto','DataAspectRatioMode','manual','PlotBoxAspectRatioMode','manual','NextPlot','add');
            D.ii=image(D.ia,'EraseMode','normal','CDataMapping','scaled','Clipping','off','SelectionHighlight','off');
            D.x=size(D.im,1);
            D.y=size(D.im,2);
            D.c=1;              % pointer location: 0. yellow-box, 1. image outside, 2. image indide, 3. image boundary, 4. slider           
            set(D.ii,'Cdata',D.im,'Clipping','on');
            set(f,'Units','normalized','OuterPosition',[0.05 0.05 0.9 0.9],'Units','pixels');

            D.b=8;      % size of detailed view
            D.bx=D.x-D.b+1;
            D.by=D.y-D.b+1;

            D.oa=axes('Parent',f,'XLim',[0 D.y+1],'YLim',[0 D.x+1],'YDir','reverse','ALimMode','manual','TickDirMode','manual','XTickMode','manual','YTickMode','manual','ZTickMode','manual','XTickLabelMode','manual','YTickLabelMode','manual','ZTickLabelMode','manual','Visible','off','DrawMode','fast','NextPlot','add','DataAspectRatioMode','manual','PlotBoxAspectRatioMode','manual','BusyAction','cancel','SelectionHighlight','off','Box','off');
            l=get(f,'Position');
            m=l(3)/l(4);
            if D.y/D.x>m
                        n=round((D.y-D.x*m)/2);
                        set(D.ia,'Xlim',[1+n D.y-n],'Ylim',[1 D.x]);
            else
                        n=round((D.x-D.y*l(4)/l(3))/2);
                        set(D.ia,'Xlim',[1 D.y],'Ylim',[1+n D.x-n]);
            end
            set(D.oa,'Position',[0.05 0.05 0.3 0.2],'Units','pixels');
            k=get(D.oa,'Position');
            m=max(k(1),k(2));
            if (0.35*l(3))/(l(4)*0.25)>D.y/D.x
                        set(D.oa,'Position',[m m k(4)*D.y/D.x k(4)],'Units','normalized');
            else
                        set(D.oa,'Position',[m m k(3) k(3)*D.x/D.y],'Units','normalized');
            end
            D.oi=imagesc('Parent',D.oa,'Cdata',D.im,'EraseMode','normal','Clipping','off','SelectionHighlight','off','BusyAction','cancel');
            line('Parent',D.oa,'XData',[1 1 D.y D.y 1],'YData',[1 D.x D.x 1 1],'Color','w','LineWidth',2,'BusyAction','cancel','HitTest','off','SelectionHighlight','off');
            l=get(D.ia,'XLim');
            D.o1=max(l(1),1);
            D.o2=min(l(2),D.y);
            l=get(D.ia,'YLim');
            D.o3=max(l(1),1);
            D.o4=min(l(2),D.x);
            D.ol=line('Parent',D.oa,'XData',[D.o1 D.o1 D.o2 D.o2 D.o1],'YData',[D.o3 D.o4 D.o4 D.o3 D.o3],'Color','y','LineWidth',2,'BusyAction','cancel','HitTest','off','SelectionHighlight','off'); 
            setAllowAxesZoom(zoom(f),D.oa,false);
            setAllowAxesPan(pan(f),D.oa,false);
            hr=rotate3d(f);
            setAllowAxesRotate(hr,D.oa,false);
            setAllowAxesRotate(hr,D.ia,false);
            l=get(f,'Position');
            D.f1=l(3);
            D.f2=l(4);
            set(f,'ResizeFcn',@rs);
            set(f,'WindowButtonMotionFcn',@ho);
            plotedit(f,'hidetoolsmenu');
            guidata(f,D);
end
return;


function wl(f,~,n)
persistent X Y I l h;
D=guidata(f);
p=get(f,'CurrentPoint');
if n
            w=h-l;
            r=w*10^((p(1)-X)/800);
            s=(l+h)/2-(w*(p(2)-Y))/400;
            r=0.5*r;
            l=s-r;
            h=s+r;
            v=[l h];
            set(D.ia,'CLim',v);
            if I
                        I=0;
            end
else
            I=1;
            r=get(D.ia,'CLim');
            h=r(2);
            l=r(1);
end
X=p(1);
Y=p(2);
return;


function pa(f,~,n)
persistent X Y Z
D=guidata(f);
p=get(f,'CurrentPoint');
a=get(D.ia,'XLim');
b=get(D.ia,'YLim');
if n
            x=a-(p(1)-X)/Z;
            y=b+(p(2)-Y)/Z;
            D.o1=max(x(1),1);
            D.o2=min(x(2),D.y);
            D.o3=max(y(1),1);
            D.o4=min(y(2),D.x);
            if (D.o2-D.o1>15)&&(D.o4-D.o3>15)
                        set(D.ia,'XLim',x,'YLim',y);
                        v=[D.o1 D.o1 D.o2 D.o2 D.o1];
                        w=[D.o3 D.o4 D.o4 D.o3 D.o3];
                        set(D.ol,'XData',v,'YData',w);

            end
            guidata(f,D);
else
            Z=min(D.f1/(a(2)-a(1)),D.f2/(b(2)-b(1)));
end
X=p(1);
Y=p(2);
return;


function wh(f,e)
D=guidata(f);
x=get(D.ia,'XLim');
y=get(D.ia,'YLim');
p=(x(1)+x(2))/2;
q=(y(1)+y(2))/2;
if e.VerticalScrollCount>0
            n=(x(2)-x(1))*0.55;
            m=(y(2)-y(1))*0.55;
            a=p-n;
            b=p+n;
            c=q-m;
            d=q+m;
            D.o1=max(a,1);
            D.o2=min(b,D.y);
            D.o3=max(c,1);
            D.o4=min(d,D.x);
            set(D.ia,'XLim',[a b],'YLim',[c d]);
            v=[D.o1 D.o1 D.o2 D.o2 D.o1];
            w=[D.o3 D.o4 D.o4 D.o3 D.o3];
            set(D.ol,'XData',v,'YData',w);
elseif e.VerticalScrollCount<0
            n=(x(2)-x(1))*0.45;
            m=(y(2)-y(1))*0.45;
            a=p-n;
            b=p+n;
            c=q-m;
            d=q+m;
            D.o1=max(a,1);
            D.o2=min(b,D.y);
            D.o3=max(c,1);
            D.o4=min(d,D.x);
            set(D.ia,'XLim',[a b],'YLim',[c d]);
            v=[D.o1 D.o1 D.o2 D.o2 D.o1];
            w=[D.o3 D.o4 D.o4 D.o3 D.o3];
            set(D.ol,'XData',v,'YData',w);
end
guidata(f,D);
return;


function pr(f,a,~)
D = guidata(f);
if D.c
            switch get(f,'SelectionType')
                        case 'normal'
                                    show('pa',gcf,gca,0);
                                    set(f,'WindowButtonMotionFcn','show(''pa'',gcf,gca,1)');
                        case 'alt'
                                    show('wl',gcf,gca,0);
                                    set(f,'WindowButtonMotionFcn','show(''wl'',gcf,gca,1)');
            end
else
            p=get(a,'CurrentPoint');
            x=get(D.ia,'XLim');
            y=get(D.ia,'YLim');
            set(f,'WindowButtonMotionFcn',{@op,[x(1) y(1)]-[p(1,1) p(1,2)]});
end
return;


function ho(f,~)
D=guidata(f);
p=get(D.ia,'CurrentPoint');
x=round(p(1,2));
y=round(p(1,1));
p=get(D.oa,'CurrentPoint');
e=p(1,1);
g=p(1,2);
if (e>D.o1)&&(e<D.o2)&&(g>D.o3)&&(g<D.o4)    
            set(f,'Name','Show 2014');
            if D.c
                        D.c=0;
            end
elseif (x>0)&&(x<D.x)&&(y>0)&&(y<D.y)     
            set(f,'Name',sprintf(['Show 2014         [' num2str(x) ', ' num2str(y) '] = ' num2str(D.im(x,y))]));
            if D.c < 1
                        D.c=1;
            end
else            
            set(f,'Name','Show 2014');
            if D.c < 1
                        D.c=1;
            end
end
guidata(f,D);
return;


function re(f,a,b,c)   
set(f,'WindowButtonMotionFcn',@ho);
return;


function op(f,~,d)
D=guidata(f);
p=get(D.oa,'CurrentPoint');
x=d(1)+p(1,1);
y=d(2)+p(1,2);
l=get(D.ia, 'XLim');
p=l(2)+x-l(1);
l=get(D.ia, 'YLim');
q=l(2)+y-l(1);
D.o1=max(x,1);
D.o2=min(p,D.y);
D.o3=max(y,1);
D.o4=min(q,D.x);
if (D.o2-D.o1>15)&&(D.o4-D.o3>15)
            set(D.ia,'XLim',[x p],'YLim',[y q]);
            v=[D.o1 D.o1 D.o2 D.o2 D.o1];
            w=[D.o3 D.o4 D.o4 D.o3 D.o3];
            set(D.ol,'XData',v,'YData',w);
end
guidata(f,D);
return;


function rs(f,~)
D=guidata(f);
l=get(f,'Position');
D.f1=l(3);
D.f2=l(4);
guidata(f,D);
return;
