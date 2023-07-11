clear all global
close all

usepath = '/srv/Preprocessing/Pediatric_Rest/imported_data/';
outpath = '/srv/Preprocessing/Pediatric_Rest/v1_HUMAN/Stage0/';

files_to_use = dir(fullfile((usepath),'*.set'));

load("ninety_chanlocs.mat");


for i=1:length(files_to_use)
    clearvars -except usepath outpath files_to_use i ninety_chanlocs
    clear global
    eeglab nogui

    EEG = pop_loadset('filepath',usepath,'filename',files_to_use(i).name);
    [ALLEEG EEG CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG = eeg_checkset( EEG );

    % save preproc info
    EEG.Preproc.when=datestr(datetime+hours(8));
    EEG.Preproc.how = 'Pediatric_Rest_Stage0_Human.m';

    % cut last 3s of data to avoid EGI artifact
    EEG = pop_select(EEG, 'time', [0 EEG.xmax-3]);

    % resample to 250
    EEG = pop_resample( EEG, 250);

    % highpass filter w/2hz passband edge; 1.001hz transition band width; 1.499hz -6dB cutoff frequency
    % my notes from 6/5/23 state 2hz passband edge, 1hz transition band width - get Makoto to confirm
    EEG = pop_eegfiltnew(EEG, 'locutoff',2, 'filtorder',824);

    % lowpass filter w/90hz cutoff, 80hz passband edge
    EEG = pop_eegfiltnew(EEG, 'hicutoff',80);

    % cleanline taken directly from Makoto
    lineNoiseIn = struct('lineNoiseMethod', 'clean', ...l
        'lineNoiseChannels', 1:EEG.nbchan,...
        'Fs', EEG.srate, ...
        'lineFrequencies', [60],...
        'p', 0.01, ...
        'fScanBandWidth', 2, ...
        'taperBandWidth', 2, ...
        'taperWindowSize', 4, ...
        'taperWindowStep', 1, ...
        'tau', 100, ...
        'pad', 2, ...
        'fPassBand', [0 EEG.srate/2], ...
        'maximumIterations', 10);
    EEG=cleanLineNoise(EEG,lineNoiseIn);

    % remove perimeter elecs
    EEG = pop_select( EEG, 'nochannel',{'E127','E126','E17','E14','E8','E1','E125','E119','E120','E121','E114','E113','E107','E100','E99','E95','E94','E88','E89','E82','E81','E74','E73','E69','E68','E64','E63','E57','E56','E49','E44','E43','E48','E38','E32','E128','E25','E21'});
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'overwrite','on','gui','off');
    EEG.urchanlocs=ninety_chanlocs;

    % save post-filt data
    pop_saveset(EEG, 'filename', sprintf('%s_postFILT', EEG.subject(1:end-4)), 'filepath', outpath);

    movefile([files_to_use(i).folder '/' files_to_use(i).name],[usepath '/completed/']);
    movefile([files_to_use(i).folder '/' files_to_use(i).name(1:end-4) '.fdt'],[usepath '/completed/']);

end