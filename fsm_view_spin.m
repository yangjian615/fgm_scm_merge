sc     = '1';
date   = '2005-01-25';
sTime  = '14:45:00';
eTime  = '15:00:00';
output = 1;

% Remove Delimeters
[year, month, day] = dissect_date(date);
new_date = [year month day];

% Data files
root   = '/Users/argall/Documents/Work/Data/Cluster';
fmerge = fullfile(root, 'Merged', ['c' sc '_afg-dfg-scm_srvy_SPIN_' new_date '_v0.0.0.cdf']);
ffsr   = fullfile(root, 'FSR',    ['C' sc '_' new_date '_FSR.mag']);

% Output files
out_dir = '/Users/argall/Documents/Work/Events/Thesis/argall_PhD_Thesis/Figures/';
fout    = fullfile(out_dir, 'mrg-fsr_spin');

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
clear sc sTime eTime root fmerge ffsr out_dir

%----------------------------------%
% Visualize \\\\\\\\\\\\\\\\\\\\\\ %
%----------------------------------%

% Convert FSR time to datenum
t_fsr = t_fsr / 24.0 + datenum(date, 'yyyy-mm-dd');

% Compare
subplot(3,1,1);
plot(t_fsr, b_fsr(:,1), t_mrg, b_mrg(:,1));
title('Merged & FSR Datasets (Spin Frame)');
xlabel('Time');
ylabel('Bx (nT)');
legend('FSR', 'Merged');
datetick('x', 'HH:MM:SS');


subplot(3,1,2);
plot(t_fsr, b_fsr(:,2), t_mrg, b_mrg(:,2));
xlabel('Time');
ylabel('By (nT)');
legend('FSR', 'Merged');
datetick('x', 'HH:MM:SS');


subplot(3,1,3);
plot(t_fsr, b_fsr(:,3), t_mrg, b_mrg(:,3));
xlabel('Time');
ylabel('Bz (nT)');
legend('FSR', 'Merged');
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