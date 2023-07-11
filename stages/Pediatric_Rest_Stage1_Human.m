clear all global
close all

usepath = '/srv/Preprocessing/Pediatric_Rest/v1_HUMAN/Stage0/';
outpath = '/srv/Preprocessing/Pediatric_Rest/v1_HUMAN/Stage1/';

files_to_use = dir(fullfile((usepath),'*.set'));

for i=1:length(files_to_use)
    clearvars -except usepath outpath files_to_use i ninety_chanlocs
    clear global
    eeglab

    EEG = pop_loadset('filepath',usepath,'filename',files_to_use(i).name);
    [ALLEEG EEG CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG = eeg_checkset( EEG );

    % save preproc info
    EEG.Preproc.when_Stage1=datestr(datetime+hours(8));
    EEG.Preproc.how_Stage1 = 'Pediatric_Rest_Stage0_Human.m';


    % remove stuff
    pop_eegplot( EEG, 1, 1, 1);
    eeglab redraw

    fprintf('\n\nWhen you are done removing bad data and bad channels, type Y then enter.     \n');

    while(1)
        m=input('Do you want to continue, enter Y or N: \n','s')
        if m=='Y' | m=='y'
            break
        end
    end

    % save post manual trim
    pop_saveset(EEG, 'filename', sprintf('%s_postTRIM', EEG.subject(1:end-4)), 'filepath', outpath);

    movefile([files_to_use(i).folder '/' files_to_use(i).name],[usepath '/completed/']);
    movefile([files_to_use(i).folder '/' files_to_use(i).name(1:end-4) '.fdt'],[usepath '/completed/']);

end