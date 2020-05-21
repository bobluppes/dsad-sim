function Pacman

% Pacman Suite
% 
% Play pacman. 
% Make your own blinkies, pinkies, inkes and clydes and tweek the AI to make it unbeatable. 
% Draw your own labyrinths and play them. 
% Each ghost has its own personality comparable to the original. 
% Pacman AI is included, but blunt. You can create your own though.
% 
% Have fun!
%
%
% Controls:
% - use arrow keys or "WASD"-keys to control pacman
% - press "P" to pause
% - press "T" to show target tiles of each ghost
% - press "Q" for to let pacman be controlled by the computer
% - press "H" to show highscores
% - press "M" to show menu
% - press "U" to toggle sounds on or off
% - press "I" for super fast invincible mode
% 
% Ghost Creator:
% - Paint each frame for every ghost individually
% - Choose color for each ghost
% - left click (+hold down and drag) for painting pixels
% - right click (+hold down and drag) for erasing pixels
% - saving will create a new .mat-file with complete struct-array that can again be loaded into the game
% 
% Level Creator:
% - Draw your own level
% - left click (+hold down and drag) for painting walls
% - right click (+hold down and drag) for removing walls
% - use the "pseudo wall"-checkbox for creating coin-free zones inside the level (pacman can still go through these areas)
% - don't forget to click the "Valdate"-Button before saving!
% - saving will create a new .mat-file with complete struct-array that can again be loaded into the game
% 
% Programmer:   Markus Petershofen
% Date:         06.06.2017

close all
clc

%% General configurations
% load standard game data
gameData = load('gameData.mat');

% change the game configurations to suit yourself
overallEnemySpeed = 1/8;    % standard ghost speed, (default: 1/8, maximum possible: 1/2);
grumpyTime = 700;           % time-increments that ghosts stay grumpy for (default: 700)
grumpyTimeSwitch = 200;     % time-increments that grumpy ghosts show that they are going to turn normal again (default: 200)
newEnemyTime = 500;         % time-increments that pass before the next ghost is let out of his cage (default: 500)
fruitAppear = [300,1500];   % time frame in whih fruits are to appear in the game (default: between 300 and 1500 time-increments after level start)
game.speed = 0.025;         % game speed (time-increment between two frames) maximum possible without lag on my machine: 0.008
game.faster = -0.001;       % make game faster every level by this amount (default: -0.001)
game.maxSpeed = 0.015;      % maximimum game speed (default: 0.01)
AI.init = 0.0;              % initial AI-> 0: (almost) no randomness, 1: full randomness
AI.improve = -0.1;          % AI-improvement per level (default: -0.1)
pacman.speed = 1/6;         % pacman speed (default: 1/6 => pacman eats exactly two coins with every mouth open/close cycle, maximum possible: 1/2)
enemyPersonalities = 1;     % flag whether to use individual personalities for every ghost or not
showGhostTarget = 0;        % flag whether to show where each ghost is heading towards or not
autoPlay = 0;               % flag whether auto play is on or not
invincible = 0;             % make pacman invincible
soundsFlag = 1;             % flag whether sounds are on or off

% Use "Courier New" Font if available. But "Arial" is also ok.
if any(strcmp(listfonts,'Courier New'))
    pacFont = 'Courier New';
else
    pacFont = 'Arial';
end

% create figure
screen_size = get(0,'ScreenSize');                  % get screen size
screenCenter = screen_size(3:4)/2;                  % calculate screen center
figure_size = [700*0.9 700];                        % figure-size
limit_left = screen_size(3)/2-figure_size(1)/2;     % figure centered horizontally
limit_down = screen_size(4)/2-figure_size(2)/2;     % figure centered vertically
pacman_Fig = figure('units','pixels','Position',[limit_left limit_down figure_size(1) figure_size(2)],...  
    'Color','k','Resize','on','MenuBar','none','Visible','on',...
    'NumberTitle','off','Name','Pacman','doublebuffer','on',...
    'WindowKeyPressFcn',@KeyAction,...              % Keyboard-Callback
    'CloseRequestFcn',@(s,e)PacmanCloseFcn);        % when figure is closed
myAxes1 = axes('Units','normalized','Position',[0 0.04 1 0.90],...                                            
    'XLim',[-3.11 32.01],'YLim',[-3.11 32.01]); 
hold(myAxes1,'on')
axis(myAxes1,'off','equal')

allDirections = gameData.gameData.allDirections;    % all possible Directions in each square
allSprites = gameData.gameData.allSprites;          % all sprites-data
allWalls = gameData.gameData.allWalls;              % all wall-data
ghostSprites = allSprites.ghosts;                   % all ghosts-Sprites
eyeSprites = allSprites.eyes;                       % all eyes-Sprites
grumpySprites = allSprites.grumpy;                  % all grumpy-Sprites
fruits.data = allSprites.fruits;                    % all fruits-Sprites

allWallsPlot = plot(myAxes1,allWalls.pacmanWalls(1,:),allWalls.pacmanWalls(2,:),'b-','LineWidth',2);    % plot all walls
plot(myAxes1,[13.1 15.9],[18.75 18.75],'w-','LineWidth',3)                              % plot gate of ghost cage

%% Coins and pills
coins = gameData.gameData.coins;    % all coins-data
coins.originalData = coins.data;    % remember that data for a new game
coins.plot = plot(coins.data(:,1),coins.data(:,2),'.','Color',[255 185 151]/255,'MarkerSize',7); % plot all coins

%pills.data = [2 8; 2 28; 27 8; 27 28];  
pills.data = gameData.gameData.pillsData;   % pills-positions
pills.originalData = pills.data;            % remember 'em pills
pills.form = [sin(linspace(0,2*pi,10)); cos(linspace(0,2*pi,10))]'; % make 'em pills nice and round
pills.radius = 0.45;    % maximum size of pills
% pills are plotted as patches with vertices and faces. This is faster than
% changing "MarkerSize" of normal plots
pills.vertices = repmat(pills.radius*pills.form(:,1:2),4,1)+[repmat(pills.data(1,:),10,1);repmat(pills.data(2,:),10,1);repmat(pills.data(3,:),10,1);repmat(pills.data(4,:),10,1)];
pills.faces = reshape(linspace(1,40,40),10,4)';
% Plot 'em pills
pills.plot = patch(pills.data(1,:),pills.data(2,:),[255 185 151]/255,'Vertices',pills.vertices,'Faces',pills.faces,'Parent',myAxes1);
pills.growing = 0.025; % rate of pills-growth and shrink

% plot all the colors of current colormap in a very small image, so it
% cannot be seen. It needs to be there somewhere for all the colors to be
% just right.
imagesc(myAxes1,'XData',[0 0.001],'YData',[0.001 0],'CData',repmat(1:length(allSprites.colormap(:,1)),[length(allSprites.colormap(:,1)), 1]),'Visible','on');
colormap(allSprites.colormap)   % change colormap

%% Initialize Ghosts
enemies(1).pos = [14.5, 20];            % ghost position
enemies(1).dir = 0;                     % current ghost direction (right-1, down-2, left-3, up-4)
enemies(1).oldDir = 1;                  % last ghost direction
enemies(1).speed = overallEnemySpeed;   % ghost speed
enemies(1).status = 1;                  % ghost status (0-in cage, 1-normal, 2-grumpy, 3-eyes) 
enemies(1).statusTimer = -1;            % remember time for status change
enemies(1).curPosMov = [1, 3];          % current squares's possible moves
enemies(1).textTimer = 0;               % remembers when enemy was eaten
enemies(1).plot = imagesc(myAxes1,'XData',[enemies(1).pos(1)-0.6 enemies(1).pos(1)+0.6],'YData',[enemies(1).pos(2)+0.6 enemies(1).pos(2)-0.6],'CData',ghostSprites{1,2,1});
enemies(1).text = text(enemies(1).pos(1),enemies(1).pos(2),'100','Color','w','FontSize',10,'Visible','off','Parent',myAxes1,'FontName',pacFont,'FontUnits','normalized','FontWeight','bold');

enemies(2).pos = [14.5, 16.5];
enemies(2).dir = 0;
enemies(2).oldDir = 1;
enemies(2).speed = overallEnemySpeed;
enemies(2).status = 0;
enemies(2).statusTimer = -1;
enemies(2).curPosMov = 0;
enemies(2).textTimer = 0;
enemies(2).plot = imagesc(myAxes1,'XData',[enemies(2).pos(1)-0.6 enemies(2).pos(1)+0.6],'YData',[enemies(2).pos(2)+0.6 enemies(2).pos(2)-0.6],'CData',ghostSprites{2,2,1});
enemies(2).text = text(enemies(2).pos(1),enemies(2).pos(2),'100','Color','w','FontSize',10,'Visible','off','Parent',myAxes1,'FontName',pacFont,'FontUnits','normalized','FontWeight','bold');
               
enemies(3).pos = [12.5, 17.5];
enemies(3).dir = 0;
enemies(3).oldDir = 1;
enemies(3).speed = overallEnemySpeed;
enemies(3).status = 0;
enemies(3).statusTimer = -1;
enemies(3).curPosMov = 0;
enemies(3).textTimer = 0;
enemies(3).plot = imagesc(myAxes1,'XData',[enemies(3).pos(1)-0.6 enemies(3).pos(1)+0.6],'YData',[enemies(3).pos(2)+0.6 enemies(3).pos(2)-0.6],'CData',ghostSprites{3,2,1});
enemies(3).text = text(enemies(3).pos(1),enemies(3).pos(2),'100','Color','w','FontSize',10,'Visible','off','Parent',myAxes1,'FontName',pacFont,'FontUnits','normalized','FontWeight','bold');

enemies(4).pos = [16.5, 17.5];
enemies(4).dir = 0;
enemies(4).oldDir = 1;
enemies(4).speed = overallEnemySpeed;
enemies(4).status = 0;
enemies(4).statusTimer = -1;
enemies(4).curPosMov = 0;
enemies(4).textTimer = 0;
enemies(4).plot = imagesc(myAxes1,'XData',[enemies(4).pos(1)-0.6 enemies(4).pos(1)+0.6],'YData',[enemies(4).pos(2)+0.6 enemies(4).pos(2)-0.6],'CData',ghostSprites{4,2,1});
enemies(4).text = text(enemies(4).pos(1),enemies(4).pos(2),'100','Color','w','FontSize',10,'Visible','off','Parent',myAxes1,'FontName',pacFont,'FontUnits','normalized','FontWeight','bold');

%% Scatter or Chase modes (0: chase mode, 1: scatter mode)
% ghostMode.timer = 0;
ghostMode.timerValues = [250 1000; 1500 2000; 2650 3650; 3800 -1]; % switch to and fro from chase to scatter mode after some time. In the end only chase
ghostMode.timerStatus = 1; % in which interval of "ghostMode.timerValues" we are right now
ghostMode.status = 0; % 0: chase, 1: scatter
ghostMode.tiles = [1 -10; 28 -10; 28 33; 1 33]; % corner tiles for scatter mode. are slightly above and beneath the actual corners so host don't get trapped 
ghostMode.targetPlot = gobjects(1,4); % plot objects for target visualization
ghostMode.form = [0.5 0.5 -0.5 -0.5; 0.5 -0.5 -0.5 0.5]; % target form (square)
for ii = 1:4
    ghostMode.targetPlot(ii) = patch('XData',ghostMode.form(1,:),'YData',ghostMode.form(2,:),'FaceColor',allSprites.colormap(ghostSprites{ii,2,1}(1,6),:),'Parent',myAxes1,'Visible','off');
end

%% Fruits
fruits.pos = [0, 0];    % fruit position
fruits.item = 1;        % current level's fruit
fruits.score = [100 100 200 200 300 300 400 500]; % scores for each fruit
fruits.picked = zeros(1,8); % how many time each fruit picked was up
fruits.timer = randi([fruitAppear(1),fruitAppear(2)],1); % time window when fruit will appear
fruits.textTimer = 0;
fruits.scoreText = text(fruits.pos(1),fruits.pos(2),'100','Color','w','FontSize',10,'Visible','off','Parent',myAxes1,'FontName',pacFont,'FontUnits','normalized','FontWeight','bold');
fruits.plot = imagesc('XData',[0 1],'YData',[1 0],'CData',fruits.data{fruits.item},'Visible','off','Parent',myAxes1);
fruits.bottomPlot = gobjects(1,8);
fruits.bottomText = gobjects(1,8);
for ii = 1:8
    fruits.bottomPlot(ii) = imagesc(myAxes1,'XData',[27 29]-(ii-1)*2.4,'YData',[-0.8 -2.8],'CData',fruits.data{ii},'Visible','off','Parent',myAxes1);
    fruits.bottomText(ii) = text(28-(ii-1)*2.4,-3.5,[num2str(0) 'x'],'Color','w','FontSize',16,'FontName',pacFont,'FontUnits','normalized','FontWeight','bold','HorizontalAlignment','center','Parent',myAxes1,'Visible','off');
end

ghostFrame = 1;             % make the ghosts wobble
grumpyColorChange = 0;      % determines grumpy host color (blue or white)
grumpyTimeSwitchSave = 0;   % this variable remembers the timer-status, so the grumpy-ghosts all change at the the same time (blue-white-blue-...)
ghostPoints = 100;          % determines how many points a ghost adds to the score (doubles with each kill)

%% Initialize pacman
pacman.size = 0.8;          % pacman size
pacman.pos = [14.5 8];      % position of pacman
pacman.dir = 0;             % direction of pacman
pacman.oldDir = 1;          % old direction of pacman
pacman.status = -2;         % -2 is normal, -3 is hit by ghost (don't ask me why I chose 'em numbers like that)

% Calculate all pacman frames, from closed to fully open
for ii = 0:18
    pacman.frames{1,ii+1} = [[-0.3 sin(linspace(pi/2+ii*pi/18,5/2*pi-ii*pi/18,50))*pacman.size -0.3];[0 cos(linspace(pi/2+ii*pi/18,5/2*pi-ii*pi/18,50))*pacman.size 0]];
    pacman.frames{2,ii+1} = [[0 sin(linspace(pi/2+ii*pi/18+pi/2,5/2*pi-ii*pi/18+pi/2,50))*pacman.size 0];[0.3 cos(linspace(pi/2+ii*pi/18+pi/2,5/2*pi-ii*pi/18+pi/2,50))*pacman.size 0.3]];
    pacman.frames{3,ii+1} = [[0.3 sin(linspace(pi/2+ii*pi/18-pi,5/2*pi-ii*pi/18-pi,50))*pacman.size 0.3];[0 cos(linspace(pi/2+ii*pi/18-pi,5/2*pi-ii*pi/18-pi,50))*pacman.size 0]];
    pacman.frames{4,ii+1} = [[0 sin(linspace(pi/2+ii*pi/18-pi/2,5/2*pi-ii*pi/18-pi/2,50))*pacman.size 0];[-0.3 cos(linspace(pi/2+ii*pi/18-pi/2,5/2*pi-ii*pi/18-pi/2,50))*pacman.size -0.3]];
end

curFrame = 1;           % open-close-frame
frameDirection = 1;     % direction-frame
pacman.plot = fill(pacman.frames{pacman.oldDir,curFrame}(1,:)+pacman.pos(1),pacman.frames{pacman.oldDir,curFrame}(2,:)+pacman.pos(2),'y','EdgeColor','y','Parent',myAxes1);
pacman.targetPlot = patch('XData',ghostMode.form(1,:),'YData',ghostMode.form(2,:),'FaceColor','y','Parent',myAxes1,'Visible','off');
pacman.curAutoDir = [1 0];

%% lives, score, level, info, animations...
lives.orig = 3;             % lives of pacman
lives.data = lives.orig;    % remember default lives of pacman         
lives.plot = gobjects(1,lives.data);
for ii = 1:lives.data
    lives.plot(ii) = fill(pacman.frames{3,5}(1,:)+1+3*(ii-1),pacman.frames{3,5}(2,:)-2,'y','Parent',myAxes1);
end

score.data = 0;             % score
score.plot = text(29,33.1,['Score: ' num2str(score.data)],'Color','w','FontSize',12,'HorizontalAlign','Right','FontName',pacFont,'FontUnits','normalized','FontWeight','bold','Parent',myAxes1);

level.data = 1;          	% level
level.plot = text(0,33.1,['Level: ' num2str(level.data)],'Color','w','FontSize',12,'HorizontalAlign','Left','FontName',pacFont,'FontUnits','normalized','FontWeight','bold','Parent',myAxes1);

info.text = text(14.65,13.9,'READY!','Color','g','FontSize',20,'FontWeight','bold','horizontalAlignment','center','FontName',pacFont,'FontUnits','normalized','FontWeight','bold','Parent',myAxes1);

rays.num = 50;              % bursting rays when pacman is hit by ghost
rays.numFrames = 25;
rays.t = linspace(0,2*pi*(1-1/rays.num),rays.num);
rays.rad1 = linspace(0,1,rays.numFrames);
rays.rad2 = linspace(0.4,1,rays.numFrames);
rays.plot = plot(myAxes1,0, 0,'y:','Visible','off','MarkerSize',1);

%% Timer
isPause = 0; % game pause flag
myTimer = timer('TimerFcn',@(s,e)GameLoop,'Period',game.speed,'ExecutionMode','fixedRate');

%% UI-controls
newGameButton = createUIcontrol('pushbutton',[0.30 0.87 0.4 0.05],'New Game',18,pacFont,'k',get(0,'DefaultUicontrolBackgroundColor'),pacman_Fig,'on',@(s,e)newGameButtonFun);
createGhostsButton = createUIcontrol('pushbutton',[0.3 0.81 0.4 0.05],'Create Ghosts',18,pacFont,'k',get(0,'DefaultUicontrolBackgroundColor'),pacman_Fig,'on',@(s,e)createGhostsFun);
createLabyButton = createUIcontrol('pushbutton',[0.3 0.75 0.4 0.05],'Create Laby',18,pacFont,'k',get(0,'DefaultUicontrolBackgroundColor'),pacman_Fig,'on',@(s,e)createLabyFun);
loadGhostsButton = createUIcontrol('pushbutton',[0.3 0.69 0.4 0.05],'Load GameData',18,pacFont,'k',get(0,'DefaultUicontrolBackgroundColor'),pacman_Fig,'on',@(s,e)loadGhostsFun);
showHighScoresButton = createUIcontrol('pushbutton',[0.3 0.63 0.4 0.05],'Highscores',18,pacFont,'k',get(0,'DefaultUicontrolBackgroundColor'),pacman_Fig,'on',@(s,e)showHighScore);

%% HighScores
highScoreTemp = load('highScore.mat');
highScore.data = highScoreTemp.HighScore;
figure_size = figure_size/1.5;                      % figure-size
limit_left = screen_size(3)/2-figure_size(1)/2;     % figure centered horizontally
limit_down = screen_size(4)/2-figure_size(2)/2;     % figure centered vertically
highScore.fig = figure('units','pixels','Position',[limit_left limit_down figure_size(1) figure_size(2)],...  
    'Color','w','Resize','on','MenuBar','none','Visible','off',...
    'NumberTitle','off','Name','Highscore',...
    'CloseRequestFcn',@(s,e)HighScoreCloseFcn);
highScore.texts = gobjects(10);
highScore.values = gobjects(10);
createUIcontrol('text',[0.05 0.9 0.2 0.07],'Place',18,pacFont,'k','w',highScore.fig,'on','');
createUIcontrol('text',[0.28 0.9 0.4 0.07],'Name',18,pacFont,'k','w',highScore.fig,'on','');
createUIcontrol('text',[0.7 0.9 0.3 0.07],'Score',18,pacFont,'k','w',highScore.fig,'on','');
for ii = 1:10
    createUIcontrol('text',[0.05 0.9-ii/11.5 0.2 0.07],[num2str(ii) '.'],16,pacFont,'k','w',highScore.fig,'on','');
    highScore.texts(ii) = createUIcontrol('edit',[0.28 0.9-ii/11.5 0.4 0.07],highScore.data{ii,1},16,pacFont,'k','w',highScore.fig,'on',{@HighScoreEdit,ii});
    highScore.texts(ii).Enable = 'off';
    highScore.values(ii)= createUIcontrol('text',[0.7 0.9-ii/11.5 0.3 0.07],num2str(highScore.data{ii,2}),16,pacFont,'k','w',highScore.fig,'on','');
end
info.highScoreText = text(14.5,33.1,['High Score: ' num2str(highScore.data{1,2})],'Color','w','FontSize',12,'HorizontalAlign','Center','FontName',pacFont,'FontUnits','normalized','FontWeight','bold','Parent',myAxes1);

%% Sounds
% special thanks to: http://www.classicgaming.cc/classics/pac-man/sounds

[b_y,b_Fs] = audioread('Sounds/pacman_beginning.wav');
[c_y,c_Fs] = audioread('Sounds/pacman_chomp.wav');
[d_y,d_Fs] = audioread('Sounds/pacman_death.wav');
[ef_y,ef_Fs] = audioread('Sounds/pacman_eatfruit.wav');
[eg_y,eg_Fs] = audioread('Sounds/pacman_eatghost.wav');
[i_y,i_Fs] = audioread('Sounds/pacman_intermission.wav');
c_y(end-round(length(c_y)/2):end) = []; % shorten waka-waka sound
sounds.beginning = audioplayer(b_y, b_Fs);
sounds.coin1 = audioplayer(c_y, c_Fs);
sounds.coin2 = audioplayer(c_y, c_Fs);
sounds.coin3 = audioplayer(c_y, c_Fs);
sounds.death = audioplayer(d_y, d_Fs);
sounds.eatfruit = audioplayer(ef_y, ef_Fs);
sounds.eatghost = audioplayer(eg_y, eg_Fs);
sounds.intermission1 = audioplayer(i_y, i_Fs);
sounds.intermission2 = audioplayer(i_y, i_Fs);
sounds.timer_c = timer('TimerFcn',@(s,e)soundManager_c,'Period',round(length(c_y)/c_Fs*1000)/1000-0.031,'ExecutionMode','fixedRate'); % -0.12
sounds.coinEating = 0;

musicIcon.data = load('Sounds/musicIcon.mat');
musicIcon.data = musicIcon.data.musicIcon;
musicIcon.data(musicIcon.data==1) = 8;
musicIcon.data(musicIcon.data==0) = 1;
musicIcon.plot = imagesc('XData',[0 1.5]-2,'YData',[1.5 0]-2.75,'CData',musicIcon.data,'Visible','on','Parent',myAxes1,'ButtonDownFcn',@(s,e)musicOnOff);

%% Include Pacman Ghost Creator
% first an empty figure is created. The figure-parameters are then
% specified in "ghostCreator.m".
pacmanGhostCreator_Fig = figure('Visible','off');
pacmanLabyCreator_Fig = figure('Visible','off');
    
    function newGameButtonFun
        if soundsFlag
            play(sounds.beginning)
        end
        coins.data = coins.originalData;
        pills.data = pills.originalData;
        level.data = 1;
        set(level.plot,'String',['Level: ' num2str(level.data)]);
        score.data = 0;
        set(score.plot,'String',['Score: ' num2str(score.data)])
        lives.data = lives.orig;
    
        set(lives.plot(:),'Visible','on')
        set(fruits.bottomPlot(:),'Visible','off')
        set(fruits.bottomText(:),'Visible','off')
        set(newGameButton,'Visible','off')
        set(createGhostsButton,'Visible','off')
        set(loadGhostsButton,'Visible','off')
        set(pacmanGhostCreator_Fig,'Visible','off')
        set(pacmanLabyCreator_Fig,'Visible','off')
        set(createLabyButton,'Visible','off')
        set(showHighScoresButton,'Visible','off')
        
        for nn = 1:4
            set(ghostMode.targetPlot(nn),'FaceColor',allSprites.colormap(ghostSprites{nn,2,1}(1,6),:));
        end
        
        % ugly workaround for focussing on figure after buttonpress (needed
        % for WindowKeyPressFcn to work properly)
        set(0,'PointerLocation',screenCenter)
        robot = java.awt.Robot;
        robot.mousePress(java.awt.event.InputEvent.BUTTON1_MASK);
        robot.mouseRelease(java.awt.event.InputEvent.BUTTON1_MASK);
        
        newGame
        set(info.text,'Visible','off')
    end

    function createGhostsFun
        ghostCreator(pacmanGhostCreator_Fig);
    end

    function createLabyFun
        labyCreator(pacmanLabyCreator_Fig);
    end

    function loadGhostsFun
        [FileName,PathName,~] = uigetfile('*.mat');
        if ~FileName
            return
        end
        gameData = load(fullfile([PathName FileName]));
        allSprites = gameData.gameData.allSprites;
        ghostSprites = allSprites.ghosts;
        eyeSprites = allSprites.eyes;
        grumpySprites = allSprites.grumpy;
        colormap(allSprites.colormap)
        
        for nn = 1:4
            plotGhost(enemies(nn),ghostSprites{nn,enemies(nn).oldDir,ghostFrame+1},zeros(14,14))
        end
        
        allDirections = gameData.gameData.allDirections;
        allWalls = gameData.gameData.allWalls;
        coins.data = gameData.gameData.coins.data;  
        coins.originalData = coins.data; 
        set(allWallsPlot,'XData',allWalls.pacmanWalls(1,:),'YData',allWalls.pacmanWalls(2,:));
        set(coins.plot,'XData',coins.data(:,1),'YData',coins.data(:,2));
    end

    function GameLoop
        pacmanMoveFun
        enemyRefresh
        pillsFun
        fruitsFun
        coinsFun
        ghostTimerFun
    end

    function musicOnOff
        soundsFlag = ~soundsFlag;
        if soundsFlag
            musicIcon.data(musicIcon.data==3) = 8;
        else
            musicIcon.data(musicIcon.data==8) = 3;
            stop(sounds.beginning)
            stop(sounds.coin1)
            stop(sounds.coin2)
            stop(sounds.coin3)
            stop(sounds.death)
            stop(sounds.eatfruit)
            stop(sounds.eatghost)
            stop(sounds.intermission1)
            stop(sounds.intermission2)
        end
        set(musicIcon.plot,'CData',musicIcon.data)
    end

    function soundManager_c % manages the waka waka coin eating sound
        if sounds.coinEating && soundsFlag
            if isplaying(sounds.coin1)
                play(sounds.coin2)
            elseif isplaying(sounds.coin2)
                play(sounds.coin3)
            else
                play(sounds.coin1)
            end
            sounds.coinEating = 0;
        else
            stop(sounds.timer_c)
        end
    end

    function newGame
        stop(myTimer)
        enemies(1).pos = [14.5, 20];
        enemies(2).pos = [14.5, 16.5];
        enemies(3).pos = [12.5, 17.5];
        enemies(4).pos = [16.5, 17.5];
        for nn = 1:4
            enemies(nn).status = 0;
            enemies(nn).dir = 0;
            enemies(nn).oldDir = 2;
            enemies(nn).speed = overallEnemySpeed;
            enemies(nn).statusTimer = -1;
            enemies(nn).curPosMov = [1, 3];
            enemies(nn).textTimer = 0;
        end
        enemies(1).dir = 1;
        enemies(1).status = 1;
        
        ghostMode.timerStatus = 1; 
        ghostMode.status = 0; 
        
        pacman.pos = [14.5 8];
        pacman.dir = 0;
        pacman.oldDir = 1;
        pacman.status = -2;
        set(pacman.plot,'XData',pacman.frames{pacman.oldDir,1}(1,:)+pacman.pos(1),'YData',pacman.frames{pacman.oldDir,1}(2,:)+pacman.pos(2),'Visible','on')
        set(info.text,'String','READY!','Color','g','Visible','on')
        
        for nn = 1:4
            plotGhost(enemies(nn),ghostSprites{nn,enemies(nn).oldDir,1},zeros(14,14))
            set(enemies(nn).plot,'Visible','on')
        end
        
        pause(1)
        set(info.text,'Visible','off')
        start(myTimer)
        
%         % Debug Mode
%         while 1
%             GameLoop
%             pause(0.01)
%         end
    end

    function coinsFun
        if any(ismember(coins.data,findSquare(pacman,pacman.oldDir),'rows'))
            coins.data(ismember(coins.data,findSquare(pacman,pacman.oldDir),'rows'),:) = [];
            score.data = score.data+10;
            sounds.coinEating = 1;
            if strcmp(get(sounds.timer_c,'Running'),'off')
                start(sounds.timer_c)
            end
        end
        
        set(coins.plot,'XData',coins.data(:,1),'YData',coins.data(:,2))
        set(score.plot,'String',['Score: ' num2str(score.data)])
        
        if isempty(coins.data) % next Level
            level.data = level.data+1;
            set(level.plot,'String',['Level: ' num2str(level.data)]);
            game.speed = game.speed+game.faster;
            if game.speed < game.maxSpeed   
                game.speed = game.maxSpeed; % limit game speed, so screen has time to update itself
            end
            stop(myTimer)
            set(myTimer,'Period',game.speed)
            coins.data = coins.originalData;
            pills.data = pills.originalData;
            fruits.timer = randi([fruitAppear(1),fruitAppear(2)],1);
            fruits.textTimer = 0;
            newGame
        end
    end

    function pillsFun
        if any(ismember(pills.data,findSquare(pacman,pacman.oldDir),'rows'))
            pills.data(ismember(pills.data,findSquare(pacman,pacman.oldDir),'rows'),:) = [];
            ghostPoints = 100;
            for nn = 1:4
                if enemies(nn).status > 0 && enemies(nn).status < 4
                    enemies(nn).status = 2;
                elseif enemies(nn).status == 5
                    enemies(nn).status = 6;
                elseif enemies(nn).status == 6
                    enemies(nn).status = 6;
                elseif enemies(nn).status == 7
                    enemies(nn).status = 7;
                else
                    enemies(nn).status = 4;
                end
                enemies(nn).statusTimer = myTimer.TasksExecuted;
            end
            if soundsFlag
                play(sounds.intermission1)
            end
        end
        
        if pills.radius > 0.45 || pills.radius < 0.1
            pills.growing = -pills.growing;
        end
        pills.radius = pills.radius+pills.growing;
        pillsMat = zeros(length(pills.data(:,1))*10,2);
        for rr = 1:length(pills.data(:,1))
            pillsMat((rr-1)*10+1:rr*10,:) = repmat(pills.data(rr,:),10,1);
        end
        pills.vertices = repmat(pills.radius*pills.form(:,1:2),length(pills.data(:,1)),1)+pillsMat;
        pills.faces = reshape(linspace(1,length(pills.data(:,1))*10,length(pills.data(:,1))*10),10,length(pills.data(:,1)))';
        set(pills.plot,'Vertices',pills.vertices,'Faces',pills.faces)
    end

    function fruitsFun
        if (fruits.timer > 0 && fruits.timer < myTimer.TasksExecuted) || (fruits.timer > 0 && length(coins.data(:,1)) <= 10)
            fruits.timer = -1;
            
            fruits.item = mod(level.data,9);
            
            if level.data > 8
                fruits.item = mod(level.data-8*floor(level.data/8),9)+(~mod(level.data-8*floor(level.data/8),9))*8;
            end
            
            fruits.pos = coins.originalData(randi([1 length(coins.originalData(:,1))],1),:);
            
            alphaMask = fruits.data{fruits.item};
            alphaMask(alphaMask~=1) = 0;
            alphaMask = ~alphaMask;
            set(fruits.plot,'Visible','on','XData',[fruits.pos(1)-0.6 fruits.pos(1)+0.6],'YData',[fruits.pos(2)+0.6 fruits.pos(2)-0.6],'CData',fruits.data{fruits.item},'AlphaData',alphaMask)
        end 
        if any(ismember(fruits.pos,findSquare(pacman,pacman.oldDir),'rows'))
            if soundsFlag
                play(sounds.eatfruit)
            end
            for mm = 0:30
                set(fruits.scoreText,'String',num2str(fruits.score(fruits.item)),'Position',[fruits.pos(1)-0.6,fruits.pos(2)+(mm)/30+0.6,0],'Visible','on')
                pause(0.02)
            end
            fruits.pos = [0,0];
            fruits.picked(fruits.item) = fruits.picked(fruits.item)+1;
            score.data = score.data+fruits.score(fruits.item);
            fruits.textTimer = myTimer.TasksExecuted;
            set(fruits.plot,'Visible','off')
            set(fruits.bottomPlot(fruits.item),'CData',fruits.data{fruits.item},'Visible','on')
            set(fruits.bottomText(fruits.item),'String',[num2str(fruits.picked(fruits.item)) 'x'],'Visible','on');
        end
        if strcmp(get(fruits.scoreText,'Visible'),'on') && myTimer.TasksExecuted - fruits.textTimer > 50
            set(fruits.scoreText,'Visible','off')
        end
    end

    function pacmanMoveFun
        % Tunnel logic
        if pacman.pos(1) > 28
            pacman.pos(1) = 1;
        elseif pacman.pos(1) < 1
            pacman.pos(1) = 28;
        elseif pacman.pos(2) > 31
            pacman.pos(2) = 1;
        elseif pacman.pos(2) < 1
            pacman.pos(2) = 31;
        end
        
        % Pacman AI
        if autoPlay
            curSquare1 = findSquare(pacman,pacman.dir);
            curSquare2 = pacmanAI(pacman,enemies,allDirections,coins,pills);
            pacman.dir = shortestPath(curSquare1,curSquare2,pacman);
            if showGhostTarget
                set(pacman.targetPlot,'XData',curSquare2(1)+ghostMode.form(1,:),'YData',curSquare2(2)+ghostMode.form(2,:),'Visible','on')
            end
        end
        
        if ~showGhostTarget || ~autoPlay
            set(pacman.targetPlot,'Visible','off') 
        end
        pacman = pathWayLogic(pacman,pacman.speed);
        
        if frameDirection   % if mouth is opening 
            curFrame = curFrame+1;
        else                % if mouth is closing
            curFrame = curFrame-1;
        end
        
        if curFrame == 1        % if mouth is fully closed
            frameDirection = 1;
        elseif curFrame == 7    % if mouth is fully open
            frameDirection = 0;
        end
        
        % update pacman plot
        set(pacman.plot,'XData',pacman.frames{pacman.oldDir,curFrame}(1,:)+pacman.pos(1),'YData',pacman.frames{pacman.oldDir,curFrame}(2,:)+pacman.pos(2))
        
        if pacman.status == -3 % if pacman is hit by ghost
            lives.data = lives.data-1;  % lose 1 life
            
            if soundsFlag
                play(sounds.death)
            end
            
            % start animation
            for nn = 1:4 % turn ghosts off
                set(enemies(nn).plot,'Visible','off')
            end
            
            for nn = 0:18 % make pacman disappear
                set(pacman.plot,'XData',pacman.frames{pacman.oldDir,nn+1}(1,:)+pacman.pos(1),'YData',pacman.frames{pacman.oldDir,nn+1}(2,:)+pacman.pos(2))
                pause(0.05)
            end
            set(pacman.plot,'Visible','off')
             
            switch pacman.oldDir % move bursting-center to correct position
                case 1
                    explodeCorrection = [-0.4 0];
                case 2
                    explodeCorrection = [0 0.4];
                case 3
                    explodeCorrection = [0.4 0];
                case 4
                    explodeCorrection = [0 -0.4];
            end
            
            for nn = 1:rays.numFrames   % make pacman burst
                circ1 = rays.rad1(nn)*[sin(rays.t); cos(rays.t)];
                circ2 = rays.rad2(nn)*[sin(rays.t); cos(rays.t)];

                rays.data = zeros(2,3*rays.num);

                for kk = 1:rays.num
                    rays.data(1,1+(kk-1)*3:3+(kk-1)*3) = pacman.pos(1)+[circ1(1,kk) circ2(1,kk) NaN]+explodeCorrection(1);
                    rays.data(2,1+(kk-1)*3:3+(kk-1)*3) = pacman.pos(2)+[circ1(2,kk) circ2(2,kk) NaN]+explodeCorrection(2);
                end
                set(rays.plot,'XData',rays.data(1,:),'YData',rays.data(2,:),'Visible','on')
                pause(0.05)
            end
            set(rays.plot,'Visible','off')
            
            if lives.data >= 0 % start anew
                set(lives.plot(lives.data+1),'Visible','off')
                newGame
            else % Game Over
                set(info.text,'Visible','on','String','Game Over', 'Color','r')
                stop(myTimer)
                setHighscore
                set(newGameButton,'Visible','on')
                set(createGhostsButton,'Visible','on')
                set(loadGhostsButton,'Visible','on')
                set(createLabyButton,'Visible','on')
                set(showHighScoresButton,'Visible','on')
            end
        end
    end

    function enemyRefresh % handles status and appearance of all ghosts 
        if curFrame == 1 || curFrame == 7 % switch between frames for movement illusion
            ghostFrame = ~ghostFrame;
        end
        for nn = 1:4 % consider one ghost at a time
            % ghost hits pacman -> pacman dies
            if enemies(nn).status == 1 && abs(pacman.pos(1)-enemies(nn).pos(1)) < 1.1 && abs(pacman.pos(2)-enemies(nn).pos(2)) < 1.1 && ~invincible
                pacman.status = -3; % pacman dies
            end
            
            % pacman hits grumpy ghost -> ghost dies
            if enemies(nn).status == 2 && abs(pacman.pos(1)-enemies(nn).pos(1)) < 1.1 && abs(pacman.pos(2)-enemies(nn).pos(2)) < 1.1 
                enemies(nn).status = 3;
                enemies(nn).speed = overallEnemySpeed*2;
                enemies(nn).statusTimer = myTimer.TasksExecuted;
                ghostPoints = ghostPoints*2;
                score.data = score.data+ghostPoints;
                if soundsFlag
                    play(sounds.eatghost)
                end
                for mm = 0:30
                    set(enemies(nn).text,'String',num2str(ghostPoints),'Position',[enemies(nn).pos(1)-0.6,enemies(nn).pos(2)+mm/30,0],'Visible','on')
                    pause(0.02)
                end
                
                enemies(nn).textTimer = myTimer.TasksExecuted;
            end
            
            if strcmp(get(enemies(nn).text,'Visible'),'on') && myTimer.TasksExecuted - enemies(nn).textTimer > 50
                set(enemies(nn).text,'Visible','off')
            end
            
            % ghost or grumpy ghost exits the cage after certain time
            if nn > 1 && newEnemyTime*(nn-1) == myTimer.TasksExecuted
                if enemies(nn).status == 4
                    enemies(nn).status = 6;
                else
                    enemies(nn).status = 5;
                end
            end
            
            switch enemies(nn).status % handle ghost status 1 to 7
                case {0,4} % inside cage
                    if enemies(nn).pos(2) >= 17.5
                        enemies(nn).dir = 2;
                    elseif enemies(nn).pos(2) <= 16.5
                        enemies(nn).dir = 4;
                    end
                    switch enemies(nn).dir
                        case 2
                            enemySpeed = [0 -overallEnemySpeed];
                            enemies(nn).oldDir = enemies(nn).dir;
                            enemies(nn).pos = enemies(nn).pos+enemySpeed;
                        case 4
                            enemySpeed = [0 overallEnemySpeed];
                            enemies(nn).oldDir = enemies(nn).dir;
                            enemies(nn).pos = enemies(nn).pos+enemySpeed;
                    end
                case 1 % normal mode
                    if enemies(nn).dir > 0
                        enemies(nn).oldDir = enemies(nn).dir;
                    end
                    if (AI.init+AI.improve*(level.data-1) < 0.5 && rand >= 0.5) || ~any(allPossibleMoves(enemies(nn)) == enemies(nn).dir) || ~isequal(allPossibleMoves(enemies(nn)),enemies(nn).curPosMov)
                        curSquare1 = findSquare(enemies(nn),enemies(nn).dir);
                        if ~ghostMode.status
                            if enemyPersonalities % use individual personalties
                                % different ghost personalities: 
                                % red: always follows pacman (when in chase mode)
                                % blue: almost as pink but more complicated. check with google or try understanding the code (when in chase mode)
                                % pink: always follows 4 tiles ahead of pacman (when in chase mode)
                                % orange: follow pacman if 8 tiles or further away, otherwise scatter to corner (when in chase mode)
                                switch nn
                                    case 1
                                        curSquare2 = findSquare(pacman,pacman.dir);
                                    case 2
                                        pinkyGoal = pacman;
                                        switch pinkyGoal.dir
                                            case 1
                                                pinkyGoal.pos(1) = pinkyGoal.pos(1)+5;
                                            case 2
                                                pinkyGoal.pos(2) = pinkyGoal.pos(2)-5;
                                            case 3
                                                pinkyGoal.pos(1) = pinkyGoal.pos(1)-5;
                                            case 4
                                                pinkyGoal.pos(2) = pinkyGoal.pos(2)+5;
                                        end
                                        curSquare2 = findSquare(pinkyGoal,pinkyGoal.dir);
                                    case 3
                                        inkyGoal = pacman;
                                        switch inkyGoal.dir
                                            case 1
                                                inkyGoal.pos(1) = inkyGoal.pos(1)+3;
                                            case 2
                                                inkyGoal.pos(2) = inkyGoal.pos(2)-3;
                                            case 3
                                                inkyGoal.pos(1) = inkyGoal.pos(1)-3;
                                            case 4
                                                inkyGoal.pos(2) = inkyGoal.pos(2)+3;
                                        end
                                        inkyGoal.pos = enemies(1).pos + 2*(inkyGoal.pos-enemies(1).pos);
                                        curSquare2 = findSquare(inkyGoal,inkyGoal.dir);
                                    case 4
                                        if norm(pacman.pos-enemies(4).pos) > 7
                                        	curSquare2 = findSquare(pacman,pacman.dir);
                                        else
                                            curSquare2 = ghostMode.tiles(nn,:);
                                        end
                                end
                            else % no individual personalties
                                curSquare2 = findSquare(pacman,pacman.dir);
                            end
                        else
                            curSquare2 = ghostMode.tiles(nn,:);
                        end
                       
                        enemies(nn).dir = shortestPath(curSquare1,curSquare2,enemies(nn));
                        
                        if curSquare2(1) < 1 
                            curSquare2(1) = 1;
                        elseif curSquare2(1) > 28 
                            curSquare2(1) = 28;
                        end
                        if curSquare2(2) < 1 
                            curSquare2(2) = 1;
                        elseif curSquare2(2) > 31 
                            curSquare2(2) = 31;
                        end
                        
                        if showGhostTarget
                            set(ghostMode.targetPlot(nn),'XData',curSquare2(1)+ghostMode.form(1,:),'YData',curSquare2(2)+ghostMode.form(2,:),'Visible','on')
                        end
                        
                        enemies(nn) = pathWayLogic(enemies(nn),enemies(nn).speed);
                        enemies(nn).curPosMov = allPossibleMoves(enemies(nn));
                    else
                        enemies(nn) = pathWayLogic(enemies(nn),enemies(nn).speed);
                    end
                case 2 % grumpy mode
                    if enemies(nn).dir > 0
                        enemies(nn).oldDir = enemies(nn).dir;
                    end
                    if ~any(allPossibleMoves(enemies(nn)) == enemies(nn).dir) || ~isequal(allPossibleMoves(enemies(nn)),enemies(nn).curPosMov)
                        curSquare1 = findSquare(enemies(nn),enemies(nn).dir);
                        curSquare2 = findSquare(pacman,pacman.dir);

                        enemies(nn).dir = shortestPath(curSquare1,curSquare2,enemies(nn));
                    end
                    enemies(nn) = pathWayLogic(enemies(nn),overallEnemySpeed*0.5);
                case 3 % eye mode
                    if enemies(nn).dir > 0
                        enemies(nn).oldDir = enemies(nn).dir;
                    end
                    if ~any(allPossibleMoves(enemies(nn)) == enemies(nn).dir) || ~isequal(allPossibleMoves(enemies(nn)),enemies(nn).curPosMov)
                        curSquare1 = findSquare(enemies(nn),enemies(nn).dir);
                        curSquare2 = [14.5, 20];

                        enemies(nn).dir = shortestPath(curSquare1,curSquare2,enemies(nn));
                    end
                    enemies(nn) = pathWayLogic(enemies(nn),enemies(nn).speed*1);
                    if isequal(findSquare(enemies(nn),enemies(nn).dir),[14, 20]) || isequal(findSquare(enemies(nn),enemies(nn).dir),[15, 20])
                        enemies(nn).status = 7;
                        enemies(nn).pos = [14.5,20];
                        enemies(nn).dir = 2;
                    end
                case {5,6} % 5-inside cage on the way out normal mode, 6-inside cage on the way out grumpy mode
                    if enemies(nn).pos(1) < 14.5
                        enemies(nn).dir = 1;
                    elseif enemies(nn).pos(1) > 14.5
                        enemies(nn).dir = 3;
                    elseif enemies(nn).pos(2) < 19.75
                        enemies(nn).dir = 4;
                    elseif enemies(nn).pos(2) >= 19.75
                        if enemies(nn).status == 6
                            enemies(nn).status = 2;
                        else
                            enemies(nn).status = 1;
                        end
                    end
                    switch enemies(nn).dir
                        case 1
                            enemySpeed = [overallEnemySpeed 0];
                            enemies(nn).oldDir = enemies(nn).dir;
                            enemies(nn).pos = enemies(nn).pos+enemySpeed;
                        case 3
                            enemySpeed = [-overallEnemySpeed 0];
                            enemies(nn).oldDir = enemies(nn).dir;
                            enemies(nn).pos = enemies(nn).pos+enemySpeed;
                        case 4
                            enemySpeed = [0 overallEnemySpeed];
                            enemies(nn).oldDir = enemies(nn).dir;
                            enemies(nn).pos = enemies(nn).pos+enemySpeed;
                    end
                case 7 % on the way inside the cage
                    enemies(nn).dir = 2;
                    enemySpeed = [0 -overallEnemySpeed];
                    enemies(nn).oldDir = enemies(nn).dir;
                    enemies(nn).pos = enemies(nn).pos+enemySpeed;
                    if enemies(nn).pos(2) <= 16.5
                        enemies(nn).status = 5;
                    end
            end
            if ~showGhostTarget || enemies(nn).status ~= 1
                set(ghostMode.targetPlot(nn),'Visible','off')
            end
            
            % ghost appearance depending on current ghost status
            if (enemies(nn).status == 2 || enemies(nn).status == 4 || enemies(nn).status == 6) && myTimer.TasksExecuted - enemies(nn).statusTimer < grumpyTime-grumpyTimeSwitch
                alphaMask = grumpySprites{1,ghostFrame+1}; % transparency
                plotGhost(enemies(nn),grumpySprites{1,ghostFrame+1},alphaMask)
            elseif (enemies(nn).status == 2 || enemies(nn).status == 4 || enemies(nn).status == 6) && myTimer.TasksExecuted - enemies(nn).statusTimer < grumpyTime
                % ghosts switch from blue to white every 10 frames
                if ~mod(myTimer.TasksExecuted,10) && grumpyTimeSwitchSave ~= myTimer.TasksExecuted
                    grumpyColorChange = ~grumpyColorChange;
                    grumpyTimeSwitchSave = myTimer.TasksExecuted; % remembers last color change
                end
                alphaMask = grumpySprites{grumpyColorChange+1,ghostFrame+1};
                plotGhost(enemies(nn),grumpySprites{grumpyColorChange+1,ghostFrame+1},alphaMask)
            elseif (enemies(nn).status == 3 || enemies(nn).status == 7) && myTimer.TasksExecuted - enemies(nn).statusTimer < grumpyTime-grumpyTimeSwitch
                alphaMask = eyeSprites{nn,enemies(nn).oldDir};
                plotGhost(enemies(nn),eyeSprites{nn,enemies(nn).oldDir},alphaMask)
            else
                enemies(nn).speed = overallEnemySpeed;
                alphaMask = ghostSprites{nn,enemies(nn).oldDir,ghostFrame+1};
                plotGhost(enemies(nn),ghostSprites{nn,enemies(nn).oldDir,ghostFrame+1},alphaMask)
            end
            % return from grumpy to normal
            if (enemies(nn).status == 2 && myTimer.TasksExecuted - enemies(nn).statusTimer >= grumpyTime) || (enemies(nn).status == 3 && myTimer.TasksExecuted - enemies(nn).statusTimer >= grumpyTime-grumpyTimeSwitch)
                enemies(nn).status = 1;
            end
            % Tunnel logic
            if enemies(nn).pos(1) > 28
                enemies(nn).pos(1) = 1;
            elseif enemies(nn).pos(1) < 1
                enemies(nn).pos(1) = 28;
            elseif enemies(nn).pos(2) > 31
                enemies(nn).pos(2) = 1;
            elseif enemies(nn).pos(2) < 1
                enemies(nn).pos(2) = 31;
            end
            % remember ghost movement possiblities, proportional to enemy
            % speed, so that he remebers only the last squares's
            % possibilities
            if ~mod(myTimer.TasksExecuted,1/enemies(nn).speed+1)
                enemies(nn).curPosMov = allPossibleMoves(enemies(nn));
            end
        end
    end

    function plotGhost(curGhost,curCData,curAlphaMask)
        curAlphaMask(curAlphaMask~=1) = 0;
        curAlphaMask = ~curAlphaMask;
        set(curGhost.plot,'XData',[curGhost.pos(1)-0.6 curGhost.pos(1)+0.6],...
                          'YData',[curGhost.pos(2)+0.6 curGhost.pos(2)-0.6],...
                          'CData',curCData,...
                          'AlphaData',curAlphaMask)
    end

    function curSquare = findSquare(entity,dir)
        if dir == 1 || dir == 4
            curSquare = [round(entity.pos(1)-0.45),round(entity.pos(2)-0.45)];
        else
            curSquare = [round(entity.pos(1)+0.45),round(entity.pos(2)+0.45)];
        end
    end

    function possibleMoves = allPossibleMoves(entity)
        curSquare = findSquare(entity,entity.dir);
        possibleMoves = allDirections{curSquare(1),curSquare(2)};
    end

    % simple -> simpler -> simplest -> my AI
    function nextMove = shortestPath(square1,square2,entity)
        possibleMoves = allDirections{square1(1),square1(2)};
        if abs(square1(1)-square2(1)) > abs(square1(2)-square2(2))
            if square1(1) > square2(1)
                nextMove = 3;
            else                
                nextMove = 1;
            end
        else
            if square1(2) > square2(2)
                nextMove = 2;
            else                
                nextMove = 4;
            end
        end
        curAI = AI.init+AI.improve*(level.data-1);
        curAI(curAI<0.05) = 0.05; % always keep some rest randomness
        if entity.status == 3 % eyes are very clever, but for their own sake, not too clever
            curAI = 0.1;
        end
        if ~any(possibleMoves==nextMove) && any(possibleMoves==entity.dir)
            nextMove = entity.dir;
        elseif ~isempty(possibleMoves) && (~any(possibleMoves==nextMove) || entity.status == 2 || rand < curAI)
            nextMove = possibleMoves(randi(length(possibleMoves),1));
        end
    end

    function entity = pathWayLogic(entity,speed)
        possibleDirections_minus = allDirections{round(entity.pos(1)-0.45),round(entity.pos(2)-0.45)};
        possibleDirections_plus = allDirections{round(entity.pos(1)+0.45),round(entity.pos(2)+0.45)};
        switch entity.dir
            case 0
                entity.oldDir = 1;
            case 1
                if rem(round(entity.pos(2)/speed)*speed,1) == 0 && any(possibleDirections_minus==entity.dir)
                    entity.pos(2) = round(entity.pos(2)/speed)*speed;
                    entity.pos(1) = entity.pos(1)+speed;
                    entity.oldDir = 1;
                elseif entity.oldDir == 2 && any(possibleDirections_plus==entity.oldDir)
                    entity.pos(2) = entity.pos(2)-speed;
                elseif entity.oldDir == 4 && any(possibleDirections_minus==entity.oldDir)
                    entity.pos(2) = entity.pos(2)+speed;
                elseif entity.status > -2
                    entity.pos(2) = entity.pos(2)+speed;
                end
            case 2
                if rem(round(entity.pos(1)/speed)*speed,1) == 0 && any(possibleDirections_plus==entity.dir)
                    entity.pos(1) = round(entity.pos(1)/speed)*speed;
                    entity.pos(2) = entity.pos(2)-speed;
                    entity.oldDir = 2;
                elseif entity.oldDir == 1 && any(possibleDirections_minus==entity.oldDir)
                    entity.pos(1) = entity.pos(1)+speed;
                elseif entity.oldDir == 3 && any(possibleDirections_plus==entity.oldDir)
                    entity.pos(1) = entity.pos(1)-speed;
                elseif entity.status > -2
                    entity.pos(1) = entity.pos(1)-speed;
                end
            case 3
                if rem(round(entity.pos(2)/speed)*speed,1) == 0 && any(possibleDirections_plus==entity.dir)
                    entity.pos(2) = round(entity.pos(2)/speed)*speed;
                    entity.pos(1) = entity.pos(1)-speed;
                    entity.oldDir = 3;
                elseif entity.oldDir == 2 && any(possibleDirections_plus==entity.oldDir)
                    entity.pos(2) = entity.pos(2)-speed;
                elseif entity.oldDir == 4 && any(possibleDirections_minus==entity.oldDir)
                    entity.pos(2) = entity.pos(2)+speed;
                elseif entity.status > -2
                    entity.pos(2) = entity.pos(2)+speed;
                end
            case 4
                if rem(round(entity.pos(1)/speed)*speed,1) == 0 && any(possibleDirections_minus==entity.dir)
                    entity.pos(1) = round(entity.pos(1)/speed)*speed;
                    entity.pos(2) = entity.pos(2)+speed;
                    entity.oldDir = 4;
                elseif entity.oldDir == 1 && any(possibleDirections_minus==entity.oldDir)
                    entity.pos(1) = entity.pos(1)+speed;
                elseif entity.oldDir == 3 && any(possibleDirections_plus==entity.oldDir)
                    entity.pos(1) = entity.pos(1)-speed;
                elseif entity.status > -2
                    entity.pos(1) = entity.pos(1)-speed;
                end
        end
    end

    function ghostTimerFun
        if ~ghostMode.status && myTimer.TasksExecuted > ghostMode.timerValues(ghostMode.timerStatus,1) && myTimer.TasksExecuted < ghostMode.timerValues(ghostMode.timerStatus,2) 
            ghostMode.status = ~ghostMode.status;
        elseif ghostMode.status && myTimer.TasksExecuted > ghostMode.timerValues(ghostMode.timerStatus,2)
            ghostMode.timerStatus = ghostMode.timerStatus+1;
            ghostMode.status = ~ghostMode.status;
        end
    end

    function KeyAction(~,evt)
        switch evt.Key
            case {'d','rightarrow'}
                if ~autoPlay
                    pacman.dir = 1;
                end
            case {'s','downarrow'}
                if ~autoPlay
                    pacman.dir = 2;
                end
            case {'a','leftarrow'}
                if ~autoPlay
                    pacman.dir = 3;
                end
            case {'w','uparrow'}
                if ~autoPlay
                    pacman.dir = 4;
                end
            case 'p'
                if isPause
                    start(myTimer)
                    isPause = 0;
                    set(info.text,'Visible','off')
                    set(newGameButton,'Visible','off')
                    set(createGhostsButton,'Visible','off')
                    set(loadGhostsButton,'Visible','off')
                    set(createLabyButton,'Visible','off')
                    set(showHighScoresButton,'Visible','off')
                else
                    stop(myTimer)
                    isPause = 1;
                    set(info.text,'String','Press "P"','Color','w','Visible','on')
                end
            case 'h'
                stop(myTimer)
                isPause = 1;
                set(highScore.fig,'Visible','on')
                set(info.text,'String','Press "P"','Color','w','Visible','on')
            case 'm'
                stop(myTimer)
                isPause = 1;
                set(info.text,'String','Press "P"','Color','w','Visible','on')
                
                set(newGameButton,'Visible','on')
                set(createGhostsButton,'Visible','on')
                set(loadGhostsButton,'Visible','on')
                set(createLabyButton,'Visible','on')
                set(showHighScoresButton,'Visible','on')
            case 't'
                showGhostTarget = ~showGhostTarget;
            case 'q'
                autoPlay = ~autoPlay;
            case 'u'
                musicOnOff
            case 'i'
                invincible = ~invincible;
                if invincible
                    pacman.speed = 1/2;
                else
                    pacman.speed = 1/6;
                end
        end
        if strcmp(get(newGameButton,'Visible'),'on') && ~isPause
            newGameButtonFun
        end
    end

    function showHighScore
        isPause = 1;
        set(highScore.fig,'Visible','on')
    end

    function setHighscore
        allHighscores = highScore.data;
        onlyHighScores = allHighscores(:,2);
        onlyHighScores = cell2mat(onlyHighScores);
        if score.data >= onlyHighScores(end,1)
            onlyHighScores(10,1) = score.data;
            [~,sortedIndices] = sort(onlyHighScores,'descend');
            onlyHighScores = onlyHighScores(sortedIndices);
            allHighscores = allHighscores(sortedIndices,:);
            highScore.data = allHighscores;
            for kk = 1:10         
                highScore.data{kk,2} = onlyHighScores(kk);
                set(highScore.texts(kk),'String',highScore.data{kk,1})
                set(highScore.values(kk),'String',num2str(highScore.data{kk,2}))
            end
            set(highScore.texts(sortedIndices==10),'Enable','on','String','');
            uicontrol(highScore.texts(sortedIndices==10))
            showHighScore
        end
    end

    function HighScoreEdit(~,~,curRow)
        highScore.data{curRow,1} = highScore.texts(curRow).String;
        m = matfile('highScore.mat','Writable',true);
        m.HighScore = highScore.data;
        highScore.texts(curRow).Enable = 'off';
        set(info.highScoreText,'String',['High Score: ' num2str(highScore.data{1,2})])
    end

    function HighScoreCloseFcn
        set(highScore.fig,'Visible','off');
        for kk = 1:10
            highScore.data{kk,1} = highScore.texts(kk).String;
            highScore.data{kk,2} = str2double(highScore.values(kk).String);
            highScore.texts(kk).Enable = 'off';
        end
        m = matfile('HighScore.mat','Writable',true);
        m.HighScore = highScore.data;
    end
    function PacmanCloseFcn
        stop(myTimer)
        delete(myTimer)
        stop(sounds.timer_c)
        delete(sounds.timer_c)
        delete(pacman_Fig)
        delete(pacmanGhostCreator_Fig)
        delete(pacmanLabyCreator_Fig)
        delete(highScore.fig)
    end

    function UIvar = createUIcontrol(varType,varPos,varStr,varFontSize,varFont,varFColor,varBColor,varParent,varVis,varCallback)
        UIvar = uicontrol('Style',varType,...
            'units','normalized',...
            'Position',varPos,...
            'String',varStr,...
            'FontSize',varFontSize,...
            'FontName',varFont,...
            'FontUnits','normalized',...
            'ForegroundColor',varFColor,...
            'BackgroundColor',varBColor,...
            'Parent',varParent,...
            'Visible',varVis,...
            'Callback',varCallback,...
            'HorizontalAlignment','center');
    end
end