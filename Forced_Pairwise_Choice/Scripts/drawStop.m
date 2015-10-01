function [ output_args ] = drawBreak( w )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if exist('w','var') == 0;
    screenNumber = max(Screen('Screens'));
    w = Screen(screenNumber, 'OpenWindow',[],[],[],[]);
end
Screen(w,'TextSize',50)
DrawFormattedText(w, 'Break', 'center', 'center', [0 0 0]);

end

