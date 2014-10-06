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
coord_sys    = 'GSE';           % SPIN | SCS | GSE
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
clear ref_time f_min f_max multiplier n_min n_max ...
      root fgm_data_dir scm_data_dir attitude_dir srt_dir transfr_dir ...
      tstart tend

%--------------------------
% Convert Time to Epoch   |
%--------------------------
%   - Convert time to Epoch (using old CDF library for the moment).
t_epoch = zeros(size(t));
year    = str2double(date(1:4));
month   = str2double(date(6:7));
day     = str2double(date(9:10));
hour    = floor(t / 3600);
minute  = floor((t - hour*3600) / 60);
seconds = floor(mod(t, 60));
milli   = floor(mod(t, 1)*1000);
for ii = 1: length(t)
    t_epoch(ii) = cdflib.computeEpoch([year, month, day, ...
                                       hour(ii), minute(ii), seconds(ii), ...
                                       milli(ii)]);
end
clear ii year month day hour minute seconds milli


%--------------------------
% Save to File            |
%--------------------------
% Create file name.
%   - Use MMS file name convention.
%       scId_instrumentId_mode_dataLevel_optionalDataProductDescriptor_startTime_vX.Y.Z.cdf
year  = date(1:4);
month = date(6:7);
day   = date(9:10);
date  = [year month day];
directory = '/Users/argall/Documents/Work/Data/Cluster/Merged/';
filename  = fullfile(directory, ['c', spacecraft, '_afg-dfg-scm_', ...
                                 'srvy', '_', coord_sys, '_', date, '_v0.0.0']);
                             
% Save to MAT file
save([filename, '.mat'], 't', 't_epoch', 'b');
disp(['File output to: ', filename, '.mat']);

% Create CDF file
fsm_cdflib_write([filename, '.cdf'], t, single(b'));
disp(['File output to: ', filename, '.cdf']);

clear mission spacecraft date year month day


%--------------------------
% Plot Results            |
%--------------------------
plot(t/3600., b);
title('Merged Data Product');
xlabel([date, ' (Hours)']);
ylabel('B (nT)');
legend('X', 'Y', 'Z');
