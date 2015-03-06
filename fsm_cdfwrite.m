%--------------------------------------------------------------------------
% NAME
%   fsm_write
%
% PURPOSE
%   Write merged magnetometer data to a file.
%
% CALLING SEQUENCE:
%   fsm_write(filename, t, b)
%       Write merged magnetometer time (T) and magnetic field (B) data
%       to file FILENAME.
%--------------------------------------------------------------------------
function [] = fsm_cdfwrite(filename, t, b)
    
    nPts = length(t);

    % Necessities
    %   - File must not already exist.
    %   - Magnetic field must be single precision
    %   - Magnetic field must be a row-vector (3xN)
    assert(exist(filename, 'file') == 0, ['File already exists: "', filename, '".']);
    assert(isa(b, 'single'), 'Magnetic field must be single precision.');
    assert(isequal(size(b), [3 nPts]), 'B must be 3xN.');
    
    instID    = 'c1';
    mode      = 'srvy';
    level     = 'l2';
    optdesc   = '';
    startTime = '20010213';
    version   = 'v0.0.0';
    
    % Dissect the file name for later
%     [pathstr, fname, ext] = fileparts(filename);
%     [instID, mode, level, optdesc, startTime, version] = mms_dissect_filename(filename);

%------------------------------------------------------
% Global Attributes                                   |
%------------------------------------------------------
    %   - Instrument Type (1+)
    %           Electric Fields (space)
    %           Magnetic Fields (space)
    %           Particles (space)
    %           Plasma and Solar Wind
    %           Spacecraft Potential Control
    global_attrs = { 'Data_type',                  [mode '_' level '_' optdesc], ...
                     'Data_version',               version, ...
                     'Descriptor',                 'AFG-DFG-SCM', ...
                     'Discipline',                 'Space Physics>Magnetospheric Science', ...
                     'Generation_date',            datestr(now(), 'yyyymmdd'), ...
                     'Instrument_type',            'Magnetic Fields (space)', ...
                     'Logical_file_id',            filename, ...
                     'Logical_source',             [instID '_afg-dfg-scm_' mode level optdesc], ...
                     'Logical_source_description', ' ', ...
                     'Mission_group',              'MMS', ...
                     'PI_affiliation',             'SWRI, UNH', ...
                     'PI_name',                    'J. Burch, R. Torbert', ...
                     'Project',                    'STP>Solar Terrestrial Physics', ...
                     'Source_name',                'MMS#>MMS Satellite Number #', ...
                     'TEXT',                       ['The merged magnetic field ' ...
        'dataset is a combination of the DFG and SCM magnetometers. Merging is done in the' ...
        'frequency domain in the same step as data calibration. Instrument papers for DFT' ...
        'and SCM can be found at the following links: ' ...
        '' ...
        ''], ...
                     'HTTP_LINK',                  {'http://mms-fields.unh.edu/', ...
                                                    'http://mms.gsfc.nasa.gov/index.html'}, ...
                     'LINK_TEXT',                  {'UNH FIELDS Home Page', ...
                                                    'NASA MMS Home'}, ...
                     'MODS',                       'v0.0.0 -- First version.', ...
                     'Acknowledgements',           ' ', ...
                     'Generated_by',               ' ', ...
                     'Parents',                    'CDF>Logical_file_id', ...
                     'Skeleton_version',           ' ', ...
                     'Rules_of_use',               ' ', ...
                     'Time_resolution',            ' '  ...
                   };
               
%------------------------------------------------------
% Variables                                           |
%------------------------------------------------------
    % Variable naming convention
    %   scId_instrumentId_paramName_optionalDescriptor
    t_vname      = 'Epoch';
    b_vname      = [instID, '_', 'afg_dfg_scm', '_', 'b', '_', 'xyz'];
    b_labl_vname = 'B_Labl_Ptr';
    
    % Variables
    var_list = { t_vname,      t, ...
                 b_vname,      b, ...
                 b_labl_vname, {'Bx', 'By', 'Bz'} ...
               };
               
    
%------------------------------------------------------
% Variable Attributes                                 |
%------------------------------------------------------
    %
    % This assignment fails because the cell arrays do not have the same
    % number of elements. Adding variable attributes will have to be done
    % with cdflib.
    %
    var_attrs = struct( 'CATDESC',       {t_vname, 'Time variable', ...
                                          b_vname, ['Three components of ' ...
         'the magnetic field derive from a combination of AFG, DFG, and ' ...
         'SCM in the frequency domain. Depends on Epoch'], ...
                                          b_labl_vname, 'Axis labels for magnetic field data.'}, ...
                        'DEPEND_0',      {b_vname,      t_vname}, ...
                        'DISPLAY_TYPE',  {b_vname,      'time_series'}, ...
                        'FIELDNAM',      {t_vname,      'Time', ...
                                          b_vname,      'Magnetic Field', ...
                                          b_labl_vname, 'Labl_Ptr_1'}, ...
                        'FILLVAL',       {t_vname,      -1.0E31, ...
                                          b_vname,      single(-1.0E31)}, ...
                        'FORMAT',        {t_vname,      'I16', ...
                                          b_vname,      'F12.6', ...
                                          b_labl_vname, 'A2'}, ...
                        'LABLAXIS',      {t_vname,      'UT'}, ...
                        'LABL_PTR_1',    {b_vname,      b_labl_vname}, ...
                        'SI_CONVERSION', {t_vname,      '1e-9>seconds', ...
                                          b_vname,      '1e-9>Tesla'}, ...
                        'UNITS',         {t_vname,      'ns', ...
                                          b_vname,      'nT'}, ...
                        'VALIDMIN',      {t_vname,      cdflib.computeEpoch([2015, 3, 1, 0, 0, 0, 0]), ...
                                          b_vname,      single(-100000.0)}, ...
                        'VALIDMAX',      {t_vname,      cdflib.computeEpoch([2050, 3, 1, 0, 0, 0, 0]), ...
                                          b_vname,      single(100000.0)}, ...
                        'VARTYPE',       {t_vname,      'support_data', ...
                                          b_vname,      'data', ...
                                          b_labl_vname, 'metadata'} ...
                      );

%------------------------------------------------------
% Write the File                                      |
%------------------------------------------------------
    cdfwrite( filename, ...
              var_list, ...
              'GlobalAttributes',   global_attrs, ...
              'VariableAttributes', var_attrs,    ...
              'TT2000',             true          ...
            );
    disp(['File written to ', filename])

end



%
% Construct an MMS file name. The file name format is:
%
%   scId_instrumentId_mode_dataLevel_optionalDataProductDescriptor_startTime_vX.Y.Z.cdf
%
% :Params:
%   INSTRUMENTID:       in, required, type=char
%                       Instrument or investigation identifier
%                           hpca
%                           aspoc
%                           epd
%                           epd-eis
%                           epd-feeps
%                           fpi
%                           des
%                           dis
%                           des-dis
%                           fields
%                           edi
%                           adp
%                           sdp
%                           adp-sdp
%                           afg
%                           dfg
%                           dsp
%                           afg-dfg
%                           scm
%   MODE:               in, required, type=string
%                       Instrument telemetry mode:
%                           fast
%                           slow
%                           brst
%                           srvy
%   DATALEVEL:          in, required, type=string
%                       Level of the data product:
%                           l1a
%                           l1b
%                           l2
%                           ql
%                           l2pre
%                           l2plus
%   OPTDESC:            in, optional, type=char, default=''
%                       Optional data product descriptor. Should be short
%                           (3-8 characters). Hyphens used to separate
%                           multiple components.
%   STARTTIME:          in, required, type=char
%                       Start time of the data product, formatted as:
%                           'yyyymmddhhmmss'. Least significant fields can
%                           be dropped when files start on regular hourly
%                           or minute boundaries.
%   VERSION:            in, required, type=char
%                       Version number in the form: "vX.Y.Z"
%                           X - Interface number. Increments represent
%                               significant changes that will break code or
%                               require code changes in analysis software.
%                           Y - Quality number. Represents change in
%                               quality of the, such as calibration or
%                               fidelity. Should not impact software.
%                           Z - Bug fix/Revision number. Minor changes to
%                               the contents of the file due to
%                               reprocessing of missing data. Dependent
%                               data products should be reprocessed.
%
function fname = mms_create_filename(instID, mode, level, optdesc, startTime, version)
    fname = [instID, '_', mode, '_', level, '_', optdesc, '_', startTime, '_', version, '.cdf'];
end