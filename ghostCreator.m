function pacmanGhostCreator_Fig = ghostCreator(myFig)

% Pacman Ghost Creator
%
% Programmer:   Markus Petershofen
% Date:         15.04.2017


% create figure
screen_size = get(0,'ScreenSize');                  % get screen size
figure_size = [1200 600];                           % figure-size
limit_left = screen_size(3)/2-figure_size(1)/2;     % figure centered horizontally
limit_down = screen_size(4)/2-figure_size(2)/2;     % figure centered vertically

if nargin == 1
    pacmanGhostCreator_Fig = myFig;
    set(pacmanGhostCreator_Fig,'units','pixels','Position',[limit_left limit_down figure_size(1) figure_size(2)],...  
        'Color','k','Resize','on','MenuBar','none','Visible','on',...
        'NumberTitle','off','Name','Pacman Ghost Creator','doublebuffer','on',...
        'CloseRequestFcn',@(s,e)PacmanCloseFcn1,...
        'WindowButtonMotionFcn',@myMotionFcn,'WindowButtonUpFcn',@myButtonUp);
else
    close all
    pacmanGhostCreator_Fig = figure('units','pixels','Position',[limit_left limit_down figure_size(1) figure_size(2)],...  
        'Color','k','Resize','on','MenuBar','none','Visible','on',...
        'NumberTitle','off','Name','Pacman Ghost Creator','doublebuffer','on',...
        'CloseRequestFcn',@(s,e)PacmanCloseFcn,...
        'WindowButtonMotionFcn',@myMotionFcn,'WindowButtonUpFcn',@myButtonUp);
end

clc

myAxes1 = axes('Units','normalized','Position',[0.3 0.5 0.4 0.4],...                                            
    'XLim',[-2 2],'YLim',[-2 2],'parent',pacmanGhostCreator_Fig);
hold(myAxes1,'on')
axis(myAxes1,'equal','off')

gameData = load('gameData.mat');

allSprites = gameData.gameData.allSprites;
grumpySprites = allSprites.grumpy;

colorPaletteAxes =  axes('Units','normalized','Position',[0.05 0.55 0.2 0.4],...                                            
    'XLim',[-0.1 1.1],'YLim',[-0.1 1.1],'parent',pacmanGhostCreator_Fig);
hold(colorPaletteAxes,'on')
axis(colorPaletteAxes,'off')

ghostAxes(1) =  axes('Units','normalized','Position',[0.05 0.1 0.2 0.4],...                                            
    'XLim',[0 1],'YLim',[0 1],'parent',pacmanGhostCreator_Fig);
hold(ghostAxes(1),'on')
axis(ghostAxes(1),'on')
ghostAxes(2) =  axes('Units','normalized','Position',[0.28 0.1 0.2 0.4],...                                            
    'XLim',[0 1],'YLim',[0 1],'parent',pacmanGhostCreator_Fig);
hold(ghostAxes(2),'on')
axis(ghostAxes(2),'on')
ghostAxes(3) =  axes('Units','normalized','Position',[0.51 0.1 0.2 0.4],...                                            
    'XLim',[0 1],'YLim',[0 1],'parent',pacmanGhostCreator_Fig);
hold(ghostAxes(3),'on')
axis(ghostAxes(3),'on')
ghostAxes(4) =  axes('Units','normalized','Position',[0.74 0.1 0.2 0.4],...                                            
    'XLim',[0 1],'YLim',[0 1],'parent',pacmanGhostCreator_Fig);
hold(ghostAxes(4),'on')
axis(ghostAxes(4),'on')

myColors = cell(8,8);
curColor = 1;
for jj = 1:8
    for ii = 1:8
        myColors{ii,jj} = allSprites.colormap(curColor,:);
        curColor = curColor + 1;
    end
end

colorMatrix = reshape(linspace(1,64,64),8,8);
imagesc(myAxes1,'XData',[0 0.001],'YData',[0.001 0],'CData',colorMatrix,'Visible','on');
colormap(allSprites.colormap)

% colorMatrix(8,1) % white
% colorMatrix(8,2) % red
% colorMatrix(8,3) % magenta
% colorMatrix(8,4) % cyan
% colorMatrix(8,5) % yellow
% colorMatrix(8,6) % blue
% colorMatrix(1,1) % black
% colorMatrix(5,1) % grey

patch([-0.1 -0.1 1.1 1.1],[1.1 -0.1 -0.1 1.1],'w','Parent',colorPaletteAxes)
patch([-0.05 -0.05 1.05 1.05],[1.05 -0.05 -0.05 1.05],'k','Parent',colorPaletteAxes)
colorPicker.plot = gobjects(8,8);
for kk = 1:8
    for mm = 1:8
        colorPicker.plot(kk,mm) = patch([mm/8 mm/8 (mm-1)/8 (mm-1)/8],1-[kk/8 (kk-1)/8 (kk-1)/8 kk/8],myColors{kk,mm},'Parent',colorPaletteAxes,'FaceAlpha',1,'EdgeColor',myColors{kk,mm},'LineWidth',2,'ButtonDownFcn',{@colorPickerFun,kk,mm});
    end
end

colorPicker.text = gobjects(1,4);
colorPicker.nicknames = {'B','P','I','C'};
for kk = 1:4
    colorPicker.text(kk,1) = text((2*(kk+1)-1)/16-0.015,1-(2*8-1)/16+0.015,colorPicker.nicknames{kk},'Color','k','Parent',colorPaletteAxes,'Visible','on','FontSize',14,'horizontalAlignment','Center');
    colorPicker.text(kk,2) = text((2*(kk+1)-1)/16-0.01,1-(2*8-1)/16+0.01,colorPicker.nicknames{kk},'Color','w','Parent',colorPaletteAxes,'Visible','on','FontSize',14,'horizontalAlignment','Center');
end

currentGhost = 1;
ghostBG = uibuttongroup('Visible','on',...
                  'Position',[0.3 0.85 .4 0.1],...
                  'BackgroundColor','k',...
                  'SelectionChangedFcn',@ghostSelection,...
                  'Parent',pacmanGhostCreator_Fig);
uicontrol('Style','radiobutton',...
          'units','normalized',...
          'String','Blinky',...
          'FontSize',16,...
          'BackgroundColor','k',...
          'ForegroundColor','w',...
          'Position',[0.05 0.1 0.2 0.9],...
          'HandleVisibility','off',...
          'Tag','1',...
          'Parent',ghostBG);
uicontrol('Style','radiobutton',...
          'units','normalized',...
          'String','Pinky',...
          'FontSize',16,...
          'BackgroundColor','k',...
          'ForegroundColor','w',...
          'Position',[0.3 0.1 0.2 0.9],...
          'Tag','2',...
          'HandleVisibility','off',...
          'Parent',ghostBG);
uicontrol('Style','radiobutton',...
          'units','normalized',...
          'String','Inky',...
          'FontSize',16,...
          'BackgroundColor','k',...
          'ForegroundColor','w',...
          'Position',[0.55 0.1 0.2 0.9],...
          'HandleVisibility','off',...
          'Tag','3',...
          'Parent',ghostBG);
uicontrol('Style','radiobutton',...
          'units','normalized',...
          'String','Clyde',...
          'FontSize',16,...
          'BackgroundColor','k',...
          'ForegroundColor','w',...
          'Position',[0.8 0.1 0.2 0.9],...
          'HandleVisibility','off',...
          'Tag','4',...
          'Parent',ghostBG);
      
chosenFrameBG = uibuttongroup('Visible','on',...
                  'Position',[0.725 0.76 0.12 0.19],...
                  'BackgroundColor','k',...
                  'SelectionChangedFcn',@chosenFrameSelection,...
                  'Parent',pacmanGhostCreator_Fig);
uicontrol('Style','radiobutton',...
          'units','normalized',...
          'String','Frame 1',...
          'FontSize',16,...
          'BackgroundColor','k',...
          'ForegroundColor','w',...
          'Position',[0.15 0.5 0.9 0.4],...
          'HandleVisibility','off',...
          'Tag','1',...
          'Parent',chosenFrameBG);
uicontrol('Style','radiobutton',...
          'units','normalized',...
          'String','Frame 2',...
          'FontSize',16,...
          'BackgroundColor','k',...
          'ForegroundColor','w',...
          'Position',[0.15 0.1 0.9 0.4],...
          'Tag','2',...
          'HandleVisibility','off',...
          'Parent',chosenFrameBG);     
      
directionFrameBG = uibuttongroup('Visible','on',...
                  'Position',[0.855 0.55 0.12 0.4],...
                  'BackgroundColor','k',...
                  'SelectionChangedFcn',@directionFrameSelection,...
                  'Parent',pacmanGhostCreator_Fig);
uicontrol('Style','radiobutton',...
          'units','normalized',...
          'String','Right',...
          'FontSize',16,...
          'BackgroundColor','k',...
          'ForegroundColor','w',...
          'Position',[0.15 0.825 0.9 0.15],...
          'HandleVisibility','off',...
          'Tag','1',...
          'Parent',directionFrameBG);
uicontrol('Style','radiobutton',...
          'units','normalized',...
          'String','Down',...
          'FontSize',16,...
          'BackgroundColor','k',...
          'ForegroundColor','w',...
          'Position',[0.15 0.625 0.9 0.15],...
          'Tag','2',...
          'HandleVisibility','off',...
          'Parent',directionFrameBG);     
uicontrol('Style','radiobutton',...
          'units','normalized',...
          'String','Left',...
          'FontSize',16,...
          'BackgroundColor','k',...
          'ForegroundColor','w',...
          'Position',[0.15 0.425 0.9 0.15],...
          'HandleVisibility','off',...
          'Tag','3',...
          'Parent',directionFrameBG);
uicontrol('Style','radiobutton',...
          'units','normalized',...
          'String','Up',...
          'FontSize',16,...
          'BackgroundColor','k',...
          'ForegroundColor','w',...
          'Position',[0.15 0.225 0.9 0.15],...
          'Tag','4',...
          'HandleVisibility','off',...
          'Parent',directionFrameBG);  
uicontrol('Style','radiobutton',...
          'units','normalized',...
          'String','Grumpy',...
          'FontSize',16,...
          'BackgroundColor','k',...
          'ForegroundColor','w',...
          'Position',[0.15 0.025 0.9 0.152],...
          'Tag','5',...
          'HandleVisibility','off',...
          'Parent',directionFrameBG);   
      
chosenColorBG = uibuttongroup('Visible','on',...
                  'Position',[0.725 0.55 0.12 0.19],...
                  'BackgroundColor','k',...
                  'SelectionChangedFcn',@chosenColorSelection,...
                  'Parent',pacmanGhostCreator_Fig);
uicontrol('Style','radiobutton',...
          'units','normalized',...
          'String','Body',...
          'FontSize',16,...
          'BackgroundColor','k',...
          'ForegroundColor','w',...
          'Position',[0.15 0.7 0.9 0.2],...
          'HandleVisibility','off',...
          'Tag','1',...
          'Parent',chosenColorBG);
uicontrol('Style','radiobutton',...
          'units','normalized',...
          'String','Eye Ball',...
          'FontSize',16,...
          'BackgroundColor','k',...
          'ForegroundColor','w',...
          'Position',[0.15 0.4 0.9 0.2],...
          'Tag','2',...
          'HandleVisibility','off',...
          'Parent',chosenColorBG);  
uicontrol('Style','radiobutton',...
          'units','normalized',...
          'String','Iris',...
          'FontSize',16,...
          'BackgroundColor','k',...
          'ForegroundColor','w',...
          'Position',[0.15 0.1 0.9 0.2],...
          'Tag','3',...
          'HandleVisibility','off',...
          'Parent',chosenColorBG);  

uicontrol('Style','pushbutton',...
          'units','normalized',...
          'String','Save Data',...
          'FontSize',16,...
          'BackgroundColor','k',...
          'ForegroundColor','w',...
          'Position',[0.74 0.01 0.2 0.06],...
          'Parent',pacmanGhostCreator_Fig,...
          'Callback',@(s,e)SaveDataFun);  
      
uicontrol('Style','pushbutton',...
          'units','normalized',...
          'String','~',...
          'FontSize',16,...
          'BackgroundColor','k',...
          'ForegroundColor','w',...
          'Position',[0.25 0.55 0.025 0.4],...
          'Parent',pacmanGhostCreator_Fig,...
          'Callback',@(s,e)NewColorMapFun);

animationButton = uicontrol('Style','togglebutton',...
          'units','normalized',...
          'String','Animation',...
          'FontSize',16,...
          'BackgroundColor','k',...
          'ForegroundColor','w',...
          'Position',[0.3 0.53 0.4 0.05],...
          'Parent',pacmanGhostCreator_Fig,...
          'Callback',@(s,e)AnimationToggleFun); 
      
ghost.data = allSprites.ghosts;
ghost.data{1,5,1} = grumpySprites{1,1};
ghost.data{1,5,2} = grumpySprites{1,2};
ghost.plot1 = gobjects(1,4);
for ii = 1:4
    [trow, tcol] = find(ghost.data{ii,1,1}>8 & ghost.data{ii,1,1}~=colorMatrix(8,1) & ghost.data{ii,1,1}~=colorMatrix(8,6));
    ghost.curColor(ii) = ghost.data{ii,1,1}(trow(1),tcol(1));
    ghost.plot1(ii) = imagesc(myAxes1,'XData',[-0.8+(ii-1)*2 0.8+(ii-1)*2],'YData',[0.8 -0.8],'CData',ghost.data{ii,1,1});
    [trow, tcol] = find(colorMatrix == ghost.data{ii,1,1}(trow(1),tcol(1)));
    set(colorPicker.text(ii,1),'Position',[(2*tcol-1)/16-0.015,1-(2*trow-1)/16+0.02,0],'Visible','on')
    set(colorPicker.text(ii,2),'Position',[(2*tcol-1)/16-0.01,1-(2*trow-1)/16+0.015,0],'Visible','on')
end

eyes.whiteColor = colorMatrix(8,1);
eyes.pupilColor = colorMatrix(8,6);

curRow = 8;
curCol = 2;

chosenFrame = 1;
chosenDirectionFrame = 1;
chosenBodyEyeIris = 1;

ghost.paintPlot = gobjects(4,14,14);
for ii = 1:4
    for kk = 1:14
        for mm = 1:14
            if ghost.data{ii,chosenDirectionFrame,chosenFrame}(kk,mm) == 1
                ghost.paintPlot(ii,kk,mm) = patch([mm/14 mm/14 (mm-1)/14 (mm-1)/14],1-[kk/14 (kk-1)/14 (kk-1)/14 kk/14],myColors{colorMatrix==ghost.data{ii,chosenDirectionFrame,chosenFrame}(kk,mm)},'Parent',ghostAxes(ii),'ButtonDownFcn',{@paintFun,ii,kk,mm},'FaceAlpha',0.7);
            else
                ghost.paintPlot(ii,kk,mm) = patch([mm/14 mm/14 (mm-1)/14 (mm-1)/14],1-[kk/14 (kk-1)/14 (kk-1)/14 kk/14],myColors{colorMatrix==ghost.data{ii,chosenDirectionFrame,chosenFrame}(kk,mm)},'Parent',ghostAxes(ii),'ButtonDownFcn',{@paintFun,ii,kk,mm},'FaceAlpha',1);
            end
        end
    end
end

loopFlag = 1;
clickedAxes = 0;
animationLoop


    function animationLoop
        while loopFlag && get(animationButton,'Value')
            for rr = currentGhost
                for ss = 1:4
                    for tt = 1:2
                        if ~loopFlag || strcmp(get(pacmanGhostCreator_Fig,'Visible'),'off')
                            break
                        end
                        set(ghost.plot1(rr),'CData',ghost.data{rr,ss,tt});
                        pause(0.1);
                    end
                end
            end
        end
    end

    function paintFun(~,~,myAx,row,col)
        clickedAxes = myAx;
        switch pacmanGhostCreator_Fig.SelectionType
            case 'normal'
                if chosenDirectionFrame <= 4
                    switch chosenBodyEyeIris
                        case 1
                            paintColor = ghost.curColor(myAx);
                        case 2
                            paintColor = colorMatrix(8,1);
                        case 3
                            paintColor = colorMatrix(8,6);
                    end
                    set(ghost.paintPlot(myAx,row,col),'FaceColor',myColors{colorMatrix==paintColor},'FaceAlpha',1)
                    ghost.data{myAx,chosenDirectionFrame,chosenFrame}(row,col) = paintColor;
                else
                    switch chosenBodyEyeIris
                        case 1
                            paintColor = colorMatrix(8,6);
                        otherwise
                            paintColor = colorMatrix(5,1);
                    end
                    for ss = 1:4
                        set(ghost.paintPlot(ss,row,col),'FaceColor',myColors{colorMatrix==paintColor},'FaceAlpha',1)
                    end
                    ghost.data{1,chosenDirectionFrame,chosenFrame}(row,col) = paintColor;
                end
            case 'alt'
                if chosenDirectionFrame <= 5
                    set(ghost.paintPlot(myAx,row,col),'FaceColor',myColors{1,1},'FaceAlpha',0.7)
                    ghost.data{myAx,chosenDirectionFrame,chosenFrame}(row,col) = 1;
                end
        end
        refreshAllPlots
    end

    function refreshAllPlots
        if chosenDirectionFrame <= 4
            for rr = 1:4
                for ss = 1:14
                    for tt = 1:14
                        if ghost.data{rr,chosenDirectionFrame,chosenFrame}(ss,tt) == 1
                            set(ghost.paintPlot(rr,ss,tt),'FaceColor',myColors{colorMatrix==ghost.data{rr,chosenDirectionFrame,chosenFrame}(ss,tt)},'FaceAlpha',0.7)
                        else
                            set(ghost.paintPlot(rr,ss,tt),'FaceColor',myColors{colorMatrix==ghost.data{rr,chosenDirectionFrame,chosenFrame}(ss,tt)},'FaceAlpha',1)
                        end
                    end
                end
                set(ghost.plot1(rr),'CData',ghost.data{rr,chosenDirectionFrame,chosenFrame})
            end
        else
            for rr = 1:4
                for ss = 1:14
                    for tt = 1:14
                        if ghost.data{1,chosenDirectionFrame,chosenFrame}(ss,tt) == 1
                            set(ghost.paintPlot(rr,ss,tt),'FaceColor',myColors{colorMatrix==ghost.data{1,chosenDirectionFrame,chosenFrame}(ss,tt)},'FaceAlpha',0.7)
                        else
                            set(ghost.paintPlot(rr,ss,tt),'FaceColor',myColors{colorMatrix==ghost.data{1,chosenDirectionFrame,chosenFrame}(ss,tt)},'FaceAlpha',1)
                        end
                    end
                end
                set(ghost.plot1(rr),'CData',ghost.data{1,chosenDirectionFrame,chosenFrame})
            end
        end
    end

    function ghostSelection(src,~)
        currentGhost = str2double(src.SelectedObject.Tag);
        loopFlag = 0;
        refreshAllPlots
        if chosenDirectionFrame <= 4
            loopFlag = 1;
        end
        animationLoop
    end

    function chosenFrameSelection(src,~)
        chosenFrame = str2double(src.SelectedObject.Tag);
        refreshAllPlots
    end

    function directionFrameSelection(src,~)
        chosenDirectionFrame = str2double(src.SelectedObject.Tag);
        loopFlag = 0;
        refreshAllPlots
        if chosenDirectionFrame < 5
            loopFlag = 1;
            animationLoop
        end
    end

    function chosenColorSelection(src,~)
        chosenBodyEyeIris = str2double(src.SelectedObject.Tag);
    end
        
    function colorPickerFun(~,~,row,col)
        nonSelectedGhosts = 1:4;
        nonSelectedGhosts(nonSelectedGhosts==currentGhost) = [];
        if colorMatrix(row,col) ~= eyes.whiteColor && colorMatrix(row,col) ~= eyes.pupilColor && colorMatrix(row,col) ~= colorMatrix(1,1) && colorMatrix(row,col) ~= ghost.curColor(nonSelectedGhosts(1)) && colorMatrix(row,col) ~= ghost.curColor(nonSelectedGhosts(2)) && colorMatrix(row,col) ~= ghost.curColor(nonSelectedGhosts(3))
            curRow = row;
            curCol = col;
            set(colorPicker.text(currentGhost,1),'Position',[(2*col-1)/16-0.015,1-(2*row-1)/16+0.02,0],'Visible','on')
            set(colorPicker.text(currentGhost,2),'Position',[(2*col-1)/16-0.01,1-(2*row-1)/16+0.015,0],'Visible','on')
            
            for rr = 1:4
               for ss = 1:2
                   ghost.data{currentGhost,rr,ss}(ghost.data{currentGhost,rr,ss}==ghost.curColor(currentGhost)) = colorMatrix(curRow,curCol);
               end
            end
            refreshAllPlots
            ghost.curColor(currentGhost) = colorMatrix(curRow,curCol);
        end
    end

    function myMotionFcn(~,~)
        if clickedAxes > 0            
            curCoord = ghostAxes(clickedAxes).CurrentPoint(1,1:2);
            curX = ceil(curCoord(1)*14);            % current col
            curY = 14-ceil(curCoord(2)*14)+1;       % current row
            if curX > 0 && curX <= 14 && curY > 0 && curY <= 14
                switch pacmanGhostCreator_Fig.SelectionType
                    case 'normal'
                        if chosenDirectionFrame <= 4
                            switch chosenBodyEyeIris
                                case 1
                                    paintColor = ghost.curColor(clickedAxes);
                                case 2
                                    paintColor = colorMatrix(8,1);
                                case 3
                                    paintColor = colorMatrix(8,6);
                            end
                            set(ghost.paintPlot(clickedAxes,curY,curX),'FaceColor',myColors{colorMatrix==paintColor},'FaceAlpha',1)
                            ghost.data{clickedAxes,chosenDirectionFrame,chosenFrame}(curY,curX) = paintColor;
                        else
                            switch chosenBodyEyeIris
                                case 1
                                    paintColor = colorMatrix(8,6);
                                otherwise
                                    paintColor = colorMatrix(5,1);
                            end
                            for ss = 1:4
                                set(ghost.paintPlot(ss,curY,curX),'FaceColor',myColors{colorMatrix==paintColor},'FaceAlpha',1)
                            end
                            ghost.data{1,chosenDirectionFrame,chosenFrame}(curY,curX) = paintColor;
                        end
                    case 'alt'
                        if chosenDirectionFrame <= 5
                            set(ghost.paintPlot(clickedAxes,curY,curX),'FaceColor',myColors{1,1},'FaceAlpha',0.7)
                            ghost.data{clickedAxes,chosenDirectionFrame,chosenFrame}(curY,curX) = 1;
                        end
                end
            end
        end
    end


    function myButtonUp(~,~)
        clickedAxes = 0;
        refreshAllPlots
    end

    function PacmanCloseFcn1
        loopFlag = 0;
        set(pacmanGhostCreator_Fig,'Visible','off')
    end

    function PacmanCloseFcn
        loopFlag = 0;
        delete(pacmanGhostCreator_Fig)
    end

    function NewColorMapFun
        curColor = 1;
        for ss = 1:8
            for rr = 1:8
                if rr < 8 && ss > 1
                    allSprites.colormap(curColor,:) = [rand rand rand];
                    myColors{rr,ss} = allSprites.colormap(curColor,:);
                    set(colorPicker.plot(rr,ss),'FaceColor',myColors{rr,ss},'EdgeColor',myColors{rr,ss})
                end
                curColor = curColor + 1;
            end
        end
        colormap(allSprites.colormap)
        
        refreshAllPlots
    end

    function AnimationToggleFun
        if get(animationButton,'Value')
            animationLoop
        end
    end

    function SaveDataFun
        % save ghosts
        gameData.gameData.allSprites.colormap = cell2mat(reshape(myColors,64,1));
        gameData.gameData.allSprites.ghosts = ghost.data;
        % save grumpies
        gameData.gameData.allSprites.grumpy{1,1} = ghost.data{1,5,1};
        gameData.gameData.allSprites.grumpy{1,2} = ghost.data{1,5,2};
        grumpy21 = gameData.gameData.allSprites.grumpy{1,1};
        grumpy22 = gameData.gameData.allSprites.grumpy{1,2};
        grumpy21(grumpy21==colorMatrix(8,6)) = colorMatrix(8,1);
        grumpy22(grumpy22==colorMatrix(8,6)) = colorMatrix(8,1);
        grumpy21(grumpy21==colorMatrix(5,1)) = colorMatrix(8,2);
        grumpy22(grumpy22==colorMatrix(5,1)) = colorMatrix(8,2);
        gameData.gameData.allSprites.grumpy{2,1} = grumpy21;
        gameData.gameData.allSprites.grumpy{2,2} = grumpy22;
        
        % save eyes
        for rr = 1:4
            for ss = 1:4
                eyes1 = gameData.gameData.allSprites.ghosts{rr,ss,1};
                eyeWhite = eyes1==colorMatrix(8,1);
                eyeBlue = eyes1==colorMatrix(8,6);
                eyes1(~(eyeWhite+eyeBlue)) = 1;
                gameData.gameData.allSprites.eyes{rr,ss} = eyes1;
            end
        end
               
        gameData = gameData.gameData;
        uisave('gameData','myOwnGameData')
    end

end