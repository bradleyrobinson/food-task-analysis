%%data.p1 = dlmread('C:\Users\bradl\Documents\MATLAB\EEG-pilot1-D.txt', '\t', 0, 1);
% data.p1(:,end) = [];
clear all;
cd 'C:\Users\bradl\Documents\MATLAB\dissonance\';
%%
d = dir('TP*.txt');
subjects = [];
for sub=1:length(d);
    subjects = [subjects; {d(sub).name}];
end;
% If you are working with multiple folders this can help:
% test = strcat('pathfolder', subjects);


data.channels = [];
temp.channels = {'AF3', 'F7', 'F3', 'FC5', 'T7', 'P7', 'O1', 'O2', 'P8', 'T8', 'FC6', 'F4', 'F8', 'AF4'}';
data.p = [];
temp.p = [];
data.outcome = [];
temp.outcome = [];
%%
for x=1:length(subjects);
    try
       temp.p = dlmread(subjects{x}, '\t', 0, 1);
       % Clean out the last line
       temp.p(:,end) = [];
       % Separate the time, then remove it
       data.time = temp.p(1,:);
       temp.p(1,:) = [];

       % Concatenate the data
       data.p = [data.p; temp.p];

       % Outcome type
       temp.outcome = repmat({subjects{x}(6:7)}, [14 1]);

       data.outcome = [data.outcome; temp.outcome];

       data.channels = [data.channels; temp.channels];
    catch exception
        disp('Cannot load or concatenate data');
    end
end


figure;
% All of them
g = gramm ('x', data.time, 'y', data.p, 'color', data.outcome);
g.axe_property('ylim', [-15 15], 'xlim', [300 400])
g.facet_wrap(data.channels, 'ncols', 5);
g.stat_summary();
g.draw();

% Mean activation
% g = gramm ( 'x', data.time, 'y',  mean(data.p));
%g.axe_property('ylim', [-15 15], 'xlim', [250 450])
%g.facet_wrap(data.channels, 'ncols', 5);
%g.stat_summary();
%g.draw();




% Only FC5 and FC6
figure;
g = gramm ('x', data.time, 'y', data.p(ismember(data.channels, {'FC5', 'FC6', 'F7', 'F8'}),:), 'color', data.outcome(ismember(data.channels, {'FC5', 'FC6', 'F7', 'F8'})));
g.axe_property('ylim', [-20 20], 'xlim', [300 400])
g.geom_hline('yintercept',0);
g.geom_vline('xintercept',0);
g.facet_wrap(data.channels(ismember(data.channels, {'FC5', 'FC6', 'F7', 'F8'})), 'ncols', 2);
g.stat_summary();
g.draw();
%% Windows 1500-2500, we want to 
% Rating: Change, no change
% Laterality: left: odd right: even
% Channels: F3, F7, FC5, FC6, F4, F8

% We want to code:
rating = {'HD', 'LD'};
channels = {'F3', 'F7', 'FC5', 'FC6', 'F4', 'F8', 'P7', 'P8'};

for x=1:length(rating);
   for y=1:length(channels);
       try
           stats_export.headers = [stats_export.headers {strcat(rating{x}, '.', channels{y})}];
       catch exception;
           stats_export.headers = [{strcat(rating{x}, '.', channels{y})}];
       end
       try
            stats_export.values = [stats_export.values mean(data.p((ismember(data.outcome, rating{x}) & ismember(data.channels, channels{y})), 411:end), 2)];
        catch exception;
            stats_export.values = [mean(data.p((ismember(data.outcome, rating{x}) & ismember(data.channels, channels{y})), 411:end), 2)];
        end
   end
end
%%
stats_export.JASP = [stats_export.headers; num2cell(stats_export.values)];
cell2csv('C:\Users\bradl\Documents\MATLAB\Processed_data\dissonance_data_3_to_4s.csv', stats_export.JASP);
%%
%onset of decision [-500 3000], that is one way to cut the data
% you have both cooperate and defect
%onset of outcome [-500 1000] - though we should check the behavioral data
% You have four outcomes (T, R, P, S)

% Grouping variables
% dislike (pretest: 1-3)
% neutral (pretest: 4-6)
% like (pretest: 7-9)
% Breaking things into sets: if you look at cooperation, you just havve
% that
% Same thing with like/dislike/neutral
% Freq analysis can be detailed or broad, i.e. any ERP analysis you run, 
% You want to do a theta power analysis (look up EEG theta papers + cog dissonance)
% alpha power analysis, and beta power analysis (papers on all of these)
% H.w. up until dead week, start working on this and e-mail on a weekly
% basis, try for one analysis a day?



%%Homework (12/8)
% Cognitive dissonant changes, and lateralization of the brain? Is it
% possible that it is a factor? 


%Abstract: focus on the methods, and the behavior (how was the data
%divided?) Analyzed the changes in the rating in EEG, current results
%suggest a laterality, left lateralization shows greater activity for no
%change over change, whereas right lateralization shows greater activity
%for change over no change.