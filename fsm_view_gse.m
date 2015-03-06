date   = '2005-01-25';
sTime  = '14:45:00';
eTime  = '15:00:00';
output = 0;

% Remove Delimeters
[year, month, day] = dissect_date(date);
new_date = [year month day];

% Data files
root   = '/Users/argall/Documents/Work/Data/Cluster/';
fmerge = fullfile(root, 'Merged', ['c1_afg-dfg-scm_srvy_GSE_' new_date '_v0.0.0.cdf']);
ffgm   = c_find_file('FGM_FULL', '1', date, sTime, eTime, fullfile(root, '20050125_142500_163500'));

% Output files
out_dir = '/Users/argall/Documents/Work/Events/Thesis/argall_PhD_Thesis/Figures/';
fout    = fullfile(out_dir, 'mrg-fsr_gse');

% Turn off file validation
cdflib.setValidate('VALIDATEFILEoff');

%----------------------------------%
% Get Data \\\\\\\\\\\\\\\\\\\\\\\ %
%----------------------------------%

% Merged Data
[mrg_data, t_mrg] = MrCDF_Read(fmerge, 'c1_afg_dfg_scm_b_xyz', ...
	                             'sTime', [date 'T' sTime], 'eTime', [date 'T' eTime], ...
															 'ConvertEpochToDatenum', true);

% FGM Data
[fgm_data, t_fgm] = MrCDF_Read(ffgm, 'B_vec_xyz_gse__C1_CP_FGM_FULL', ...
	                             'sTime', [date 'T' sTime], 'eTime', [date 'T' eTime], ...
															 'ConvertEpochToDatenum', true);
clear date sTime eTime year month day new_date root fmerge ffgm out_dir

%----------------------------------%
% Visualize \\\\\\\\\\\\\\\\\\\\\\ %
%----------------------------------%
mrg_gse_fig = figure();
set(mrg_gse_fig, 'Position', [0 0 400 500]);

% Compare
subplot(3,1,1);
plot(t_fgm, fgm_data(:,1), t_mrg, mrg_data(:,1));
title('Merged & FGM Datasets (GSE)');
xlabel('Time');
ylabel('Bx (nT)');
legend('FSR', 'Merged');
datetick('x', 'HH:MM:SS');



subplot(3,1,2);
plot(t_fgm, fgm_data(:,2), t_mrg, mrg_data(:,2));
xlabel('Time');
ylabel('By (nT)');
legend('FSR', 'Merged');
datetick('x', 'HH:MM:SS');


subplot(3,1,3);
plot(t_fgm, fgm_data(:,3), t_mrg, mrg_data(:,3));
legend('FGM', 'Merged');
xlabel('Time');
ylabel('Bz (nT)');
legend('FSR', 'Merged');
datetick('x', 'HH:MM:SS');

% Clean up
clear t_fgm t_mrg fgm_data fgm_mrg

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