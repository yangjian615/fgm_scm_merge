%--------------------------------------------------------------------------
% NAME
%   fast_rotat
%
% PURPOSE
%   Rotate a counter-clockwise spinning coordinate system backwards to a
%   fixed location within the spin. Also, transform the axes so that
%       x -> z'
%       y -> x'
%       z -> y'
%
% INPUTS
%   V_IN:           in, required, type=3xN double
%                   3-component vector data to be tranformed.
%   DT:             in, required, type=float
%                   Sampling period at which V_IN was recorded.
%   N_ROTATE:       in, required, type=long
%                   Number of points in V_IN being transformed.
%   OMEGA:          in, required, type=double
%                   Spin rate of the spacecraft, in revolutions per second.
%
% RETURNS
%   V_OUT:          out, optional, type=3xN double
%                   V_IN rotated from a spinning system into an inertial
%                       system.
%--------------------------------------------------------------------------
function v_out = fast_rotat(v_in, dt, N_rotate, OMEGA)
    % We consider dt and OMEGA to be fixed.
    %   - Rotation matrices change only if the number of points change
    persistent sin_rot cos_rot L_rotate

    % Build rotation
    %   - alt. N_rotate = 2*pi/(dt_staff*omega);
    if ( isempty(cos_rot) || (N_rotate~= L_rotate))
        L_rotate = N_rotate;
        cos_rot  = -OMEGA*dt*(0:N_rotate-1)';
        sin_rot  =  single( sin( cos_rot ) );
        cos_rot  =  single( cos( cos_rot ) );
    end
    
    %
    % The transform
    %   | 0  cos_rot -sin_rot | | Vx |   | Vx' |
    %   | 0  sin_rot  cos_rot | | Vy | = | Vy' |
    %   | 1     0        0    | | Vz |   | Vz' |
    %
    %   - Cluster rotates counter-clockwise about its x-axis.
    %   - Must rotate system clockwise to despin
    %       o i.e. a counter-clockwise rotation of angle -theta
    %   - Cluster's X-axis points South and is within 2-7 degrees of -zGSE.
    %   - Exhange the axes so that the spin-axis is along the z'-axis.
    %       o x -> z'
    %       o y -> x'
    %       o z -> y'
    %
    v_out(:,1) = cos_rot.*v_in(1:N_rotate,2) + sin_rot.*v_in(1:N_rotate,3);
    v_out(:,2) = cos_rot.*v_in(1:N_rotate,3) - sin_rot.*v_in(1:N_rotate,2);
    v_out(:,3) = v_in(1:N_rotate,1);
end