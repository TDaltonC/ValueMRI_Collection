function [ output_args ] = drawChoice( itemsLeft, itemsRight, w)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
screenNumber = max(Screen('Screens'));
[width height] = Screen('WindowSize', screenNumber);


%% Defaults --- If input arguments are not provided, these gives the default values

if exist('itemsLeft','var') == 0;
    itemsLeft{1} = imread('ajuice.jpg');
    itemsLeft{2} = 0;
end

if exist('itemsRight','var') == 0;
    itemsRight{1} = 0;
    itemsRight{2} = imread('cheese.jpg');
end

if exist('w','var') == 0;
    Screen('Preference', 'SkipSyncTests', 1);
    w = Screen(screenNumber, 'OpenWindow',[],[],[],[]);
end

black = imread('black.jpg');
grey = imread('grey.jpg');


%% These are all of the position constants  

centerw = width/2;  % This the center width of the screen
centerh = height/2; % THe center of the height of the screen
eccen =   150;       % This is the eccentricity. Distance from the center to the right edge of the array
itemw =   80;       % The width of one item in the array
itemh =   140;% The hight of one item in the array
gutterw = 20;       % The width of the gutters between the items
gutterh = 20;       % The hight of the gutters between the items

devLineHeight = height*.9;  % The height of the black box inthe middle of the screen
devLineWidth  = 1;          % The width of the black box in the middle of the screen

% EVerything below here is codded in terms of the numbers above


leftSideLeftBorder = centerw - eccen;
leftSideRightBorder = centerw - eccen + itemw;
rightSideRightBorder = centerw + eccen;
rightSideLeftBorder = centerw + eccen - itemw;

topItemTopBorder = centerh - gutterh/2 - itemh;
topItemBottomBorder = centerh - gutterh/2;
bottomItemBottomBorder = centerh + gutterh/2 + itemh;
bottomItemTopBorder = centerh + gutterh/2;

leftPositions = [];
rightPositions = [];
topPositions = [];
bottomPositions = [];


%% Make all of the textures for the draw array
%Textures for the first group
%%placeholders

draw = [];
% The line that devides the the screen in half    
blackt = Screen('MakeTexture',w,black);
greyt = Screen('MakeTexture',w,grey);
draw = cat(1,draw,blackt);

for i = 1:2
    if itemsLeft{i} == 0
        draw = cat(1,draw,greyt);
    else
        tempTexture = Screen('MakeTexture',w,itemsLeft{i});
        draw = cat(1,draw, tempTexture);
    end
end

for i = 1:2
    if itemsRight{i} == 0
        draw = cat(1,draw,greyt);
    else
        tempTexture = Screen('MakeTexture',w,itemsRight{i});
        draw = cat(1,draw, tempTexture);
    end
end

%%Add all the positions
%Black T
leftPositions   = cat(2,leftPositions,  centerw - devLineWidth);
topPositions    = cat(2,topPositions,   centerh - devLineHeight/2);
rightPositions  = cat(2,rightPositions, centerw + devLineWidth);
bottomPositions = cat(2,bottomPositions,centerh + devLineHeight/2);

%Add in the item from top to bottom, left to right
leftPositions = cat(2,leftPositions, leftSideLeftBorder);
leftPositions = cat(2,leftPositions, leftSideLeftBorder);
leftPositions = cat(2,leftPositions, rightSideLeftBorder);
leftPositions = cat(2,leftPositions, rightSideLeftBorder);

rightPositions = cat(2,rightPositions, leftSideRightBorder);
rightPositions = cat(2,rightPositions, leftSideRightBorder);
rightPositions = cat(2,rightPositions, rightSideRightBorder);
rightPositions = cat(2,rightPositions, rightSideRightBorder);

topPositions = cat(2,topPositions, topItemTopBorder); 
topPositions = cat(2,topPositions, bottomItemTopBorder); 
topPositions = cat(2,topPositions, topItemTopBorder); 
topPositions = cat(2,topPositions, bottomItemTopBorder); 

bottomPositions = cat(2,bottomPositions, topItemBottomBorder);
bottomPositions = cat(2,bottomPositions, bottomItemBottomBorder);
bottomPositions = cat(2,bottomPositions, topItemBottomBorder);
bottomPositions = cat(2,bottomPositions, bottomItemBottomBorder);

v = cat(1,leftPositions,topPositions,rightPositions,bottomPositions);

   Screen('DrawTextures',w,draw,[],v)
    %Screen('Flip',w);
    %KbWait
    %Screen('CloseAll');

end

