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
%
% History:
%  2014-11-29  - Uses Nmatlab_cdf351b_patch from SPDF. - MRA
%--------------------------------------------------------------------------
function [] = fsm_spdfcdfwrite(filename, t, b)
    
    nPts = length(t);

    % Necessities
    %   - File must not already exist.
    %   - Magnetic field must be single precision
    %   - Magnetic field must be a row-vector (3xN)
    assert(exist(filename, 'file') == 0, ['File already exists: "', filename, '".']);
    assert(isa(t, 'int64'),  'Time must be of type int64.');
		assert(isequal(size(t), [nPts, 1]), 'T must be Nx1');
    assert(isa(b, 'single'), 'Magnetic field must be single precision.');
    assert(isequal(size(b), [nPts, 3]), 'B must be Nx3.');
    
    instID    = 'c1';
    mode      = 'srvy';
    level     = 'l2';
    optdesc   = '';
    startTime = '20050125';
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
    global_attrs = struct( 'Data_type',                  [mode '_' level '_' optdesc], ...
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
                           'HTTP_LINK',                  { {'http://mms-fields.unh.edu/' ...
                                                            'http://mms.gsfc.nasa.gov/index.html'} }, ...
                           'LINK_TEXT',                  { {'UNH FIELDS Home Page', ...
                                                            'NASA MMS Home'} }, ...
                           'MODS',                       'v0.0.0 -- First version.', ...
                           'Acknowledgements',           ' ', ...
                           'Generated_by',               ' ', ...
                           'Parents',                    'CDF>Logical_file_id', ...
                           'Skeleton_version',           ' ', ...
                           'Rules_of_use',               ' ', ...
                           'Time_resolution',            ' '  ...
                         );
               
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
		
		% Bounded Records
		recbound = {t_vname, b_vname};
						 
		% Variable data types
		vardatatypes = {t_vname,      'cdf_time_tt2000', ...
			              b_vname,      'cdf_float', ...
										b_labl_vname, 'cdf_char'};
               
    
%------------------------------------------------------
% Variable Attributes                                 |
%------------------------------------------------------
    %
    % This assignment fails because the cell arrays do not have the same
    % number of elements. Adding variable attributes will have to be done
    % with cdflib.
    %
    var_attrs = struct( 'CATDESC',       {  ...
			                                     { t_vname, 'Time variable', ...
                                             b_vname, ['Three components of ' ...
         'the magnetic field derive from a combination of AFG, DFG, and ' ...
         'SCM in the frequency domain. Depends on Epoch'], ...
                                             b_labl_vname, 'Axis labels for magnetic field data.' } ...
																				 }, ...
                        'DEPEND_0',      {  ...
                                           {b_vname,      t_vname} ...
                                         }, ...
                        'DISPLAY_TYPE',  {  ... 
                                           {b_vname,      'time_series'} ...
                                         }, ...
                        'FIELDNAM',      {  ...
                                           {t_vname,      'Time', ...
                                            b_vname,      'Magnetic Field', ...
                                            b_labl_vname, 'Labl_Ptr_1'} ...
                                         }, ...
                        'FILLVAL',       {  ...
                                           {t_vname,      -1.0E31, ...
                                            b_vname,      single(-1.0E31)} ...
                                         }, ...
                        'FORMAT',        {  ...
                                           {t_vname,      'I16', ...
                                            b_vname,      'F12.6', ...
                                            b_labl_vname, 'A2'} ...
                                         }, ...
                        'LABLAXIS',      {  ...
                                           {t_vname,      'UT'} ...
                                         }, ...
                        'LABL_PTR_1',    {  ...
                                           {b_vname,      b_labl_vname} ...
                                         }, ...
                        'SI_CONVERSION', {  ...
                                           {t_vname,      '1e-9>seconds', ...
                                            b_vname,      '1e-9>Tesla'} ...
                                         }, ...
                        'UNITS',         {  ...
                                           {t_vname,      'ns', ...
                                            b_vname,      'nT'}
                                         }, ...
                        'VALIDMIN',      {  ...
                                           {t_vname,      cdflib.computeEpoch([2015, 3, 1, 0, 0, 0, 0]), ...
                                            b_vname,      single(-100000.0)} ...
                                         }, ...
                        'VALIDMAX',      {  ...
                                           {t_vname,      cdflib.computeEpoch([2050, 3, 1, 0, 0, 0, 0]), ...
                                            b_vname,      single(100000.0)} ...
                                         }, ...
                        'VARTYPE',       {  ...
                                           {t_vname,      'support_data', ...
                                            b_vname,      'data', ...
                                            b_labl_vname, 'metadata'} ...
                                         } ...
                      );

%------------------------------------------------------
% Write the File                                      |
%------------------------------------------------------
    spdfcdfwrite( filename, ...
                  var_list, ...
                 'GlobalAttributes',   global_attrs, ...
                 'VariableAttributes', var_attrs,    ...
                 'VarDatatypes',       vardatatypes, ...
                 'RecordBound',        recbound      ...
                );
    disp(['File written to ', filename])

end