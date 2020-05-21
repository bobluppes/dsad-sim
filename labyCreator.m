function labyCreator(myFigLaby) % pacmanLabyCreator_Fig = 

% Pacman Labyrinth Creator
%
% Programmer:   Markus Petershofen
% Date:         07.05.2017

clc

% create figure
screen_size = get(0,'ScreenSize');                  % get screen size
figure_size = [650 650];                            % figure-size
limit_left = screen_size(3)/2-figure_size(1)/2;     % figure centered horizontally
limit_down = screen_size(4)/2-figure_size(2)/2;     % figure centered vertically

if nargin == 1
    pacmanLabyCreator_Fig = myFigLaby;
    set(pacmanLabyCreator_Fig,'units','pixels','Position',[limit_left limit_down figure_size(1) figure_size(2)],...  
        'Color','k','Resize','on','MenuBar','none','Visible','on',...
        'NumberTitle','off','Name','Pacman Labyrinth Creator','doublebuffer','on',...
        'WindowButtonDownFcn',@(s,e)ButtonDownFun,...
        'WindowButtonUpFcn',@(s,e)ButtonUpFun,...
        'WindowButtonMotionFcn',@(s,e)ButtonMotionFun,...
        'CloseRequestFcn',@(s,e)PacmanCloseFcn1);
else
    close all
    pacmanLabyCreator_Fig = figure('units','pixels','Position',[limit_left limit_down figure_size(1) figure_size(2)],...  
        'Color','k','Resize','on','MenuBar','none','Visible','on',...
        'NumberTitle','off','Name','Pacman Labyrinth Creator','doublebuffer','on',...
        'WindowButtonDownFcn',@(s,e)ButtonDownFun,...
        'WindowButtonUpFcn',@(s,e)ButtonUpFun,...
        'WindowButtonMotionFcn',@(s,e)ButtonMotionFun,...
        'CloseRequestFcn',@(s,e)PacmanCloseFcn);
end

gameData = load('gameData.mat');

gameBoardSize = [31 34];
gameBoard = zeros(gameBoardSize(1),gameBoardSize(2));

myAxes1Pac = axes('Units','normalized','Position',[0.1 0.1 0.8 0.8],...                                            
    'XLim',[0 gameBoardSize(1)-1],'YLim',[-0.01 gameBoardSize(2)-1],'Parent',pacmanLabyCreator_Fig); 
hold(myAxes1Pac,'on')
axis(myAxes1Pac,'off','equal')

buttonDownFlag = 0;

gridXY = zeros(30*33,2);
tt = 1;
for hh = 1:30
    for ff = 1:33
        gridXY(tt,:) = [hh ff];
        tt = tt+1;
    end
end
plot(myAxes1Pac,gridXY(:,1),gridXY(:,2),'r.','ButtonDownFcn',@(s,e)ButtonDownFun,'MarkerSize',5); % grid plot

tt = 1;
for hh = 2:29
    for ff = 2:32
        coins.data(tt,:) = [hh ff];
        tt = tt+1;
    end
end
current_wall = [12 19 19 12 12; 16 16 20 20 16]';
coins.data(inpolygon(coins.data(:,1),coins.data(:,2),current_wall(:,1),current_wall(:,2)),:) = [];
coins.plot = plot(myAxes1Pac,coins.data(:,1),coins.data(:,2),'wo','LineWidth',1,'MarkerSize',1.5,'MarkerFaceColor','w','ButtonDownFcn',@(s,e)ButtonDownFun);

test1WallsPlot = plot(myAxes1Pac,0,0,'b-','LineWidth',2,'ButtonDownFcn',@(s,e)ButtonDownFun);    % plot all walls
% cage plot
plot(myAxes1Pac,[12 19 19 17 17 18.5 18.5 12.5 12.5 14 14 12 12],[16 16 20 20 19.5 19.5 16.5 16.5 19.5 19.5 20 20 16],'b-','LineWidth',2,'ButtonDownFcn',@(s,e)ButtonDownFun);    % plot cage
% door plot
plot(myAxes1Pac,[14 17],[19.75 19.75],'w-','LineWidth',3);

lastEntry = [-1 -1];
wallsMat = [];

wallTypeBG = uibuttongroup('Visible','on',...
                  'Position',[0.16 0.925 0.4 0.05],...
                  'SelectionChangedFcn',@wallTypeSelection,...
                  'Parent',pacmanLabyCreator_Fig);
uicontrol('Style','radiobutton',...
          'units','normalized',...
          'String','pills',...
          'Position',[0.8 0.1 0.15 0.9],...
          'HandleVisibility','off',...
          'Tag','2',...
          'Parent',wallTypeBG);
uicontrol('Style','radiobutton',...
          'units','normalized',...
          'String','pseudo wall',...
          'Position',[0.4 0.1 0.35 0.9],...
          'Tag','0',...
          'HandleVisibility','off',...
          'Parent',wallTypeBG);
uicontrol('Style','radiobutton',...
          'units','normalized',...
          'String','normal wall',...
          'Position',[0.05 0.1 0.35 0.9],...
          'HandleVisibility','off',...
          'Tag','1',...
          'Value',1,...
          'Parent',wallTypeBG);
uicontrol('Style', 'pushbutton', 'String', 'Clear pseudo wall',...
        'units','normalized','Position', [0.7 0.925 0.17 0.05],...
        'Callback', @(s,e)clearPseudoWallFun);
currentWallType = 1;
pseudoWallCell = cell(1,1); 
pseudoWall = [];
pseudoWall1 = [];
pseudoWall2 = [];
pseudoWallPlot = plot(0,0,'y-','LineWidth',1);
pseudoWallPlotKeep = plot(0,0,'y-','LineWidth',1);

saveButton = uicontrol('Style', 'pushbutton', 'String', 'Save',...
        'units','normalized','Position', [0.15 0.05 0.13 0.05],...
        'Enable','off',...
        'Callback', @(s,e)saveFun);  
uicontrol('Style', 'pushbutton', 'String', 'Clear',...
        'units','normalized','Position', [0.31 0.05 0.13 0.05],...
        'Callback', @(s,e)clearFun);  
uicontrol('Style', 'pushbutton', 'String', 'Validate',...
        'units','normalized','Position', [0.47 0.05 0.13 0.05],...
        'Callback', @(s,e)validateFun);       
    
validateAxes = axes('Units','normalized','Position',[0.63 0.05 0.22 0.05],...                                            
    'XLim',[0 1],'YLim',[0 1],'Parent',pacmanLabyCreator_Fig); 
hold(validateAxes,'on')
axis(validateAxes,'off')

validate.boxPlot = plot(validateAxes,[0 0 1 1 0],[0 1 1 0 0],'w-','LineWidth',2);
validate.progressPlot = patch([0 0 0 0 0],[0 1 1 0 0],'w','EdgeColor','w','Parent',validateAxes);
validate.text = text(1.2,0.5,'0%','Color','w','FontSize',12,'FontUnits','normalized','HorizontalAlignment','center','Parent',validateAxes);

pills.data = [2 8; 2 28; 27 8; 27 28]+1;  % pills-positions
pills.form = [sin(linspace(0,2*pi,10)); cos(linspace(0,2*pi,10))]/2; % make 'em pills nice and round
pills.plot = gobjects(1,4);
for kk = 1:4
    pills.plot(kk) = patch(pills.data(kk,1)+pills.form(1,:),pills.data(kk,2)++pills.form(2,:),'w','ButtonDownFcn',{@pillsButtonDownFun,kk},'Parent',myAxes1Pac);
end
pills.flag = 0;

pacmanWalls = [];
pacmanCoins = [];

% gameBoard = zeros(gameBoardSize(1),gameBoardSize(2));
% gameBoard(2:end-1,2:end-1) = rand(gameBoardSize(1)-2,gameBoardSize(2)-2)>0.5;
gameBoard = pacBoard;
makeMaze(gameBoard)

    function PacmanCloseFcn1
        set(pacmanLabyCreator_Fig,'Visible','off')
    end

    function PacmanCloseFcn
        delete(pacmanLabyCreator_Fig)
    end

    function ButtonDownFun
        set(saveButton ,'Enable','off')
        plotProgress(0)
        buttonDownFlag = 1;
        if ~currentWallType
            pseudoWall1 = round(myAxes1Pac.CurrentPoint(1,1:2));
        end
        ButtonMotionFun
    end

    function ButtonUpFun
        pills.flag = 0;

        buttonDownFlag = 0;
        lastEntry = [-1 -1];
        gameBoard(11:21,15:22) = 0;
        gameBoard(15:17,9:10) = 0;

        if ~currentWallType 
            pseudoWall2 = round(myAxes1Pac.CurrentPoint(1,1:2));
            pseudoWallCell{end+1} = [pseudoWall1(1) pseudoWall1(1) pseudoWall2(1) pseudoWall2(1) pseudoWall1(1);...
                                 pseudoWall1(2) pseudoWall2(2) pseudoWall2(2) pseudoWall1(2) pseudoWall1(2)]';
            pseudoWall(1:2,end+1:end+6) = [NaN pseudoWall1(1) pseudoWall1(1) pseudoWall2(1) pseudoWall2(1) pseudoWall1(1);...
                                           NaN pseudoWall1(2) pseudoWall2(2) pseudoWall2(2) pseudoWall1(2) pseudoWall1(2)];
            set(pseudoWallPlotKeep,'XData',pseudoWall(1,:),'YData',pseudoWall(2,:))
        end
        makeMaze(gameBoard)
    end

    function plotProgress(progress)
        set(validate.progressPlot,'XData',[0 0 progress progress 0])
        set(validate.text,'String',[num2str(progress*100,3) '%'])
        pause(0.001)
    end

    function ButtonMotionFun
        currentPoint = ceil(myAxes1Pac.CurrentPoint(1,1:2));
        
        if currentWallType == 2
            if  pills.flag > 0 && currentPoint(1) > 1 && currentPoint(1) < 30 && currentPoint(2) > 1 && currentPoint(2) < 33
                pills.data(pills.flag,:) = currentPoint;
                set(pills.plot(pills.flag),'XData',currentPoint(1)+pills.form(1,:),'YData',currentPoint(2)++pills.form(2,:))
            end
        else
            if buttonDownFlag && currentPoint(1) > 1 && currentPoint(1) <= gameBoardSize(1)-1 && currentPoint(2) > 1 && currentPoint(2) <= gameBoardSize(2)-1
                if currentWallType == 1
                    switch pacmanLabyCreator_Fig.SelectionType
                        case 'normal'
                            gameBoard(currentPoint(1), currentPoint(2)) = 1;
                            connectFast(currentPoint,1)
                            makeMaze(gameBoard)
                        case 'alt'
                            gameBoard(currentPoint(1), currentPoint(2)) = 0;
                            connectFast(currentPoint,0)
                            makeMaze(gameBoard)
                    end
                    lastEntry = ceil(currentPoint);
                elseif currentWallType == 0
                    pseudoWall2 = round(myAxes1Pac.CurrentPoint(1,1:2));
                    set(pseudoWallPlot,'XData',[pseudoWall1(1) pseudoWall1(1) pseudoWall2(1) pseudoWall2(1) pseudoWall1(1)],...
                                       'YData',[pseudoWall1(2) pseudoWall2(2) pseudoWall2(2) pseudoWall1(2) pseudoWall1(2)])
                end
            end
        end
    end

    function connectFast(currentPoint,newDelFlag)
        if lastEntry(1) > -1 
            if lastEntry(1) > currentPoint(1)+1 
                gameBoard(currentPoint(1)+1:lastEntry(1), currentPoint(2)) = newDelFlag;
                if lastEntry(2) > currentPoint(2)+1
                    gameBoard(lastEntry(1), currentPoint(2)+1:lastEntry(2)) = newDelFlag;
                elseif lastEntry(2) < currentPoint(2)-1
                    gameBoard(lastEntry(1), lastEntry(2):currentPoint(2)-1) = newDelFlag;
                end
            elseif lastEntry(1) < currentPoint(1)-1 
                gameBoard(lastEntry(1):currentPoint(1)-1, currentPoint(2)) = newDelFlag;
                if lastEntry(2) > currentPoint(2)+1
                    gameBoard(lastEntry(1), currentPoint(2)+1:lastEntry(2)) = newDelFlag;
                elseif lastEntry(2) < currentPoint(2)-1
                    gameBoard(lastEntry(1), lastEntry(2):currentPoint(2)-1) = newDelFlag;
                end
            elseif lastEntry(2) > currentPoint(2)+1
                gameBoard(currentPoint(1), currentPoint(2)+1:lastEntry(2)) = newDelFlag;
                if lastEntry(1) > currentPoint(1)+1
                    gameBoard(currentPoint(1)+1:lastEntry(1), lastEntry(2)) = newDelFlag;
                elseif lastEntry(1) < currentPoint(1)-1
                    gameBoard(lastEntry(1):(1)-1, lastEntry(2)) = newDelFlag;
                end
            elseif lastEntry(2) < currentPoint(2)-1
                gameBoard(currentPoint(1), lastEntry(2):currentPoint(2)-1) = newDelFlag;
                if lastEntry(1) > currentPoint(1)+1
                    gameBoard(currentPoint(1)+1:lastEntry(1), lastEntry(2)) = newDelFlag;
                elseif lastEntry(1) < currentPoint(1)-1
                    gameBoard(lastEntry(1):currentPoint(1)-1, lastEntry(2)) = newDelFlag;
                end
            end
        end
    end
    function makeMaze(curBoard)
        wallsMat = [];
        for ii = 1:length(curBoard(:,1))
            for jj = 1:length(curBoard(1,:))
                if curBoard(ii,jj) && ~curBoard(ii,jj+1) && ~curBoard(ii,jj-1) && ~curBoard(ii+1,jj) && ~curBoard(ii-1,jj)
                    wallsMat(end+1:end+6,1:2) = [ii-1 jj;...
                        ii-1 jj-1;...
                        ii jj-1;...
                        ii jj;...
                        ii-1 jj;...
                        NaN NaN];
                elseif curBoard(ii,jj) && curBoard(ii,jj+1) && ~curBoard(ii,jj-1) && ~curBoard(ii+1,jj) && ~curBoard(ii-1,jj)
                    wallsMat(end+1:end+5,1:2) = [ii-1 jj;...
                        ii-1 jj-1;...
                        ii jj-1;...
                        ii jj;...
                        NaN NaN];
                elseif curBoard(ii,jj) && ~curBoard(ii,jj+1) && curBoard(ii,jj-1) && ~curBoard(ii+1,jj) && ~curBoard(ii-1,jj)
                    wallsMat(end+1:end+5,1:2) = [ii jj-1;...
                        ii jj;...
                        ii-1 jj;...
                        ii-1 jj-1;...
                        NaN NaN];
                elseif curBoard(ii,jj) && curBoard(ii,jj+1) && curBoard(ii,jj-1) && ~curBoard(ii+1,jj) && ~curBoard(ii-1,jj)
                    wallsMat(end+1:end+6,1:2) = [ii jj-1;...
                        ii jj;...
                        NaN NaN;...
                        ii-1 jj;...
                        ii-1 jj-1;...
                        NaN NaN];
                elseif curBoard(ii,jj) && ~curBoard(ii,jj+1) && ~curBoard(ii,jj-1) && ~curBoard(ii+1,jj) && curBoard(ii-1,jj)
                    wallsMat(end+1:end+5,1:2) = [ii-1 jj;...
                        ii jj;...
                        ii jj-1;...
                        ii-1 jj-1;...
                        NaN NaN];
                elseif curBoard(ii,jj) && ~curBoard(ii,jj+1) && ~curBoard(ii,jj-1) && curBoard(ii+1,jj) && ~curBoard(ii-1,jj)
                    wallsMat(end+1:end+5,1:2) = [ii jj-1;...
                        ii-1 jj-1;...
                        ii-1 jj;...
                        ii jj;...
                        NaN NaN];
                elseif curBoard(ii,jj) && ~curBoard(ii,jj+1) && ~curBoard(ii,jj-1) && curBoard(ii+1,jj) && curBoard(ii-1,jj)
                    wallsMat(end+1:end+6,1:2) = [ii-1 jj;...
                        ii jj;...
                        NaN NaN;...
                        ii jj-1;...
                        ii-1 jj-1;...
                        NaN NaN];
                elseif curBoard(ii,jj) && curBoard(ii,jj+1) && ~curBoard(ii,jj-1) && curBoard(ii+1,jj) && ~curBoard(ii-1,jj)
                    wallsMat(end+1:end+4,1:2) = [ii jj-1;...
                        ii-1 jj-1;...
                        ii-1 jj;...
                        NaN NaN];
                elseif curBoard(ii,jj) && ~curBoard(ii,jj+1) && curBoard(ii,jj-1) && ~curBoard(ii+1,jj) && curBoard(ii-1,jj)
                    wallsMat(end+1:end+4,1:2) = [ii jj-1;...
                        ii jj;...
                        ii-1 jj;...
                        NaN NaN];
                elseif curBoard(ii,jj) && ~curBoard(ii,jj+1) && curBoard(ii,jj-1) && curBoard(ii+1,jj) && ~curBoard(ii-1,jj)
                    wallsMat(end+1:end+4,1:2) = [ii jj;...
                        ii-1 jj;...
                        ii-1 jj-1;...
                        NaN NaN];
                elseif curBoard(ii,jj) && curBoard(ii,jj+1) && ~curBoard(ii,jj-1) && ~curBoard(ii+1,jj) && curBoard(ii-1,jj)
                    wallsMat(end+1:end+4,1:2) = [ii jj;...
                        ii jj-1;...
                        ii-1 jj-1;...
                        NaN NaN];
                elseif curBoard(ii,jj) && ~curBoard(ii,jj+1) && curBoard(ii,jj-1) && curBoard(ii+1,jj) && curBoard(ii-1,jj)
                    wallsMat(end+1:end+3,1:2) = [ii-1 jj;...
                        ii jj;...
                        NaN NaN];
                elseif curBoard(ii,jj) && curBoard(ii,jj+1) && ~curBoard(ii,jj-1) && curBoard(ii+1,jj) && curBoard(ii-1,jj)
                    wallsMat(end+1:end+3,1:2) = [ii-1 jj-1;...
                        ii jj-1;...
                        NaN NaN];
                elseif curBoard(ii,jj) && curBoard(ii,jj+1) && curBoard(ii,jj-1) && curBoard(ii+1,jj) && ~curBoard(ii-1,jj)
                    wallsMat(end+1:end+3,1:2) = [ii-1 jj-1;...
                        ii-1 jj;...
                        NaN NaN];
                elseif curBoard(ii,jj) && curBoard(ii,jj+1) && curBoard(ii,jj-1) && ~curBoard(ii+1,jj) && curBoard(ii-1,jj)
                    wallsMat(end+1:end+3,1:2) = [ii jj-1;...
                        ii jj;...
                        NaN NaN];
                end
            end
        end
        if ~isempty(wallsMat)
            set(test1WallsPlot,'XData',wallsMat(:,1),'YData',wallsMat(:,2))
        else
            set(test1WallsPlot,'XData',0,'YData',0)
        end
    end

    function validateFun
        niceMazeFormat = connectMaze(wallsMat);
        set(test1WallsPlot,'XData',niceMazeFormat(:,1),'YData',niceMazeFormat(:,2))
    end

    function clearFun
        gameBoard = zeros(gameBoardSize(1),gameBoardSize(2));
        makeMaze(gameBoard)
    end

    function clearPseudoWallFun
        pseudoWallCell = cell(1,1); 
        pseudoWall = [];
        pseudoWall1 = [];
        pseudoWall2 = [];
        set(pseudoWallPlot,'XData',0,'YData',0)
        set(pseudoWallPlotKeep,'XData',0,'YData',0)
    end

    function niceMazeFormat = connectMaze(mazeData)
        if isempty(mazeData)
            niceMazeFormat = [0,0];
            return
        end
        
        validate.progress = 0;
        mazeCell = cell(1,1);
        curRow = 1;
        curCell = 1;
        isNAN = 0;
        while curRow < length(mazeData(:,1))
            if ~isnan(mazeData(curRow+isNAN,1))
                isNAN = isNAN+1;
            else
                mazeCell{curCell} = mazeData(curRow:curRow+isNAN-1,:);
                curCell = curCell+1;
                curRow = curRow+isNAN+1;
                isNAN = 0;
            end
        end
        
        plotProgress(0.1)
        
        
        allWalls = cell(1,1);
        allWallsCounter = 1;
        nn = 1;
        while ~isempty(mazeCell) && length(mazeCell) >= 1 && length(mazeCell) >= nn
            curCell = mazeCell{nn};
            if length(curCell) == 5 && curCell(1,1) == curCell(end,1) && curCell(1,2) == curCell(end,2)
                mazeCell(nn) = [];
                nn = nn-1;
                allWalls{allWallsCounter} = curCell;
                allWallsCounter = allWallsCounter + 1;
            else
                mm = 1;
                breakFlag = 1;
                while ~isempty(mazeCell) && mm <= length(mazeCell) && breakFlag
                    if mm ~= nn
                        curNextCell = mazeCell{mm};
                        if numel(curCell(ismember(curCell,curNextCell(1,:),'rows'))) > 0
                            if curCell(1,1) == curNextCell(1,1) && curCell(1,2) == curNextCell(1,2)
                                curNextCell = [flipud(curCell); curNextCell];
                            else
                                curNextCell = [curCell; curNextCell];
                            end
                            mazeCell{mm} = curNextCell;
                            mazeCell(nn) = [];
                            nn = nn-1;
                            breakFlag = 0;
                        elseif numel(curCell(ismember(curCell,curNextCell(end,:),'rows'))) > 0
                            if curCell(1,1) == curNextCell(end,1) && curCell(1,2) == curNextCell(end,2)
                                curNextCell = [curNextCell; curCell];
                            else
                                curNextCell = [curNextCell; flipud(curCell)];
                            end
                            mazeCell{mm} = curNextCell;
                            mazeCell(nn) = [];
                            nn = nn-1;
                            breakFlag = 0;
                        end
                    end
                    mm = mm+1;
                end
            end
            nn = nn+1;
            plotProgress(0.1+nn/length(mazeCell)*0.8)
        end
        
        plotProgress(0.9)
        for ii = 1:numel(allWalls)
            mazeCell{end+1} = allWalls{ii};
        end
        plotProgress(0.93)
        for ii = 1:numel(mazeCell)
            if isempty(mazeCell{ii})
                mazeCell(ii) = [];
            end
        end
        plotProgress(0.95)
        
        niceMazeFormat = [];
        for ii = 1:length(mazeCell)
            niceMazeFormat(end+1:end+length(mazeCell{ii})+1,1:2) = [mazeCell{ii}; NaN NaN];
        end        
        pacmanWalls = niceMazeFormat';
        
        plotProgress(0.97)
        curCoins = coins.data;
        
        for ii = 1:numel(mazeCell)
            current_wall = mazeCell{ii};
            in = inpolygon(curCoins(:,1),curCoins(:,2),current_wall(:,1),current_wall(:,2));
            curCoins(in,:) = [];
        end
        if ~isempty(pseudoWallCell) && numel(pseudoWallCell) > 1
            for ii = 2:numel(pseudoWallCell)
                current_wall = pseudoWallCell{ii};
                in = inpolygon(curCoins(:,1),curCoins(:,2),current_wall(:,1),current_wall(:,2));
                curCoins(in,:) = [];
            end
        end
        
        pacmanCoins = curCoins;
        set(coins.plot,'XData',curCoins(:,1),'YData',curCoins(:,2))
        plotProgress(1)
        set(saveButton ,'Enable','on')
    end
    
    function wallTypeSelection(src,~)
        currentWallType = str2double(src.SelectedObject.Tag);
    end

    function saveFun
        
        gameData.gameData.coins.data = pacmanCoins-1;
        
        pacmanWallsTest = [pacmanWalls [12:19 ones(1,5)*19 19:-1:12 ones(1,5)*12; ones(1,8)*16 16:20 ones(1,8)*20 20:-1:16]]-1;
        
        allDirections = cell(33,33);
        for ii = 1:33
            for jj = 1:33
                curDirections = 1:4;
                if any(ismember(pacmanWallsTest',[ii+1,jj],'rows'))
                    curDirections(curDirections==1) = [];
                end
                if any(ismember(pacmanWallsTest',[ii,jj-1],'rows'))
                    curDirections(curDirections==2) = [];
                end
                if any(ismember(pacmanWallsTest',[ii-1,jj],'rows'))
                    curDirections(curDirections==3) = [];
                end
                if any(ismember(pacmanWallsTest',[ii,jj+1],'rows'))
                    curDirections(curDirections==4) = [];
                end
                allDirections{ii,jj} = curDirections;
            end 
        end
        
        gameData.gameData.allWalls.pacmanWalls = [pacmanWalls [12 19 19 17 17 18.5 18.5 12.5 12.5 14 14 12 12;16 16 20 20 19.5 19.5 16.5 16.5 19.5 19.5 20 20 16]]-1;
        
        gameData.gameData.allDirections = allDirections;
        
        gameData = gameData.gameData;
        
        gameData.pillsData = pills.data-1;
        uisave('gameData','myOwnLabyData')
    end

    function pillsButtonDownFun(~,~,pillNo)
        pills.flag = pillNo;
    end

    function origBoard = pacBoard
        origBoard = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;0 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 1 0 0 1 0 0 1 1 1 1 1 1 1 1 1 1 1 0;0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 1 0 0 1 0 0 1 0 0 0 0 0 0 0 0 0 1 0;0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 1 0 0 1 0 0 1 0 0 0 0 0 0 0 0 0 1 0;0 1 0 0 1 0 0 0 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 1 0 0 1 0;0 1 0 0 1 0 0 0 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 1 0 0 1 0;0 1 0 0 1 0 0 1 1 1 1 0 0 1 1 1 1 0 0 1 1 1 1 0 0 1 0 0 1 1 0 0 1 0;0 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0;0 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0;0 1 0 0 1 1 1 1 0 0 1 0 0 1 1 1 1 0 0 1 1 1 1 1 1 1 0 0 1 1 0 0 1 0;0 1 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 1 0 0 1 0;0 1 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 1 0 0 1 0;0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 0 0 0 0 0 0 1 0 0 1 0 0 1 1 0 0 1 0;0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0;0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0;0 1 0 0 1 1 1 1 0 0 1 1 1 1 0 0 0 0 0 0 0 0 1 1 1 1 0 0 1 1 1 1 1 0;0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0;0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0;0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 0 0 0 0 0 0 1 0 0 1 0 0 1 1 0 0 1 0;0 1 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 1 0 0 1 0;0 1 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 1 0 0 1 0;0 1 0 0 1 1 1 1 0 0 1 0 0 1 1 1 1 0 0 1 1 1 1 1 1 1 0 0 1 1 0 0 1 0;0 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0;0 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0;0 1 0 0 1 0 0 1 1 1 1 0 0 1 1 1 1 0 0 1 1 1 1 0 0 0 0 0 1 1 0 0 1 0;0 1 0 0 1 0 0 0 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 0 0 0 1 1 0 0 1 0;0 1 0 0 1 0 0 0 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 0 0 0 1 1 0 0 1 0;0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 1 0 0 1 0 0 1 0 0 0 0 0 0 0 0 0 1 0;0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 1 0 0 1 0 0 1 0 0 0 0 0 0 0 0 0 1 0;0 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 1 0 0 1 0 0 1 1 1 1 1 1 1 1 1 1 1 0;0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
    end
end