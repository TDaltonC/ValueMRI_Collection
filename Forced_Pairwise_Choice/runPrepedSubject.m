function [] = runPrepedSubject(subjID, j)
%% Load Everything

if exist('subjID','var') == 0;
    subjID = 1;
end

if exist('j','var') == 0;
    j = 1;
end


Screen('Preference', 'SkipSyncTests', 1 );

recordfolder = 'records';
load([recordfolder '/' num2str(subjID) '_globalSettings' '.mat']);
itemImages = settings.images;
settings.run = j;
settings.task = 'OnScreenOffScreen';

%% Setting up the Run
load(strcat('Run',num2str(j),'.mat'));
trialOrder = settings.orderedOptions(settings.indexes{j}(1):settings.indexes{j}(2));
%Index to start looking at the combination arrays
combinationIndex = settings.indexes{j}(1); 
%Index to manage the run loop
currentIndex = 1;
%Run Trials
trialLength = length(trialOrder);
%get the order
weightedOrder = settings.weightedArray;

%% Set up the screen
screenNumber = max(Screen('Screens'));
[width,height] = Screen('WindowSize', screenNumber);

w = Screen('OpenWindow', screenNumber,[],[],[],[]);

% Display "Please wait. Do not touch anything"
drawStart(w);
Screen('Flip',w);

%James' code for scanner cue 
key = 0;
while key ~= '5'
    [keyisdown, StartSecs, keycode] = KbCheck();
    if keyisdown
        key = KbName(keycode);  
    end
end 
UT = GetSecs;
settings.UT = UT;
% create the file name for this run of this subject
recordname = [settings.recordfolder '/' num2str(subjID) '_' num2str(j) '_' datestr(now,'yyyymmddTHHMMSS') '.mat'];
textFileName = [settings.recordfolder '/' num2str(subjID) '_' num2str(j) '_' datestr(now,'yyyymmddTHHMMSS') '.txt'];
% Save the settings (the results are saved later)
save (recordname, 'settings')
fileID = fopen(textFileName, 'w');

%Feedback Time
feedbackTime = 0.25;

whenTime = zeros(length(time),1);
for k = 1:(length(time))
    whenTime(k,1) = UT + 4 + time(k);
end

%whenTime(length(time)+1,1) = UT + j*10 + 324 + time(k);

RestrictKeysForKbCheck([30, 31, 32, 33]); % these are the keycodes for 1,2,3,4 on a Mac
% RestrictKeysForKbCheck([49, 50, 51, 52]); % these are the keycodes for 1,2,3,4 on a Windows

while currentIndex <= trialLength;
   
    %Draw Textures for trial
    if weightedOrder(combinationIndex) == 0; %%If null, draw fixation
        drawFixation(w);
    else %If either single, hetero, or homo then pick textures
        if trialOrder{currentIndex}(1) ~= 0;
          top = itemImages{trialOrder{currentIndex}(1)};
        else
            top = settings.nullImage;
        end
        if trialOrder{currentIndex}(2) ~= 0;
            bottom = itemImages{trialOrder{currentIndex}(2)};
        else
            bottom = settings.nullImage;
        end
        %Determine if switching
        switch weightedOrder(combinationIndex)
            case 1%Single
                shouldSwitch = settings.switchSingle(settings.switchSingleCount);
                settings.switchSingleCount = settings.switchSingleCount + 1;
                shouldFlip = settings.flipSingle(settings.flipSingleCount);
                settings.flipSingleCount = settings.flipSingleCount + 1;
            case 2%Hetero
                shouldSwitch = settings.switchHetero(settings.switchHeteroCount);
                settings.switchHeteroCount = settings.switchHeteroCount + 1;
                shouldFlip = settings.flipHetero(settings.flipHeteroCount);
                settings.flipHeteroCount = settings.flipHeteroCount + 1;
            case 3%Homo
                shouldSwitch = settings.switchHomo(settings.switchHomoCount);
                settings.switchHomoCount = settings.switchHomoCount + 1;
                shouldFlip = settings.flipHomo(settings.flipHomoCount);
                settings.flipHomoCount = settings.flipHomoCount + 1;
        end
        %Draw the textures
        fourSquaresLogic(top,bottom, w, width, height, shouldSwitch, shouldFlip); 
    end;
    
    %fprintf(fileID,'%d\t%d\t',caseNumber,setNumber);

    %Flip the screen
    [VBLTimestamp, StimulusOnsetTime, FlipTimestamp] = Screen('Flip', w, whenTime(currentIndex,1));
    settings.VBLTimestamp(currentIndex) = VBLTimestamp - StartSecs;
    settings.StimulusOnsetTime(currentIndex) = StimulusOnsetTime - StartSecs;
    settings.FlipTimestamp(currentIndex) = FlipTimestamp - StartSecs;

    %Response
    if weightedOrder(combinationIndex) == 0  % if the condition is the NULL condition (i.e. fixation cross), then show keep the fixation cross displayed for the amount of time, specified by variable "isi" -- an optseq output
        WaitSecs(isi(currentIndex))
        responseAt = whenTime(currentIndex,1)+isi(currentIndex);
        behavioral.secs(currentIndex) = responseAt - StimulusOnsetTime;
    elseif weightedOrder(combinationIndex) > 0 % for all conditions except for the NULL, 
                             % keep display on screen until subject presses
                             % button or 4 seconds is up (whichever happens 
                             % first) and record button press in the former case   
        [responseAt, keyCode, behavioral.deltaSecs(currentIndex)] = KbWait(-1,0,(whenTime(currentIndex,1)+4));
        behavioral.secs(currentIndex) = responseAt - StimulusOnsetTime;
        %WHITE IS ON-SCREEN! BLACK IS OFF-SCREEN. If switch is 0, then black
        %(off) is right and white (on) is left. Else switch is 1, black (off)
        %is right
        if (strcmp(KbName(keyCode),'1!') || strcmp(KbName(keyCode),'2@'));
            if shouldSwitch
                behavioral.choice(currentIndex,1) = 'o';
            else
                behavioral.choice(currentIndex,1) = 's';
            end    
            behavioral.key(currentIndex,1) = '1';
            feedbackLogic('1',top, bottom, w, shouldSwitch, shouldFlip);
            Screen('Flip',w);
            drawFixation(w);
            Screen('Flip',w,behavioral.secs(currentIndex)+feedbackTime);
        elseif (strcmp(KbName(keyCode),'3#') || strcmp(KbName(keyCode),'4$'));
            if shouldSwitch
                behavioral.choice(currentIndex,1) = 's';
            else
                behavioral.choice(currentIndex,1) = 'o';
            end    
            behavioral.key(currentIndex,1) = '3';
            feedbackLogic('3',top, bottom,w, shouldSwitch, shouldFlip);            
            Screen('Flip',w);
            drawFixation(w);
            Screen('Flip',w,behavioral.secs(currentIndex)+feedbackTime);
        else
            drawFixation(w);
            Screen('Flip',w);
            behavioral.key(currentIndex,1) = '0';
            behavioral.choice(currentIndex,1) = 'n';
        end 
    end
    fprintf(fileID,'%f\t%f\n',StimulusOnsetTime-UT, behavioral.secs(currentIndex)-StimulusOnsetTime);
    currentIndex = currentIndex + 1;
    combinationIndex = combinationIndex + 1;
end
%% at the end
drawStop(w);
Screen('Flip',w);
save (recordname, 'settings');
save (recordname, 'behavioral', '-append');
fclose(fileID);
Screen('CloseAll');
clear all;
end