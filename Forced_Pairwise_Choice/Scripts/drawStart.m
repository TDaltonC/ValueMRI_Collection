function [ output_args ] = drawStart(w)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if exist('w','var') == 0;
    w = Screen(screenNumber, 'OpenWindow',[],[],[],[]);
end
Screen(w,'TextSize',50)
DrawFormattedText(w, 'Please wait.\n\nDo not touch anything.', 'center', 'center', [0 0 0]);

end

