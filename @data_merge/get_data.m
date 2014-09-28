function [] = get_data(obj, inst, sc, date, tstart, tend, varargin)
    %
    % Determine which instrument class (FGM or SCM) is desired and load the time and
    % magnetic field for that instrument into the object's properties.
    %
    
    % Check inputs
    obj.check_inputs(inst, sc, date, tstart, tend, varargin{:});
    
    % get staff and fgm data in one step
    switch obj.inst
        case 'FGM'
            obj.load_fgm();
        case 'SCM'
            obj.load_scm();
        otherwise
            error('Instrument not recognized')
    end
end