cd('/Users/Dalton/Documents/Projects/BundledOptionsExp/BehavioralValueMeasurements')


records = dir('records/a*.mat');

% Create all of the variables were going to need
optSIDs = [];
elicitedRanks = [];
itemCounts = [];
types = [];
item1s = [];
item2s = [];
valueLBUBSUMs = [];
valueLBUBs = [];
valueLBs = [];
values = [];

respSIDs = [];
reactionTimes = [];
opt1item1s = [];
opt1item2s = [];
opt2item1s = [];
opt2item2s  = [];
switchLRs = [];
switchTB1s = [];
switchTB2s = [];
opt1Codes = [];
opt2Codes = [];
chosenOpts = [];
opt1Types = [];
opt2Types = [];
opt1Values = [];
opt2Values = [];
opt1Ranks = [];
opt2Ranks = [];


for record = [1:10]
    clearvars itemCount type item1 item2 opt1item1 opt1item2 opt2item1 opt2item2 opt1Code opt2Code chosenOpt opt1Type opt2Type opt1Value opt2Value opt1Rank opt2Rank
    load('records/BlankRecord.mat');

    % Set the simulated responses (behavioral.keys) to be a random permutation of 1's and 2's
    % at a fixed ratio (specified by thier error)
    
    %% Options DataFame
    elicitedRank = 1:numel(settings.allOptions);
    for i = elicitedRank
        item1(i) = settings.allOptions{1, i}(1);
        try
            item2(i) = settings.allOptions{1, i}(2);
            itemCount(i) = 2;
            if settings.allOptions{1, i}(2) == settings.allOptions{1, i}(1)
                type(i) = 2;
            else
                type(i) = 3;
            end
        catch
            item2(i) = 0;
            itemCount(i) = 1;
            type(i) = 1;
        end
    end
    optSID = cell(numel(settings.allOptions),1);
    optSID(:) = {settings.subjID};

    %% Responses DataFrame

    for i = 1:numel(settings.taskAll);
        opt1item1(i) = settings.taskAll{i}{1}{1}(1);
        try
            opt1item2(i) = settings.taskAll{i}{1}{1}(2);
        catch
            opt1item2(i) = 0;
        end
        opt2item1(i) = settings.taskAll{i}{1}{2}{1}(1);
        try
            opt2item2(i) = settings.taskAll{i}{1}{2}{1}(2);
        catch
            opt2item2(i) = 0;
        end
        for rank = elicitedRank 
            if  [item1(rank),item2(rank)] == [opt1item1(i),opt1item2(i)]
                opt1Code(i) = rank;
                break
            end
        end
        for rank = elicitedRank 
            if  [item1(rank),item2(rank)] == [opt2item1(i),opt2item2(i)]
                opt2Code(i) = rank;
                break
            end
        end       
    end

    switchLR = settings.switchLR;
    switchTB1 = settings.switchTB(1,:);
    switchTB2 = settings.switchTB(2,:);

    choiceLR = behavioral.key;
    for i = 1:numel(choiceLR)
        if choiceLR(i) == 'f'
            if switchLR(i) == 0
                chosenOpt(i) = 1;
            elseif switchLR(i) == 1
                chosenOpt(i) = 2;
            end
        elseif choiceLR(i) == 'j'
            if switchLR(i) == 0
                chosenOpt(i) = 2;
            elseif switchLR(i) == 1
                chosenOpt(i) = 1;
            end
        end
    end
    respSID = cell(numel(settings.taskAll),1);
    respSID(:) = {settings.subjID};
    reactionTime = behavioral.secs;

    %% Estimate Values
    [a,b,valueLBUBSUM,d,e] = MLEValue(opt1Code,opt2Code,chosenOpt,0,1,1,1);
    [a,b,valueLBUB,d,e]    = MLEValue(opt1Code,opt2Code,chosenOpt,-1,1);
    [a,b,valueLB,d,e]      = MLEValue(opt1Code,opt2Code,chosenOpt,0);
    [a,b,value,d,e]        = MLEValue(opt1Code,opt2Code,chosenOpt,[],[],0,0);

    %% More Resonse things
    opt1Type = type(opt1Code);
    opt2Type = type(opt2Code);
    
    opt1Value = valueLB(opt1Code);
    opt2Value = valueLB(opt2Code);

    opt1Rank = elicitedRank(opt1Code);
    opt2Rank = elicitedRank(opt2Code);
    
    
    %% Stick the data from this loop to the date from the previous loops
    optSIDs = [optSIDs; optSID];
    elicitedRanks = [elicitedRanks, elicitedRank];
    itemCounts = [itemCounts,itemCount];
    types = [types,type];
    item1s = [item1s,item1];
    item2s = [item2s,item2];
    valueLBUBSUMs = [valueLBUBSUMs;valueLBUBSUM];
    valueLBUBs = [valueLBUBs;valueLBUB];
    valueLBs = [valueLBs;valueLB];
    values = [values;value];

    respSIDs = [respSIDs;respSID];
    reactionTimes = [reactionTimes;reactionTime];
    opt1item1s = [opt1item1s,opt1item1];
    opt1item2s = [opt1item2s,opt1item2];
    opt2item1s = [opt2item1s,opt2item1];
    opt2item2s = [opt2item2s,opt2item2];
    switchLRs = [switchLRs,switchLR];
    switchTB1s = [switchTB1s,switchTB1];
    switchTB2s = [switchTB2s,switchTB2];
    opt1Codes = [opt1Codes,opt1Code];
    opt2Codes = [opt2Codes,opt2Code];
    chosenOpts = [chosenOpts,chosenOpt];
    opt1Types = [opt1Types,opt1Type];
    opt2Types = [opt2Types,opt2Type];
    opt1Values = [opt1Values;opt1Value];
    opt2Values = [opt2Values;opt2Value];
    opt1Ranks = [opt1Ranks,opt1Rank];
    opt2Ranks = [opt2Ranks,opt2Rank];
    
    
end
%% Save the two dataframes
cd('records');
options = table(  [1:length(optSIDs)]', optSIDs  ,elicitedRanks' ,itemCounts' ,types' ,item1s' ,item2s', valueLBUBSUMs,  valueLBUBs,  valueLBs,  values,...
    'VariableNames',{'index'              'SID'  'elicitedRank'  'itemCount'  'type'  'item1'  'item2', 'valueLBUBSUM', 'valueLBUB', 'valueLB', 'value'});
writetable(options,'options.csv');

responses = table(  [1:length(respSIDs)]',  respSIDs  ,reactionTimes  ,opt1item1s' ,opt1item2s' ,opt2item1s' ,opt2item2s' ,switchLRs' ,switchTB1s' ,switchTB2s', opt1Codes', opt2Codes', chosenOpts', opt1Types', opt2Types', opt1Values, opt2Values, opt1Ranks', opt2Ranks',...
    'VariableNames',{ 'index',                 'SID'  'reactionTime'  'opt1item1'  'opt1item2'  'opt2item1'  'opt2item2'  'switchLR'  'switchTB1'  'switchTB2'  'opt1Code'  'opt2Code'  'chosenOpt'  'opt1Type'  'opt2Type'  'opt1Value'  'opt2Value'  'opt1Rank'  'opt2Rank'});
writetable(responses,'responses.csv');



