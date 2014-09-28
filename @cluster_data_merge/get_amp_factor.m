function [] = get_amp_factor(obj)
    %
    %   The amplitude correction factor is determined by on-the-
    %   ground callibration done before flight. It is the factor by which SCM data needs
    %   to be multiplied by in order to match FGM data.
    %
    switch obj.sc
        case '1'
            obj.amp_factor = 1.24;
        case '2'
            obj.amp_factor = 1.073;
        case '3'
            obj.amp_factor = 1.073;
        case '4'
            %  amp_factor has (somewhat) not been determined for C4
            obj.amp_factor = 1.08;
    end
end