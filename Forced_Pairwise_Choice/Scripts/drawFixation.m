function [ output_args ] = drawFixation(w)

% Simple -- It draws a fixation cross on the off screen window.
screenNumber = max(Screen('Screens'));
[width height] = Screen('WindowSize', screenNumber);
rect = [0,0,width,height];
[X,Y] = RectCenter(rect);
FixCross = [X-1,Y-40,X+1,Y+40;X-40,Y-1,X+40,Y+1];
Screen('FillRect', w, [0,0,0], FixCross');

end


