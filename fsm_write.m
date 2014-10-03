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
function [] = fsm_write(filename, t, b)
    
    % Create a file name
    dir      = '/Users/argall/Documents/Work/Data/Cluster/Merged/';
    filename = fullfile(dir, 'c1_fields_srvy_20010318_v0.0.0.cdf');
    
    % Dissect the file name for later
    [pathstr, fname, ext] = fileparts(filename);
    [instID, mode, level, optdesc, startTime, version] = mms_dissect_filename(filename);

    % Open the file
    cdf_id = cdflib.create(filename);

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
    version    = cdflib.createAttr(cdf_id, 'Data_version',               'global_scope');
    desc       = cdflib.createAttr(cdf_id, 'Descriptor',                 'global_scope');
    desc       = cdflib.createAttr(cdf_id, 'Discipline',                 'global_scope');
    dspln      = cdflib.createAttr(cdf_id, 'Generation_date',            'global_scope');
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
% Write Global Attributes                             |
%------------------------------------------------------
    cdflib.putAttrgEntry(cdf_id, type,       0, 'CDF_BYTE', strjoin({mode level optdesc}, '_'));
    cdflib.putAttrgEntry(cdf_id, version,    0, 'CDF_BYTE', version);
    cdflib.putAttrgEntry(cdf_id, desc,       0, 'CDF_BYTE', 'AFG-DFG-SCM');
    cdflib.putAttrgEntry(cdf_id, dscln,      0, 'CDF_BYTE', 'Space Physics>Magnetospheric Science');
    cdflib.putAttrgEntry(cdf_id, gen_date,   0, 'CDF_BYTE', datestr(now(), 'yyyymmdd'));
    cdflib.putAttrgEntry(cdf_id, inst_type,  0, 'CDF_BYTE', 'Magnetic Fields (space)');
    cdflib.putAttrgEntry(cdf_id, file_id,    0, 'CDF_BYTE', fname);
    cdflib.putAttrgEntry(cdf_id, src,        0, 'CDF_BYTE', strjoin({instID 'afg-dfg-scm' mode level optdesc}, '_'));
    cdflib.putAttrgEntry(cdf_id, src_desc,   0, 'CDF_BYTE', '');
    cdflib.putAttrgEntry(cdf_id, mission,    0, 'CDF_BYTE', 'MMS');
    cdflib.putAttrgEntry(cdf_id, pi_affil,   0, 'CDF_BYTE', 'SWRI, UNH');
    cdflib.putAttrgEntry(cdf_id, pi,         0, 'CDF_BYTE', 'J. Burch, R. Torbert)');
    cdflib.putAttrgEntry(cdf_id, project,    0, 'CDF_BYTE', 'STP>Solar Terrestrial Physics');
    cdflib.putAttrgEntry(cdf_id, src_name,   0, 'CDF_BYTE', 'MMS#>MMS Satellite Number #');
    cdflib.putAttrgEntry(cdf_id, text,       0, 'CDF_BYTE', ['The merged magnetic field ', ...
        'dataset is a combination of the DFG and SCM magnetometers. Merging is done in the', ...
        'frequency domain in the same step as data calibration. Instrument papers for DFT', ...
        'and SCM can be found at the following links: ', ...
        '', ...
        '']);
    cdflib.putAttrgEntry(cdf_id, link,       0, 'CDF_BYTE', 'http://mms-fields.unh.edu/');
    cdflib.putAttrgEntry(cdf_id, link,       1, 'CDF_BYTE', 'http://mms.gsfc.nasa.gov/index.html');
    cdflib.putAttrgEntry(cdf_id, link_text,  0, 'CDF_BYTE', 'UNH FIELDS Home Page');
    cdflib.putAttrgEntry(cdf_id, link_text,  1, 'CDF_BYTE', 'NASA MMS Home');
    cdflib.putAttrgEntry(cdf_id, link_title, 0, 'CDF_BYTE', 'UNH FIELDS');
    cdflib.putAttrgEntry(cdf_id, link_title, 1, 'CDF_BYTE', 'NASA MMS Home');
    cdflib.putAttrgEntry(cdf_id, mods,       0, 'CDF_Bg4YTE', 'v0.0.0 -- First version.');
    cdflib.putAttrgEntry(cdf_id, acknow,     0, 'CDF_BYTE', '');
    cdflib.putAttrgEntry(cdf_id, genby,      0, 'CDF_BYTE', '');
    cdflib.putAttrgEntry(cdf_id, parents,    0, 'CDF_BYTE', 'CDF>Logical_file_id');
    cdflib.putAttrgEntry(cdf_id, skel_ver,   0, 'CDF_BYTE', '');
    cdflib.putAttrgEntry(cdf_id, rules,      0, 'CDF_BYTE', '');
    cdflib.putAttrgEntry(cdf_id, time_res,   0, 'CDF_BYTE', '');
    
    
    
    
    
%------------------------------------------------------
% Variables                                           |
%------------------------------------------------------
    % Create variables
    %   - MMS variables must adhere to the following naming conventions
    %       scId_instrumentId_paramName_optionalDescriptor
    varnum = cdflib.createVar(cdf_id, 'DEPEND_0', '
    
end

%
% Dissect an MMS file name. The file name format is:
%
%   scId_instrumentId_mode_dataLevel_optionalDataProductDescriptor_startTime_vX.Y.Z.cdf
%
% :Params:
%   INSTRUMENTID:       in, required, type=char
%                       Instrument or investigation identifier
%   MODE:               in, required, type=string
%                       Instrument telemetry mode.
%   DATALEVEL:          in, required, type=string
%                       Level of the data product.
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
function [instID, mode, level, optdesc, startTime, version] = mms_dissect_filename(filename)
    
    % Form a recular expression to take apart the file name.
    parts = regexp(filename, ['(mms[1-4])_', ...                % Instrument ID
                              '([a-z]{4})_', ...                % Instrument Mode
                              '([a-z1-2]+)_', ...               % Data Level
                              '(.*)_', ...                      % Optional Descriptor
                              '([0-9]+)_', ...                  % Start Time
                              '(v[0-9]+\.[0-9]+\.[0-9]+)', ...  % Version
                              '.cdf'], ...                      % Extension
                              'tokens');
    % Extract the parts
    instID    = parts{1};
    mode      = parts{2};
    level     = parts{3};
    optdesc   = parts{4};
    startTime = parts{5};
    version   = parts{6};
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