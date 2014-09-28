function [] = get_amp_factor(obj)
    %
    %   The amplitude correction factor is determined by on-the-
    %   ground callibration done before flight. It is the factor
    %   by which the SCM signal needs to be multiplied to scale
    %   it to FGM levels.
    %
    
    % A correction factor of 1.0 for each spacecraft in the mission.
    obj.amp_factor = 1.0;
end