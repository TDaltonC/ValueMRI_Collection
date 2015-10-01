function [] = feedbackLogic(key,itemTop, itemBottom, w, switching, flipping)
disp('feedback')
screenNumber = max(Screen('Screens'));
[width, height] = Screen('WindowSize', screenNumber);

%% These are all of the position constants
% centerw = width/2;  % This is the center width of the screen
% thirdHeight = height/3; % The height of the first third
% twoThirdHeight = 2 * height/3; 
% centerh = height/2; % The center of the height of the screen
% %eccen =   150;      % This is the eccentricity. Distance from the center to the right edge of the array
% itemw =   130;       % The width of one item in the array
% itemh =   240;       % The height of one item in the array
% gutterw = 40;       % The height of the gutters between the items
% gutterh = 40;       % The height of the gutters between the items
centerw = width/2;  % This is the center width of the screen
thirdHeight = height/3; % The height of the first third
cueHeight = height*.4; %2/5ths height of the screen
twoThirdHeight = 2 * height/3; % height of the second third
%eccen =   150;      % This is the eccentricity. Distance from the center to the right edge of the array
itemw =   .6*height/5;       % The width of one item in the array
itemh =   height/5;       % The height of one item in the array
gutterw = 40;       % The height of the gutters between the items
gutterh = height/20;       % The height of the gutters between the items



if key == '1'
    feedbackPosition = 1;
elseif key == '3'
    feedbackPosition = 2;
end

pwCueL1 = centerw - 3*gutterw;
pwCueL2 = centerw - 1*gutterw;
pwCueR1 = centerw + 1*gutterw;
pwCueR2 = centerw + 3*gutterw;

% phCue1 = twoThirdHeight + itemh;
% phCue2 = phCue1 + 2*gutterw;

phCue2 = height -  gutterw;
phCue1 = phCue2 - 2*gutterw;

pwCue1 = [pwCueL1, pwCueR1];
pwCue2 = [pwCueL2, pwCueR2];
phCue1 = [phCue1, phCue1];
phCue2 = [phCue2, phCue2];

feedbackRect = [pwCue1(feedbackPosition),phCue1(feedbackPosition),...
    pwCue2(feedbackPosition),phCue2(feedbackPosition)];

Screen('FrameRect',w,0,feedbackRect,2);

fourSquaresLogic(itemTop, itemBottom, w, width, height, switching, flipping);

end

