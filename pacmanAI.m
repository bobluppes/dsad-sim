function targetSquare = pacmanAI(pacman,enemies,allDirections,coins,pills)

% targetSquare = pacmanAI(pacman,enemies,allDirections)
% 
%% Input:
% pacman: struct-array with all of the pacman information
% pacman.pos: current position [x,y]
% 
% enemies: struct-array with all of the ghosts information
% enemies(1).pos: current position of ghost No.1 [x,y]     
% enemies(2).pos: current position of ghost No.2 [x,y]    
% enemies(3).pos: current position of ghost No.3 [x,y]    
% enemies(4).pos: current position of ghost No.4 [x,y]    
%
% allDirections: cell-array with all possible moves for each tile in the game
%
% coins: struct-array with all of the coins information
%
% pills: struct-array with all of the pills information
%
%% Output:
% targetSquare: this is the tile where pacman is sent to after this function is done
%
%
%% Nested functions:
% curSquare = findSquare(entity,dir):
% returns the current tile a ghost or pacman (entity) is at right now
%
% possibleMoves = allPossibleMoves(entity):
% returns all possible moves the entity (pacman or ghost) can go to at its current position

%% AI
% This part can be changed completely
    allDist = 100*ones(4,2);
    for nn = 1:4 
        if enemies(nn).status == 1
            allDist(nn,1) = norm(pacman.pos-enemies(nn).pos);
        elseif enemies(nn).status == 2
            allDist(nn,2) = norm(pacman.pos-enemies(nn).pos);
        end
    end

    [minDist1,minDist1_Index] = min(allDist(:,1));
    [minDist2,minDist2_Index] = min(allDist(:,2));
    if minDist2 == 100 || minDist1 <= minDist2
        curDist = pacman.pos-enemies(minDist1_Index).pos;
        if norm(curDist) < 5
            if rand < 0.01 || pacman.pos(1) <= 2 || pacman.pos(1) >= 30
                pacman.curAutoDir = (-1+2*round(rand))*round(rand(1,2));
            end
            curSquare2 = pacman.pos + pacman.curAutoDir;
        else
            if curDist(1) >= 0 && curDist(2) > 0
                curSquare2 = enemies(minDist1_Index).pos + [6 -6]*2;
            elseif curDist(1) <= 0 && curDist(2) < 0
                curSquare2 = enemies(minDist1_Index).pos + [-6 6]*2;
            elseif curDist(1) >= 0 && curDist(2) < 0
                curSquare2 = enemies(minDist1_Index).pos + [-6 -6]*2;
            elseif curDist(1) <= 0 && curDist(2) > 0
                curSquare2 = enemies(minDist1_Index).pos + [6 6]*2;
            else
                if rand < 0.01 || pacman.pos(1) <= 2 || pacman.pos(1) >= 30
                    pacman.curAutoDir = (-1+2*round(rand))*round(rand(1,2));
                end
                curSquare2 = pacman.pos + pacman.curAutoDir;
            end
        end
    else
        curSquare2 = enemies(minDist2_Index).pos;
    end

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
    
    
    targetSquare = curSquare2;
    
    
%% Nested Functions
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
end