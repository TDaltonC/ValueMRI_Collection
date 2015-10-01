function [] = fourSquaresLogic(itemTop, itemBottom, w, width, height, switching, flipping)
%   Notes:
%       -Make the squares larger
%       -Aspect ratio
%       -Center the squares

if flipping
    textureTop = Screen('MakeTexture',w,itemTop);
    textureBottom = Screen('MakeTexture',w,itemBottom);
else
    textureTop = Screen('MakeTexture', w, itemBottom);
    textureBottom = Screen('MakeTexture',w,itemTop);
end;

%% load textures for the items -- flipping is handled by runPrepedSubject
%textureTop = Screen('MakeTexture',w,itemTop);
%textureBottom = Screen('MakeTexture',w,itemBottom); 

%% These are all of the position constants
centerw = width/2;  % This is the center width of the screen
thirdHeight = height/3; % The height of the first third
cueHeight = height*.4; %2/5ths height of the screen
twoThirdHeight = 2 * height/3; % height of the second third
%eccen =   150;      % This is the eccentricity. Distance from the center to the right edge of the array
itemw =   .6*height/5;       % The width of one item in the array
itemh =   height/5;       % The height of one item in the array
gutterw = 40;       % The height of the gutters between the items
gutterh = height/20;       % The height of the gutters between the items

%Left and Right are the same for both items
itemLeft = centerw - (itemw*0.5);
itemRight = centerw + (itemw*0.5);

%Top Item -top and bottom
topItemTop = cueHeight - gutterh - itemh;
topItemBottom = cueHeight - gutterh;

%Bottom Item - top and bottom
bottomItemBottom = cueHeight + gutterh + itemh;
bottomItemTop = cueHeight + gutterh;

% response cue position coordinates
leftCueLeft = centerw - 3*gutterw;
leftCueRight = centerw - 1*gutterw;
rightCueLeft = centerw + 1*gutterw;
rightCueRight = centerw + 3*gutterw;

%Left and right cue share the same top
% cueTop = twoThirdHeight + itemh;
% cueBottom = cueTop + 2*gutterw;
cueBottom = height -  gutterw;
cueTop = cueBottom - 2*gutterw;

leftCueRect = [leftCueLeft, cueTop, leftCueRight, cueBottom];
rightCueRect = [rightCueLeft, cueTop, rightCueRight, cueBottom];

black = 0;
if switching == 1; %SWITCH. Left circle black, right circle white
    Screen('FillOval',w,black,leftCueRect);
    Screen('FrameOval',w,black,rightCueRect,2); %pen width is 2
else %DON'T SWITCH. Left circle white, white circle black
    Screen('FillOval',w,black,rightCueRect);
    Screen('FrameOval',w,black,leftCueRect,2); %pen width is 2
end

% These are here so that the cat()'s will have something to grab on to.

draw = [];
leftPositions = [];
topPositions = [];
rightPositions = [];
bottomPositions = [];

%Add the textures to the draw
draw = cat(1,draw,textureTop);
draw = cat(1,draw,textureBottom);

%Left and right are the same for both
leftPositions = cat(2,leftPositions,    itemLeft);
leftPositions = cat(2,leftPositions,    itemLeft);
rightPositions = cat(2,rightPositions,  itemRight);
rightPositions = cat(2,rightPositions,  itemRight);

%Add the different top and bottom positions
topPositions = cat(2, topPositions, topItemTop);
topPositions = cat(2, topPositions, bottomItemTop);
bottomPositions = cat(2, bottomPositions, topItemBottom);
bottomPositions = cat(2, bottomPositions, bottomItemBottom);

%%Draw
v = cat(1,leftPositions,topPositions,rightPositions,bottomPositions);
Screen('DrawTextures',w,draw,[],v);

end

