function [] = generateOrder()
cd('Sequences')

%Helpful Youtube link: https://www.youtube.com/watch?v=MIx_PN4FkKk
%for getting up to speed quickly
%Documentation: http://surfer.nmr.mgh.harvard.edu/optseq/optseq2.help.txt

%%This script will generate the order of the events to be shown to the
%%participants

%IMPORTANT: Include a space at the beginning of every string except for the
%first one

%Path: Where the exec is located
execPath = '/usr/local/bin/optseq2';
%Number of time points in scan
ntp = ' --ntp 162';
%Time between volumes
tr = ' --tr 2';
%Least and Most time btw conditions
psdwin = ' --psdwin 0 20 .5';
%Events --You can add more, just add to the concat **DONT INCLUDE NULL**
eventOne = ' --ev single 4.5 20';
eventTwo = ' --ev homo 4.5 20';
eventThree = ' --ev hetero 4.5 20';
%Number of runs
nkeep = ' --nkeep 5';
%Outsteam
o = ' --o ex1';
%Nsearch
nsearch = ' --nsearch 10000';
%FOCB
focb = ' --focb 2';

%Concat strings into command string
command = strcat(execPath, ntp, tr, psdwin, eventOne, eventTwo, eventThree, nkeep, o, nsearch, focb);

%Run command. This will create the necessary files in the directory
[status, output] = unix(command);
cd('../')
end



