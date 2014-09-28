function [] = get_rotmat_to_scm_frame(obj)
    %
    %   set up to rotate the FG to near the staff coordinates
    %   we also negate the z component of FGM for correlation purposes
    %   This is now for both NM and BM1 data
    %   NOte:  We use the transpose of the matrix to save time
    %   (i.e. so we do not have to transpose the entire data array:
    %       |x'|       |x|             
    %       |y'| = A * |y| = |x y z| * transpose(A)
    %       |z'|       |z|
    %   We also swap around the FSR data in order to make comparisons easier
    %
    %     Y(FSR)  ---> 1
    %     Z(FSR)  ---> 2
    %     X(FSR)  ---> 3
    %
    %	Note we put spin axis in third component
    %
    %   The spin axis is X(FSR).
    %
    rot_angle = obj.get_rot_angle();
    
    obj.rotmat_to_scm = [ 0    cos(rot_angle)  sin(rot_angle) ; ...
                          0   -sin(rot_angle)  cos(rot_angle) ; ...
                          1           0               0            ]';
end