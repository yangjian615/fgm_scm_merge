% Inputs to FGM_SCM_Merge
mission      = 'C';
spacecraft   = '4';             % Must be string.
date         = '2005-01-25';    % YYYY-MM-DD
tstart       = '14:45:00';      % HH:MM:SS
tend         = '15:00:00';      % HH:MM:SS
ref_time     = '-10';           % Negative index or HH:MM:SS
f_min        = 0.3;
f_max        = 1.5;
multiplier   = 64;
n_min        = 1.5;
n_max        = 6;
coord_sys    = 'GSE';           % SPIN | SCS | GSE
root         = '/Users/argall/Documents/Work/Data/Cluster';
fgm_data_dir = fullfile(root, 'FSR');
scm_data_dir = fullfile(root, '20050125_142500_163500');
attitude_dir = fullfile(root, 'attitude');
srt_dir      = fullfile(root, 'srt');
transfr_dir  = fullfile(root, 'Transfer_Functions');
save_dir     = fullfile(root, 'Merged');

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
% Convert Time to TT2000  |
%--------------------------

% Breakdown date and time
nPts    = length(t);
year    = repmat(str2double(date(1:4)),  1, nPts);
month   = repmat(str2double(date(6:7)),  1, nPts);
day     = repmat(str2double(date(9:10)), 1, nPts);
hour    = floor(t / 3600);
minute  = floor((t - hour*3600) / 60);
seconds = floor(mod(t, 60));
milli   = floor(mod(t, 1e0)*1e3);
micro   = floor(mod(t, 1e-3)*1e6);
nano    = floor(mod(t, 1e-6)*1e9);

% Compute TT2000
t_tt2000 = spdfcomputett2000([year;  month;  day; ...
                              hour;  minute; seconds; ...
                              milli; micro;  nano;]');
clear year month day hour minute seconds milli micro nano

%--------------------------
% Convert b to Single     |
%--------------------------
b = single(b);


%--------------------------
% Save to MAT File        |
%--------------------------
% Create file name.
%   - Use MMS file name convention.
%       scId_instrumentId_mode_dataLevel_optionalDataProductDescriptor_startTime_vX.Y.Z.cdf
year  = date(1:4);
month = date(6:7);
day   = date(9:10);
date  = [year month day];
filename  = fullfile(save_dir, ['c', spacecraft, '_afg-dfg-scm_', ...
                                'srvy', '_', coord_sys, '_', date, '_v0.0.0']);
                             
% Save to MAT file
save([filename, '.mat'], 't', 't_tt2000', 'b');
disp(['File output to: ', filename, '.mat']);

%--------------------------
% Save to CDF File        |
%--------------------------
% Each record must be a cell array
%   - Required for cdfwrite.
% t_out = num2cell(t_tt2000);
% b_out = num2cell(b, 1);

% Create CDF file
fsm_spdfcdfwrite([filename, '.cdf'], t_tt2000, b);

clear mission spacecraft date year month day t_out


%--------------------------
% Plot Results            |
%--------------------------
plot(t/3600., b);
title('Merged Data Product');
xlabel([date, ' (Hours)']);
ylabel('B (nT)');
legend('X', 'Y', 'Z');
