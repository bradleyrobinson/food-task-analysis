%% Loading and Filtering
% Load a raw EMOTIV EEG data file, convert into EEGLAB structure, then
% filter
% This is the actual script, I'll rename it soon.
% clears everything out of the workspace
clear all;

%% User input
folder = 'C:\Users\bradl\Documents\MATLAB\';
subjects_file = dir(strcat(folder, 'valid_participants.csv'));
subjects = csvimport(subjects_file.name);
Ss = subjects(2:end,2);

for P = 1:length(Ss);
    temp_folder = strcat(folder, Ss{P});
    try
        % Sometimes folder naming is inconsistent, so this tries TP** and 
        % if that doesn't work, it tries P**
        cd(temp_folder);
    catch
        s_name = Ss{P}(2:4);
        temp_folder = strcat(folder, s_name);
    end
    try
        cd(temp_folder);
        eegfile = dir('*.set');
        if length(eegfile) < 1;
            a = b;
        else
            EEG = pop_loadset(eegfile.name);
        end;
    catch
        cd(temp_folder);
        eegfile = dir('*.edf');
        EEG = eeglab;
        disp(eegfile);
        % Loads raw data
        EEG = pop_biosig(eegfile.name, 'channels',[3:16 36]);
        
        % Loads channel locations
        EEG=pop_chanedit(EEG, 'lookup','C:\\Users\\bradl\\Documents\\MATLAB\\eeglab13_6_5b\\plugins\\dipfit2.3\\standard_BESA\\standard-10-5-cap385.elp');
        
        % Change set name to participant name
        EEG.setname = Ss;
        
        % crop down the files so we're only looking at markered data
        EEG = pop_select(EEG, 'point',[(EEG.event(1).latency)-128 (EEG.event(end).latency)+7700]);
        
        % Filters data
        EEG = pop_eegfiltnew(EEG, 59, 0.01);
        
        % re-reference to average ref
        EEG = pop_reref(EEG, []);
        
        % Runs ICA
        EEG = pop_runica(EEG, 'icatype', 'runica');
        
        % Manually reject components from ICA
        EEG = pop_selectcomps(EEG, [1:14]);
        
        % checks for consistency after all the changes we've made up to now
        % EEG = eeg_checkset( EEG );
        
        % plots filtered data
        % pop_eegplot( EEG, 1, 1, 1);
        
        
        
        
        % creates events via epochs
        % parse data into selected events (events we care about only)
        % save and export
        % reject artifactual data via algorithm (1. by hand and 2. by code)
        % ICA
        % save and export
        
        eeglab redraw;
        keyboard;
    end;
    % Load in the behavioral data
    d = dir('dis*.csv');
    behavior = csvimport(d.name);
    % Iterate over the events
    % TODO: Change this to look at both prep screen and choice screen
    idx = 2;
    numberScreens = 0;
    for eventItem = 1:length(EEG.event);
        if strcmp(EEG.event(eventItem).type, '68') == 1;
            if numberScreens > 0;
                try
                    EEG.event(eventItem).type = behavior{idx, 3};
                catch
                end;
                idx = idx + 1;
            else
                numberScreens = numberScreens + 1;
            end
        end
    end
    
    
    % Breaks the dataset into epochs
    EEG = pop_epoch(EEG, {'TRUE', 'FALSE'}, [-.2 4]);
    % Remove the baseline
    EEG = pop_rmbase(EEG, [-200 0]);
    %% reject data by algorithm
    EEG = pop_jointprob(EEG, 1, [1:14], 3, 3);
    EEG = pop_rejkurt(EEG, 1, [1:14], 3, 3);
    
    %%  Export the data!
    
    % Make a copy of EEG
    masterEEG = EEG;
    %% 
    EEG = pop_selectevent(masterEEG, 'event', [,]);
    pop_export(EEG, strcat(folder, 'dissonance\test\', Ss{P}, '.txt'), 'erp', 'on', 'precision', 6);

    %% Break dataset more; save pieces of the dataset test stuff
    
    EEG = pop_selectevent(masterEEG, 'type', {'TRUE'});
    pop_export(EEG,  strcat(folder, 'dissonance\', Ss{P}, '-HD.txt'), 'erp', 'on', 'precision', 6);
    
    %% Break it to cooperate
    
    EEG = pop_selectevent(masterEEG, 'type', {'FALSE'});
    pop_export(EEG,  strcat(folder, 'dissonance\', Ss{P}, '-LD.txt'), 'erp', 'on', 'precision', 6);
    eeglab redraw;
    
    
    %%
    % Notes: Within subject, grouped by rating change, no rating change,
    % Repeated measures ANOVA, from each channel for every person, multiplied
    % by amt of behaviors that are being looked at. During prep screen, is
    % there activity that is different for change vs. no change. ERP analysis,
    % or frequency analysis. Prediction: theta will occur in windows when they
    % make they change rating. Alpha will be more present when it doesn't.
    % We'll just look at the prep screen, choice should be confirming the prep
    % screen
    % Now we need to label the choices
    
end