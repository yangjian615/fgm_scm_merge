function [] = calibrate(obj)
    %
    % Get calibration details.
    %   FGM: Rotation matrix to tranform FGM frame into SCM coordinate system.
    %   SCM: Amplitude correction factor to scale SCM signal down to FGM.
    %
    switch obj.inst
        case 'FGM'
            obj.get_rotmat_to_scm_frame
        case 'SCM'
            obj.get_amp_factor
    end
end
