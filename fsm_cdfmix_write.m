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
function [] = fsm_cdfmix_write(filename, t, b)
    %
    % cdflib is unable to write TT2000 times and cdfwrite/spdfcdfwrite are
    % unable to manage variable attributes properly. Here, we use cdflib to
    % do everything except write our "Epoch" time variable. At the end,
    % cdfwrite appends our Epoch TT2000 variable to the file.
    %
    
    nPts = length(t);

    % Necessities
    %   - File must not already exist.
    %   - Time must be int64.
    %   - Magnetic field must be single precision
    %   - Magnetic field must be a row-vector (3xN)
    assert( exist(filename, 'file') == 0,     ['File already exists: "', filename, '".']);
    assert( iscell(t) && isa(t{1}, 'int64'),   'Time must be a cell array of int64 values.');
    assert( isa(b, 'single'),                  'Magnetic field must be single precision.');
    assert( isequal(size(b), [3 nPts]),        'B must be 3xN.');
    
    instID    = 'c1';
    mode      = 'srvy';
    level     = 'l2';
    optdesc   = '';
    startTime = '20010213';
    version   = 'v0.0.0';
    
    % Dissect the file name for later
%     [pathstr, fname, ext] = fileparts(filename);
%     [instID, mode, level, optdesc, startTime, version] = mms_dissect_filename(filename);

    % Open the file
%    cdf_id = cdflib.create(filename);
    
%------------------------------------------------------
% Start by Writing TT2000                             |
%------------------------------------------------------
    cdfwrite(filename, {'Epoch', t}, 'tt2000', true);
    
    % Open the file to write with cdflib
    %   - Must turn validate off. cdfwrite uses higher version than cdflib
    cdflib.setValidate('VALIDATEFILEoff');
    cdf_id = cdflib.open(filename);

%------------------------------------------------------
% Create Global Attributes                            |
%------------------------------------------------------
    %   - Instrument Type (1+)
    %           Electric Fields (space)
    %           Magnetic Fields (space)
    %           Particles (space)
    %           Plasma and Solar Wind
    %           Spacecraft Potential Control
    type       = cdflib.createAttr(cdf_id, 'Data_type',                  'global_scope');
    ver        = cdflib.createAttr(cdf_id, 'Data_version',               'global_scope');
    desc       = cdflib.createAttr(cdf_id, 'Descriptor',                 'global_scope');
    dspln      = cdflib.createAttr(cdf_id, 'Discipline',                 'global_scope');
    gen_date   = cdflib.createAttr(cdf_id, 'Generation_date',            'global_scope');
    inst_type  = cdflib.createAttr(cdf_id, 'Instrument_type',            'global_scope');
    file_id    = cdflib.createAttr(cdf_id, 'Logical_file_id',            'global_scope');
    src        = cdflib.createAttr(cdf_id, 'Logical_source',             'global_scope');
    src_desc   = cdflib.createAttr(cdf_id, 'Logical_source_description', 'global_scope');
    mission    = cdflib.createAttr(cdf_id, 'Mission_group',              'global_scope');
    pi_affil   = cdflib.createAttr(cdf_id, 'PI_affiliation',             'global_scope');
    pi         = cdflib.createAttr(cdf_id, 'PI_name',                    'global_scope');
    project    = cdflib.createAttr(cdf_id, 'Project',                    'global_scope');
    src_name   = cdflib.createAttr(cdf_id, 'Source_name',                'global_scope');
    text       = cdflib.createAttr(cdf_id, 'TEXT',                       'global_scope');
    link       = cdflib.createAttr(cdf_id, 'HTTP_LINK',                  'global_scope');
    link_text  = cdflib.createAttr(cdf_id, 'LINK_TEXT',                  'global_scope');
    link_title = cdflib.createAttr(cdf_id, 'LINK_TITLE',                 'global_scope');
    mods       = cdflib.createAttr(cdf_id, 'MODS',                       'global_scope');
    acknow     = cdflib.createAttr(cdf_id, 'Acknowledgements',           'global_scope');
    genby      = cdflib.createAttr(cdf_id, 'Generated_by',               'global_scope');
    parents    = cdflib.createAttr(cdf_id, 'Parents',                    'global_scope');
    skel_ver   = cdflib.createAttr(cdf_id, 'Skeleton_version',           'global_scope');
    rules      = cdflib.createAttr(cdf_id, 'Rules_of_use',               'global_scope');
    time_res   = cdflib.createAttr(cdf_id, 'Time_resolution',            'global_scope');
    
%------------------------------------------------------
% Create Variable Attributes                          |
%------------------------------------------------------
    catdesc    = cdflib.createAttr(cdf_id, 'CATDESC',       'variable_scope');
    dep0       = cdflib.createAttr(cdf_id, 'DEPEND_0',      'variable_scope');
    dep1       = cdflib.createAttr(cdf_id, 'DEPEND_1',      'variable_scope');
    dep2       = cdflib.createAttr(cdf_id, 'DEPEND_2',      'variable_scope');
    dep3       = cdflib.createAttr(cdf_id, 'DEPEND_3',      'variable_scope');
    disp_type  = cdflib.createAttr(cdf_id, 'DISPLAY_TYPE',  'variable_scope');
    fieldnam   = cdflib.createAttr(cdf_id, 'FIELDNAM',      'variable_scope');
    fillval    = cdflib.createAttr(cdf_id, 'FILLVAL',       'variable_scope');
    format     = cdflib.createAttr(cdf_id, 'FORMAT',        'variable_scope');
    form_ptr   = cdflib.createAttr(cdf_id, 'FORM_PTR',      'variable_scope');
    lablax     = cdflib.createAttr(cdf_id, 'LABLAXIS',      'variable_scope');
    labl_ptr_1 = cdflib.createAttr(cdf_id, 'LABL_PTR_1',    'variable_scope');
    si_conv    = cdflib.createAttr(cdf_id, 'SI_CONVERSION', 'variable_scope');
    units      = cdflib.createAttr(cdf_id, 'UNITS',         'variable_scope');
    unit_ptr   = cdflib.createAttr(cdf_id, 'UNIT_PTR',      'variable_scope');
    valmin     = cdflib.createAttr(cdf_id, 'VALIDMIN',      'variable_scope');
    valmax     = cdflib.createAttr(cdf_id, 'VALIDMAX',      'variable_scope');
    vartype    = cdflib.createAttr(cdf_id, 'VARTYPE',       'variable_scope');
    
%------------------------------------------------------
% Create Variables                                    |
%------------------------------------------------------
    % Variable naming convention
    %   scId_instrumentId_paramName_optionalDescriptor
    t_vname      = 'Epoch';
    b_vname      = [instID, '_', 'afg_dfg_scm', '_', 'b', '_', 'xyz'];
    b_labl_vname = 'B_Labl_Ptr';
    
    % Create the variables
%    t_ID     = cdflib.createVar(cdf_id, t_vname,      'CDF_EPOCH', 1, [], true,  []);
    t_ID     = cdflib.getVarNum(cdf_id, 'Epoch');
    b_ID     = cdflib.createVar(cdf_id, b_vname,      'CDF_REAL4', 1,  3, true,  true);
    b_ptr_ID = cdflib.createVar(cdf_id, b_labl_vname, 'CDF_CHAR',  1,  2, false, true);
    
%------------------------------------------------------
% Write Global Attributes                             |
%------------------------------------------------------
    cdflib.putAttrgEntry(cdf_id, type,       0, 'CDF_CHAR', [mode '_' level '_' optdesc]);
    cdflib.putAttrgEntry(cdf_id, ver,        0, 'CDF_CHAR', version);
    cdflib.putAttrgEntry(cdf_id, desc,       0, 'CDF_CHAR', 'AFG-DFG-SCM');
    cdflib.putAttrgEntry(cdf_id, dspln,      0, 'CDF_CHAR', 'Space Physics>Magnetospheric Science');
    cdflib.putAttrgEntry(cdf_id, gen_date,   0, 'CDF_CHAR', datestr(now(), 'yyyymmdd'));
    cdflib.putAttrgEntry(cdf_id, inst_type,  0, 'CDF_CHAR', 'Magnetic Fields (space)');
    cdflib.putAttrgEntry(cdf_id, file_id,    0, 'CDF_CHAR', filename);
    cdflib.putAttrgEntry(cdf_id, src,        0, 'CDF_CHAR', [instID '_afg-dfg-scm_' mode level optdesc]);
    cdflib.putAttrgEntry(cdf_id, src_desc,   0, 'CDF_CHAR', ' ');
    cdflib.putAttrgEntry(cdf_id, mission,    0, 'CDF_CHAR', 'MMS');
    cdflib.putAttrgEntry(cdf_id, pi_affil,   0, 'CDF_CHAR', 'SWRI, UNH');
    cdflib.putAttrgEntry(cdf_id, pi,         0, 'CDF_CHAR', 'J. Burch, R. Torbert)');
    cdflib.putAttrgEntry(cdf_id, project,    0, 'CDF_CHAR', 'STP>Solar Terrestrial Physics');
    cdflib.putAttrgEntry(cdf_id, src_name,   0, 'CDF_CHAR', 'MMS#>MMS Satellite Number #');
    cdflib.putAttrgEntry(cdf_id, text,       0, 'CDF_CHAR', ['The merged magnetic field ', ...
        'dataset is a combination of the DFG and SCM magnetometers. Merging is done in the', ...
        'frequency domain in the same step as data calibration. Instrument papers for DFT', ...
        'and SCM can be found at the following links: ', ...
        '', ...
        '']);
    cdflib.putAttrgEntry(cdf_id, link,       0, 'CDF_CHAR', 'http://mms-fields.unh.edu/');
    cdflib.putAttrgEntry(cdf_id, link,       1, 'CDF_CHAR', 'http://mms.gsfc.nasa.gov/index.html');
    cdflib.putAttrgEntry(cdf_id, link_text,  0, 'CDF_CHAR', 'UNH FIELDS Home Page');
    cdflib.putAttrgEntry(cdf_id, link_text,  1, 'CDF_CHAR', 'NASA MMS Home');
    cdflib.putAttrgEntry(cdf_id, link_title, 0, 'CDF_CHAR', 'UNH FIELDS');
    cdflib.putAttrgEntry(cdf_id, link_title, 1, 'CDF_CHAR', 'NASA MMS Home');
    cdflib.putAttrgEntry(cdf_id, mods,       0, 'CDF_CHAR', 'v0.0.0 -- First version.');
    cdflib.putAttrgEntry(cdf_id, acknow,     0, 'CDF_CHAR', ' ');
    cdflib.putAttrgEntry(cdf_id, genby,      0, 'CDF_CHAR', ' ');
    cdflib.putAttrgEntry(cdf_id, parents,    0, 'CDF_CHAR', 'CDF>Logical_file_id');
    cdflib.putAttrgEntry(cdf_id, skel_ver,   0, 'CDF_CHAR', ' ');
    cdflib.putAttrgEntry(cdf_id, rules,      0, 'CDF_CHAR', ' ');
    cdflib.putAttrgEntry(cdf_id, time_res,   0, 'CDF_CHAR', ' ');
    
    
%------------------------------------------------------
% Write Variable Attributes                           |
%------------------------------------------------------
    %
    %   TIME
    %
    cdflib.putAttrEntry(cdf_id, catdesc,  t_ID, 'CDF_CHAR',  'Time variable')
    cdflib.putAttrEntry(cdf_id, fieldnam, t_ID, 'CDF_CHAR',  'Time')
    cdflib.putAttrEntry(cdf_id, fillval,  t_ID, 'CDF_EPOCH', -1.0E31)          % Defined in MMS_CDF_Format_Guide.docx
    cdflib.putAttrEntry(cdf_id, format,   t_ID, 'CDF_CHAR',  'I16')
    cdflib.putAttrEntry(cdf_id, lablax,   t_ID, 'CDF_CHAR',  'UT')             % Not required
    cdflib.putAttrEntry(cdf_id, si_conv,  t_ID, 'CDF_CHAR',  '1e-9>seconds')   % Not required
    cdflib.putAttrEntry(cdf_id, units,    t_ID, 'CDF_CHAR',  'nx')
    cdflib.putAttrEntry(cdf_id, valmin,   t_ID, 'CDF_EPOCH', cdflib.computeEpoch([2015, 3, 1, 0, 0, 0, 0]))
    cdflib.putAttrEntry(cdf_id, valmax,   t_ID, 'CDF_EPOCH', cdflib.computeEpoch([2050, 3, 1, 0, 0, 0, 0]))
    cdflib.putAttrEntry(cdf_id, vartype,  t_ID, 'CDF_CHAR',  'support_data')
    
    %
    %   MAGNETIC FIELD
    %
    cdflib.putAttrEntry(cdf_id, catdesc,    b_ID, 'CDF_CHAR', ...
        ['Three components of the magnetic field derive from a combination', ...
         'of AFG, DFG, and SCM in the frequency domain. Depends on Epoch'])
    cdflib.putAttrEntry(cdf_id, dep0,       b_ID, 'CDF_CHAR',  t_vname)
    cdflib.putAttrEntry(cdf_id, disp_type,  b_ID, 'CDF_CHAR',  'time_series')
    cdflib.putAttrEntry(cdf_id, fieldnam,   b_ID, 'CDF_CHAR',  'Magnetic Field')
    cdflib.putAttrEntry(cdf_id, fillval,    b_ID, 'CDF_REAL4', single(-1.0E31))   % Defined in MMS_CDF_Format_Guide.docx
    cdflib.putAttrEntry(cdf_id, format,     b_ID, 'CDF_CHAR',  'F12.6')
    cdflib.putAttrEntry(cdf_id, labl_ptr_1, b_ID, 'CDF_CHAR',  b_labl_vname)
    cdflib.putAttrEntry(cdf_id, si_conv,    b_ID, 'CDF_CHAR',  '1e-9>Tesla')
    cdflib.putAttrEntry(cdf_id, units,      b_ID, 'CDF_CHAR',  'nT')
    cdflib.putAttrEntry(cdf_id, valmin,     b_ID, 'CDF_REAL4', single(-100000.0))
    cdflib.putAttrEntry(cdf_id, valmax,     b_ID, 'CDF_REAL4', single(100000.0))
    cdflib.putAttrEntry(cdf_id, vartype,    b_ID, 'CDF_CHAR',  'data')
    
    %
    %   B_LABL1
    %
    cdflib.putAttrEntry(cdf_id, catdesc,  b_ptr_ID, 'CDF_CHAR',  'Axis labels for magnetic field data.')
    cdflib.putAttrEntry(cdf_id, fieldnam, b_ptr_ID, 'CDF_CHAR',  'Labl_Ptr_1')
    cdflib.putAttrEntry(cdf_id, fillval,  b_ptr_ID, 'CDF_CHAR',  'N/A')   % Defined in MMS_CDF_Format_Guide.docx
    cdflib.putAttrEntry(cdf_id, format,   b_ptr_ID, 'CDF_CHAR',  'A2')
    cdflib.putAttrEntry(cdf_id, vartype,  b_ptr_ID, 'CDF_CHAR',  'metadata')
    
    
%------------------------------------------------------
% Write Variable Data                                 |
%------------------------------------------------------
    t_len = length(t);
    b_len = size(b, 2);

%    cdflib.hyperPutVarData(cdf_id, t_ID,     [0, t_len, 1], {0, 1, 1}, t)
    cdflib.hyperPutVarData(cdf_id, b_ID,     [0, b_len, 1], {0, 3, 1}, b)
    cdflib.hyperPutVarData(cdf_id, b_ptr_ID, [0,     3, 1], {0, 2, 1}, ['Bx'; 'By'; 'Bz'])
    
%------------------------------------------------------
% Close the File                                      |
%------------------------------------------------------
    cdflib.close(cdf_id)
    disp(['File written to ', filename])
end