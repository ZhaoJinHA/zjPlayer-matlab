
function zjPlayer_script
captureDir = 'D:\Experiment_data\'; % change to the target dir
frameRate = 25; % chang to any value you like.

fH = figure('name','zjPlayer1.0','NumberTitle','off','KeyPressFcn', @keypressfcn1,'Interruptible','off','color','k', ...
    'BusyAction','cancel','Resize','on','Units', 'Norm',...
    'WindowButtonDownFcn',@WBDF, 'WindowButtonUpFcn', @WBUF,...
    'WindowButtonMotionFcn',@WBMF);
barHeightNorm = .03;
barWidthNorm = .1;
videoAxes = axes('Parent', fH, 'fontname', 'a','Units', 'norm',...
    'Position', [0, barHeightNorm, 1, 1 - barHeightNorm - .05]);
barAxes = axes('Parent', fH, 'Position', [0, 0, 1, barHeightNorm] ,'xlim',[0 1], 'ylim', [0 1],'visible', 'on');
axis off
barH = patch('Parent', barAxes, 'xdata', [0 0 barWidthNorm barWidthNorm] , 'ydata', [0 1 1 0],...
    'edgecolor' ,'none','facecolor', [.8 .28 0]);

captureList = get_subfilepath(fullfile(captureDir,'*.jpg'));
fH.CurrentAxes = videoAxes;
im = imread(captureList{1});
imH = imshow(im,'Parent', videoAxes);
%  text(.9,1,sprintf('fps%03d', frameRate),'color','red','fontname',...
%     'microsoft uighur','Parent', fH,'Units','norm');
imSize = size(im)

textH = annotation(fH,'textbox',...
    [.8 .9 .2 .1],...
    'String',sprintf('fps: %03d', frameRate),...
    'FitBoxToText','on','color',[.85 .33 .1],'fontname',...
    'microsoft uighur','Units','norm','fontsize',16,...
    'linestyle','none');
titleH = title('start','parent',videoAxes, 'fontname', 'microsoft uighur','fontsize',16,'color',[.47 .67 .19]);
if imSize(1)<1080 && imSize(2)<1920, truesize, end
frameNum = numel(captureList);

click = 0;
iFrame = 0;


playTimer = timer('TimerFcn', @timefcn1, 'Period',1/frameRate, 'ExecutionMode','fixedrate');



start(playTimer);

    function timefcn1(~, ~)
        if iFrame < frameNum
            iFrame = iFrame + 1;
            refreshFrame(iFrame);
            %             pause(0.001)
        else
            stop(playTimer)
        end
    end
    function refreshFrame(newFrame)
        if newFrame < 1; newFrame = 1;   end
        if newFrame > frameNum; newFrame = frameNum;   end
        barH.XData = [-barWidthNorm/2 -barWidthNorm/2 barWidthNorm/2 barWidthNorm/2] + newFrame/frameNum;
        refreshImg(newFrame)
%         curpoint = fH.CurrentPoint;
        %         title(sprintf('frame %04d click %d curpoint %f %f',newFrame,
        %         click, curpoint(1), curpoint(2)),'parent',videoAxes)  %for test
%         title(sprintf('frame %04d',newFrame),'parent',videoAxes, 'fontname', 'microsoft uighur','fontsize',16)
        titleH.String = sprintf('frame %04d',newFrame);
%         pause(.0001)
        %         drawnow;
    end
    function refreshImg(newFrame)
        
        img = imread(captureList{newFrame});
        imH.CData = img;
%         videoAxes.CData = img;
%         imshow(img, 'Parent', videoAxes)
    end
    function WBDF(~, ~)
        curPoint = fH.CurrentPoint;
        if curPoint(2) < barHeightNorm
            click = 1;
            iFrame = floor(frameNum * curPoint(1));
            refreshFrame(iFrame)
        else
            click = 0;
        end
        
    end

    function WBUF(~,~)
        click = 0;
    end
    function WBMF(~,~)
        
        if click == 0; return; end
        fH.Units = 'norm';
        curPoint = fH.CurrentPoint;
        
        barH.XData = [0 0 barWidthNorm barWidthNorm] + curPoint(1);
        iFrame = floor(frameNum * curPoint(1));
        refreshFrame(iFrame)
    end
    function keypressfcn1(~, event)
        switch event.Key
            case 'rightarrow'
                iFrame = iFrame+10;
                refreshFrame(iFrame);
                disp('====> + 10 frames');
            case 'leftarrow'
                iFrame = iFrame - 10;
                refreshFrame(iFrame);
                disp('<==== - 10 frames');
            case 'downarrow'
                iFrame = iFrame+1;
                refreshFrame(iFrame);
                disp('==> + 01 frames');
            case 'uparrow'
                iFrame = iFrame - 1;
                refreshFrame(iFrame);
                disp('<== - 01 frames');
            case 'space'
                if strcmp(get(playTimer,'running'), 'on')
                    disp('pause');
                    refreshFrame(iFrame);
                    stop(playTimer);
                elseif strcmp(get(playTimer,'running'), 'off')
                    disp('resume');
                    start(playTimer)
                end
            case 'q'
                stop(playTimer)
                disp('quit')
                close(fH)
            case 'home'
                disp('ahead')
                iFrame = 1;
                refreshFrame(iFrame)
            case 'end'
                disp('end')
                iFrame = frameNum;
                refreshFrame(iFrame);
        end
    end
end

