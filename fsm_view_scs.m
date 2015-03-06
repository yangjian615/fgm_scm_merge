sc     = '1';
date   = '2005-01-25';
sTime  = '14:46:00';
eTime  = '14:46:30';
output = 1;

% Remove Delimeters
[year, month, day] = dissect_date(date);
new_date = [year month day];

% Data files
root    = '/Users/argall/Documents/Work/Data/Cluster';
fmerge  = fullfile(root, 'Merged', ['c' sc '_afg-dfg-scm_srvy_SCS_' new_date '_v0.0.0.cdf']);
ffsr    = fullfile(root, 'FSR',    ['C' sc '_' new_date '_FSR.mag']);
srt_dir = fullfile(root, 'srt');
att_dir = fullfile(root, 'attitude');

% Output files
out_dir = '/Users/argall/Documents/Work/Events/Thesis/argall_PhD_Thesis/Figures/';
fout    = fullfile(out_dir, 'mrg-fsr_despun_30sec');
	
%----------------------------------%
% Get Data \\\\\\\\\\\\\\\\\\\\\\\ %
%----------------------------------%

% Merged Data
[b_mrg, t_mrg] = MrCDF_Read(fmerge, 'c1_afg_dfg_scm_b_xyz', ...
                            'sTime', [date 'T' sTime], 'eTime', [date 'T' eTime], ...
                            'ConvertEpochToDatenum', true);


% FSR Data
%   - Convert decimal hours to seconds.
[b_fsr, t_fsr] = c_fsr_read(ffsr, ...
	                          'TSTART', MrDatenumToSSM(datenum([date ' ' sTime], 'yyyy-mm-dd HH:MM:SS')) / 3600.0, ...
														'TEND',   MrDatenumToSSM(datenum([date ' ' eTime], 'yyyy-mm-dd HH:MM:SS')) / 3600.0);


% Read attitude and srt date
srtime = cluster_get_srtime(sc, new_date, srt_dir);
omega  = cluster_get_attitude(sc, new_date, t_fsr(1), att_dir);


% Convert time seconds since midnight
t_fsr = t_fsr * 3600.0;
t_mrg = MrDatenumToSSM(t_mrg);
b_fsr = b_fsr';
b_mrg = b_mrg';
t_fsr = t_fsr';
t_mrg = t_mrg';
srtime = srtime';

clear sc sTime eTime root fmerge ffsr srt_dir att_dir out_dir year month day new_date
	
%----------------------------------%
% Despin \\\\\\\\\\\\\\\\\\\\\\\\\ %
%----------------------------------%

% Despin the data
b_despun = despin(b_fsr, t_fsr, srtime, omega, 'SpinAxis', 1, 'Direction', 1);

% Rotate into the FSR frame
mrg2fsr = [0 0 1; ...
	         1 0 0; ...
					 0 1 0];
b_mrg = mrg2fsr * b_mrg;

% Rotate from the sun-sensor frame to the FSR frame. 
% theta    = 32.7 * pi/180;
theta    = 34 * pi/180;
sinTheta = sin(theta);
cosTheta = cos(theta);
sun2fsr = [ 1     0         0;      ...
	          0  cosTheta -sinTheta;  ...
	          0  sinTheta  cosTheta]; ...
b_mrg = sun2fsr * b_mrg;

clear theta mrg2fsr sun2fsr sinTheta cosTheta

%----------------------------------%
% Visualize \\\\\\\\\\\\\\\\\\\\\\ %
%----------------------------------%
% Convert time to datenum
t_fsr = ssm2datenum(t_fsr, date);
t_mrg = ssm2datenum(t_mrg, date);

fig = figure();
set(fig, 'Position', [100 100 450 600]);
set(fig, 'PaperUnits', 'inches', 'PaperSize', [4 6], ...
	       'PaperPosition', [0 0 4 6]);

% Bx
subplot(3,1,1);
plot(t_fsr, b_despun(1,:), t_mrg, b_mrg(1,:));
title('Despun Merged & FSR Datasets');
xlabel('Time');
ylabel('Bx (nT)');
legend('FSR', 'Merged', 'Location', 'Northwest');
yrange = [min(b_mrg(1,:)) max(b_mrg(1,:))];
ylim(yrange + abs(yrange) .* [-0.1, 0.1]);
datetick('x', 'HH:MM:SS');

% By
subplot(3,1,2);
plot(t_fsr, b_despun(2,:), t_mrg, b_mrg(2,:));
xlabel('Time');
ylabel('By (nT)');
legend('FSR', 'Merged', 'Location', 'Northwest');
yrange = [min(b_mrg(2,:)) max(b_mrg(2,:))];
ylim(yrange + abs(yrange) .* [-0.1, 0.1]);
datetick('x', 'HH:MM:SS');

% Bz
subplot(3,1,3);
plot(t_fsr, b_despun(3,:), t_mrg, b_mrg(3,:));
xlabel('Time');
ylabel('Bz (nT)');
legend('FSR', 'Merged', 'Location', 'Northwest');
yrange = [min(b_mrg(3,:)) max(b_mrg(3,:))];
ylim(yrange + abs(yrange) .* [-0.1, 0.1]);
datetick('x', 'HH:MM:SS');

% Clean up
clear date t_fsr b_fsr t_mrg b_mrg

%----------------------------------%
% Save \\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%----------------------------------%
if output
	print(gcf, '-depsc2', [fout '.eps']);
	print(gcf, '-dps',    [fout '.ps']);
	print(gcf, '-dpng',   [fout '.png']);
	disp(['Saving files to: ', fout, '.png']);
end

clear output fout