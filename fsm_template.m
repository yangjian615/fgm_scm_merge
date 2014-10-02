% Inputs to FGM_SCM_Merge
mission      = 'C';
spacecraft   = '1';             % Must be string.
date         = '2001-02-13';    % YYYY-MM-DD
tstart       = '00:00:00';      % HH:MM:SS
tend         = '24:00:00';      % HH:MM:SS
ref_time     = '-1';            % Negative index or HH:MM:SS
f_min        = 0.3;
f_max        = 1.5;
multiplier   = 64;
n_min        = 1.5;
n_max        = 6;
coord_sys    = 'GSE';
root         = '/Users/argall/Documents/Work/Data/Cluster';
fgm_data_dir = fullfile(root, 'FSR');
scm_data_dir = fullfile(root, 'STAFF');
attitude_dir = fullfile(root, 'attitude');
srt_dir      = fullfile(root, 'srt');
transfr_dir  = fullfile(root, 'Transfer_Functions');

% Merge the indicated datasets
[t, b] = fgm_scm_merge( mission, spacecraft, date, tstart, tend, ...
                        'Ref_Time',      ref_time,     ...
                        'f_min',         f_min,        ...
                        'f_max',         f_max,        ...
                        'Multiplier',    multiplier,   ...
                        'N_Min',         n_min,        ...
                        'N_Max',         n_max,        ...
                        'coord_sys',     coord_sys,    ...
                        'fgm_data_dir',  fgm_data_dir, ...
                        'scm_data_dir',  scm_data_dir, ...
                        'attitude_dir',  attitude_dir, ...
                        'srt_dir',       srt_dir,      ...
                        'TransfrFn_dir', transfr_dir   ...
                      );

% Save data to a MatFile
date      = strrep(date, '-', '');
tstart    = strrep(tstart, ':', '');
tend      = strrep(tend, ':', '');
directory = '/Users/argall/Documents/Work/Data/Cluster/Merged/';
filename  = fullfile(directory, [mission, spacecraft, '_Merged_', ...
                     coord_sys, '_', date, '_', tstart, '_', tend, '.mat']);
save(filename, 't', 'b');
disp(['File output to: ', filename]);

% Visualize the results
plot(t/3600., b);
title('Merged Data Product');
xlabel([date, ' (Hours)']);
ylabel('B (nT)');
legend('X', 'Y', 'Z');
