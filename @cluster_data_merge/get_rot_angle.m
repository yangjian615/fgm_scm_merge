function [rot_angle] = get_rot_angle(obj, sc)
    %
    %   set up to rotate the FG to near the staff coordinates
    %   we also negate the z component of FGM for correlation purposes
    %   THis is now for both NM and BM1 data
    %   NOte:  We use the transpose of the matrix to save time.
    %   We also swap around the FSR data in order to make comparisons easier
    %
    %     Y(FSR)  ---> 1
    %     Z(FSR)  ---> 2
    %     X(FSR)  ---> 3
    %
    switch obj.sc
        case '1'
            rot_angle = (53.0) * pi/180;
        case '2'
            rot_angle = (52.5) * pi/180;
        case '3'
            rot_angle = (51.8) * pi/180;
        case '4'
            %  angle has not been determined for C4
            rot_angle = (52.5) * pi/180;
    end
end