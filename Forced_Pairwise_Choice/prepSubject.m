function [] = prepSubject(subjID,runs)
%% If not running on actual subject, use the following to test out script
% item1c = 1; item2c = 2; item3c = 3;
% item4c = 4; item5c = 5; item6c = 6;
% item7c = 7; item8c = 8; item9c = 9;
% item10c = 10; item11c = 11; item12c = 12;
% item13c = 13; item14c = 14; item15c= 15;
% item16c = 16; item17c= 17; item18c = 18;
% item19c = 19; item20c = 20; item21c = 21;

%Things to do
%Flip top & bottom randomly across all things
%Make the timing specific to the run, but keep an overall list


%% Settings
%Default for runs
if exist('runs', 'var') == 0;
    runs = 5;
end
% Default for subjID is 1. This only kicks in off on a subject ID is given.
if exist('subjID','var') == 0;
    subjID = 1;
end
if exist('input','var') == 0;
    input = 'k';
end

%%Translate Schedules to .mat && Create the ordered array
weightedArray = [];
indexes = {};
startIndex = 1; %Give it a starting point of 1
for n = 1:runs
    %% Initialize variables.
    run = int2str(n);
    filename = strcat('Sequences/ex1-00', run, '.par');
    delimiter = ' ';
    %Determine document format
    formatSpec = '%f%f%f%f%s%[^\n\r]';
    %Open file
    fileID = fopen(filename,'r');
    %Read file
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true,  'ReturnOnError', false);
    disp(dataArray{1})
    %Close file
    fclose(fileID);
    %Set variables
    time = dataArray{:, 1};
    condition = dataArray{:, 2};
    isi = dataArray{:, 3};
    VarName4 = dataArray{:, 4};
    condName = dataArray{:, 5};
    clearvars filename delimiter formatSpec fileID dataArray ans;
    runName = strcat('Run',run,'.mat');
    %Add to array of order of all conditions
    weightedArray = cat(1,weightedArray, condition);
    %Mark ending position
    temp = [startIndex, length(weightedArray)];
    indexes = cat(1,indexes,temp);
    %Set up for next loop
    startIndex = length(weightedArray)+1;
    %Save
    cd('Runs')
    save (runName);
    cd('../')
end


%% Items
%Parse the text file given to us from the GA **Imort JSON**
[single, homo, hetero, reward] = importRanking(subjID);
% single = [1,2,3,4,5,6,7,8,9,10];
% homo = [11,12,13,14,15,16,17,18,19,20];
% hetero = [21,22,23,24,25,26,27,28,29,30];

%Create the images
optionsImages = cell(21,1);
for i = 1:30;
    optionsImages{i} = imread(strcat('Images/Image', num2str(i), '.jpg'));
end

grey = imread('grey.jpg');

%% **Design the task orders**

%%Break the items into combinations
singleOptions = {};
heteroOptions = {};
homoOptions = {};

for i=1:length(single);
    temp = [single(i), 0];
    singleOptions = cat(1, singleOptions, temp);
end
for i=1:length(homo);
    temp = [homo(i), homo(i)];
    homoOptions = cat(1, homoOptions, temp);
end
% for i=1:length(hetero); %this counter needs to be going up by 2
%     if (i+1 < length(hetero)+1)
%         temp = [hetero(i), hetero(i+1)];
%     else
%         temp = [hetero(i), hetero(1)];
%     end
%     heteroOptions = cat(1, heteroOptions, temp);
% end

for i = 1:length(hetero)/2
    temp = [hetero{2*i-1}, hetero{2*i}];
    heteroOptions = cat(1, heteroOptions, temp);
end        

%Randomize arrays
rand = randperm(length(singleOptions));
singleOptions = singleOptions(rand);
rand = randperm(length(heteroOptions));
heteroOptions = heteroOptions(rand);
rand = randperm(length(homoOptions));
homoOptions = homoOptions(rand);

%Load the order from the runs
%totalTrials = runs * trialsPerRun;
%[weightedArray, inputString] = repeatedhistory(4, 3, 2);

orderedOptions = {};
singleIndex = 1;
heteroIndex = 1;
homoIndex = 1; 

%Go through the weightArray and determine the options order
for i=1:length(weightedArray);
    switch weightedArray(i)
        case 0 %NULL --This is added to keep consistency in the index between the weightArray and orderedOptions
            orderedOptions = cat(1, orderedOptions, [0,0]);
        case 1 %Single
            orderedOptions = cat(1, orderedOptions, singleOptions{singleIndex});
            singleIndex = singleIndex + 1;
            if (singleIndex > length(singleOptions))
                singleIndex = 1;
            end
        case 2 %Hetero
            orderedOptions = cat(1, orderedOptions, heteroOptions{heteroIndex});
            heteroIndex = heteroIndex + 1;
            if (heteroIndex > length(heteroOptions))
                heteroIndex = 1;
            end
        case 3 %Homo
            orderedOptions = cat(1, orderedOptions, homoOptions{homoIndex});
            homoIndex = homoIndex + 1;
            if (homoIndex > length(homoOptions))
                homoIndex = 1;
            end
    end
end

%% Random Switching
    %Randomized sideswitching of the buttons. Ints of 1 or 2. 1 is dont switch, 2 is switch.
    %Randomized for each combination - Hetero, Homo, Single.
    %Note: Not truely random. Counterbalanced by splitting the switching
    %exactly in half for each set of combinations, then randperming.
    
    %Function to make these arrays
    function array = randSwitch(weightedArray, numb)
        switchLength = nnz(weightedArray==numb); %How many times the option is in the array
        %Make Even
        if mod(switchLength,2) == 1
          switchLength = switchLength + 1;
        end;
        %Fill Array
        switchFill(1:switchLength/2,1) = 0;
        switchFill(switchLength/2+1:switchLength,1) = 1;
        %Random Perm
        randOrder = randperm(switchLength);
        array = switchFill(randOrder,1);   
    end

    switchSingle = randSwitch(weightedArray, 1);
    switchHetero = randSwitch(weightedArray, 2);
    switchHomo = randSwitch(weightedArray, 3);
    
    %Rand flipping for drawing the combinations
    flipSingle = randSwitch(weightedArray, 1);
    flipHetero = randSwitch(weightedArray, 2);
    flipHomo = randSwitch(weightedArray, 3);

%% Saving the settings

% these are the same across all runs, so no need to save them under that run's name in the settings file
settings.recordfolder = 'records';
settings.subjID = subjID;
%options
settings.orderedOptions = orderedOptions;
settings.indexes = indexes;
%arrays
settings.weightedArray = weightedArray;
settings.singleOptions = singleOptions;
settings.heteroOptions = heteroOptions;
settings.homoOptions = homoOptions;
settings.images = optionsImages;
settings.nullImage = grey;
settings.reward = reward;
settings.fixedOpt = reward;
%Randomized switching
settings.switchSingle = switchSingle;
settings.switchHetero = switchHetero;
settings.switchHomo = switchHomo;
settings.flipSingle = flipSingle;
settings.flipHetero = flipHetero;
settings.flipHomo = flipHomo;
settings.switchSingleCount = 1;
settings.switchHeteroCount = 1;
settings.switchHomoCount = 1;
settings.flipSingleCount = 1;
settings.flipHeteroCount = 1;
settings.flipHomoCount = 1;
% if the records folder doesn't exist, create it.
if settings.recordfolder
    mkdir(settings.recordfolder);
end
recordname = [settings.recordfolder '/' num2str(subjID) '_globalSettings' '.mat'];
% Save the settings (the results are saved later)
save (recordname, 'settings')
end
