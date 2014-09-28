function [out] = merging_input_gui(mission, sc, date, tstart, tend, f_min, f_max, ref_time, multiplier, n_min, n_max, coord_sys)

%
% Check input arguments
%

if nargin == 0
    mission = 'C or RBSP';
    sc = 'E.g. A,B,1,2,3,4';
    date = 'YYYYMMDD';
    tstart = 'HHMMSS';
    tend = 'HHMMSS';
end

if nargin < 6
    f_min = '0.3';
    f_max = '1,5';

end

if nargin < 8
    ref_time = 'HHMMSS';
    
end

if nargin < 10
    multiplier = 64;
    
end

if nargin < 11
    n_min = '1.5';
    n_max = '6';

end

if nargin < 13;
    coord_sys = 'GSE';
end

assert(max(nargin == [1 2 3 4 6 10]) == 0 || nargin > 11, ...
       'Incorrect number of input arguments: merging_input_gui.m');

S.cancel = 0;

%
% Creates a GUI to input spacecraft number date, start time, and end time 
% for a data interval.
%

nrows=27;
dfl = 10;
width = 100;
height = 20;
dfb = height*nrows;

% Position: [left, bottom, width, height]
S.figure = figure('Name', 'Merging Inputs', ...
                  'NumberTitle', 'Off', ...
                  'Position', [300, 500, 2*width + 2*dfl, height*nrows]);


% Position: [distand from left, distance from bottom, width, height]
% Mission
n=1;
S.mis_desc = uicontrol('Style', 'text', ...
                       'String', 'Data Information', ...
                       'Position', [dfl, dfb-height*n, 2*width, height]);
S.mis_text = uicontrol('Style', 'text', ...
                       'String', 'Mission', ...
                       'Position', [dfl, dfb-height*(n+1), width, height]);
S.mis_edit = uicontrol('Style', 'edit', ...
                       'String', mission, ...
                       'Position', [dfl + width, dfb-height*(n+1), width, height]);
                  

% Spacecraft
n=3;
S.sc_text = uicontrol('Style', 'text', ...
                      'String', 'SC', ...
                      'Position', [dfl, dfb-height*n, width, height]);
S.sc_edit = uicontrol('Style', 'edit', ...
                      'String', sc, ...
                      'Position', [dfl + width, dfb-height*n, width, height]);


% Date
n=4;
S.date_text = uicontrol('Style', 'text', ...
                        'String', 'DATE', ...
                        'Position', [dfl, dfb-height*n, width, height]);
S.date_edit = uicontrol('Style', 'edit', ...
                        'String', date, ...
                        'Position', [dfl + width, dfb-height*n, width, height]);


% Start Time
n=5;
S.start_text = uicontrol('Style', 'text', ...
                         'String', 'Start Time', ...
                         'Position', [dfl, dfb-height*n, width, height]);
S.start_edit = uicontrol('Style', 'edit', ...
                         'String', tstart, ...
                         'Position', [dfl + width, dfb-height*n, width, height]);


% End Time
n=6;
S.end_text = uicontrol('Style', 'text', ...
                       'String', 'End Time', ...
                       'Position', [dfl, dfb-height*n, width, height]);
S.end_edit = uicontrol('Style', 'edit', ...
                       'String', tend, ...
                       'Position', [dfl + width, dfb-height*n, width, height]);


% Reference Time
n=8;
S.reft_desc = uicontrol('Style', 'text', ...
                        'String', 'Time of Reference Interval', ...
                        'Position', [dfl, dfb-height*n, 2*width, height]);
S.reft_text = uicontrol('Style', 'text', ...
                        'String', 'Reference Time', ...
                        'Position', [dfl, dfb-height*(n+1), width, height]);
S.reft_edit = uicontrol('Style', 'edit', ...
                        'String', ref_time, ...
                        'Position', [dfl + width, dfb-height*(n+1), width, height]);


% Frequency Interval
n=11;
S.f_desc = uicontrol('Style', 'text', ...
                     'String', 'Frequency Range to Merge', ...
                     'Position', [dfl, dfb-height*n, 2*width, height]);
S.fmin_text = uicontrol('Style', 'text', ...
                        'String', 'f Min', ...
                        'Position', [dfl, dfb-height*(n+1), width, height]);
S.fmax_text = uicontrol('Style', 'text', ...
                        'String', 'f Max', ...
                        'Position', [dfl+width, dfb-height*(n+1), width, height]);
S.fmin_edit = uicontrol('Style', 'edit', ...
                        'String', f_min, ...
                        'Position', [dfl, dfb-height*(n+2), width, height]);
S.fmax_edit = uicontrol('Style', 'edit', ...
                        'String', f_max, ...
                        'Position', [dfl+width, dfb-height*(n+2), width, height]);


% Multiplier
n=15;
S.mult_desc = uicontrol('Style', 'text', ...
                        'String', 'Multiplier of Min FFT Length', ...
                        'Position', [dfl, dfb-height*n, 2*width, height]);
S.mult_text = uicontrol('Style', 'text', ...
                        'String', 'Multiplier', ...
                        'Position', [dfl, dfb-height*(n+1), width, height]);
S.mult_edit = uicontrol('Style', 'edit', ...
                        'String', multiplier, ...
                        'Position', [dfl + width, dfb-height*(n+1), width, height]);



% Coordinate System
n=18;
S.coord_desc = uicontrol('Style', 'text', ...
                         'String', 'Rotate to Which Coordinate System?', ...
                         'Position', [dfl, dfb-height*n, 2*width, height]);
S.coord_text = uicontrol('Style', 'text', ...
                         'String', 'Coord Sys', ...
                         'Position', [dfl, dfb-height*(n+1), width, height]);
S.coord_edit = uicontrol('Style', 'edit', ...
                         'String', coord_sys, ...
                         'Position', [dfl + width, dfb-height*(n+1), width, height]);


% Gap Range
n=21;
S.n_desc = uicontrol('Style', 'text', ...
                     'String', 'Interpolate Small Data Gaps (# Samples)', ...
                     'Position', [dfl, dfb-height*n, 2*width, height]);
S.nmin_text = uicontrol('Style', 'text', ...
                        'String', 'N Min', ...
                        'Position', [dfl, dfb-height*(n+1), width, height]);
S.nmax_text = uicontrol('Style', 'text', ...
                        'String', 'N Max', ...
                        'Position', [dfl+width, dfb-height*(n+1), width, height]);
S.nmin_edit = uicontrol('Style', 'edit', ...
                        'String', n_min, ...
                        'Position', [dfl, dfb-height*(n+2), width, height]);
S.nmax_edit = uicontrol('Style', 'edit', ...
                        'String', n_max, ...
                        'Position', [dfl+width, dfb-height*(n+2), width, height]);


% OK, Cancel
n=25;
S.ok_button = uicontrol('Style', 'pushbutton', ...
                        'String', 'Ok', ...
                        'Position', [dfl + width/2, dfb-height*n, width, height], ...
                        'callback', {@merger_ok, S.figure});

S.cancel_button = uicontrol('Style', 'pushbutton', ...
                            'String', 'Cancel', ...
                            'Position', [dfl + width/2, dfb-height*(n+1), width, height]);
set(S.cancel_button, 'callback', {@merger_cancel; S})
   
uiwait(S.figure)

if S.cancel == 1
    return
end

out.mission = get(S.mis_edit, 'String');
out.sc = get(S.sc_edit, 'String');
out.date = get(S.date_edit, 'String');
out.tstart = get(S.start_edit, 'String');
out.tend = get(S.end_edit, 'String');
out.f_min = str2double(get(S.fmin_edit, 'String'));
out.f_max = str2double(get(S.fmax_edit, 'String'));
out.ref_time = get(S.reft_edit, 'String');
out.multiplier = str2double(get(S.mult_edit, 'String'));
out.n_min = str2double(get(S.nmin_edit, 'String'));
out.n_max = str2double(get(S.nmax_edit, 'String'));


delete(S.figure)

    function [] = merger_ok(~, ~, fig)

        uiresume(fig)

    function [] = merger_cancel(~, ~, S)

        S.cancel = 1;
        uiresume(S.figure)
