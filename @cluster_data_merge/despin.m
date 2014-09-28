
function [despun] = despin(obj, t, data, sc, date, attitude_dir, srt_dir)
    %
    % Rotate data from a frame in which the fields are spinning and the spacecraft is
    % static to one in which the fields are static and the spacecraft is spinning.
    %
    dt = mode(diff(t));

    % Get the number of radians the spacecraft spins every second
    omega = obj.get_attitude(sc, date, t(1), attitude_dir);

    % Get the Sun-Reference Times
    srtime = obj.get_srtime(sc, date, srt_dir);
    
    % Despin the data
    despun = SCS(data, omega, dt, t, srtime);
end