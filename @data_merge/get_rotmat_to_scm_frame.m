function [] = get_rotmat_to_scm_frame(obj)
    %
    %   Define a rotation matrix using the angles in obj.get_rot_angle() that will
    %   rotate the FGM coordinate system into aligment with the SCM system.
    %
    %   NOTE:  We use the transpose of the matrix to save time
    %   (i.e. so we do not have to transpose the entire data array:
    %       |x'|       |x|             
    %       |y'| = A * |y| = |x y z| * transpose(A)
    %       |z'|       |z|
    %
    %	NOTE: The spin axis is assumed to be the third component.
    %
    rot_angle = obj.get_rot_angle;
    
    obj.rotmat_to_scm = [ cos(rot_angle)  sin(rot_angle)    0; ...
                         -sin(rot_angle)  cos(rot_angle)    0; ...
                                 0               0          1]';
end
