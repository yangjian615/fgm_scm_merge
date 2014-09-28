
function [despun] = despin(obj, t, data, sc, date, attitude_dir, srt_dir)
    %
    % Rotate data from a frame in which the fields are spinning and the spacecraft is
    % static to one in which the fields are static and the spacecraft is spinning.
    %
    % This algorithm depends on the attitude of the spacecraft and, hence, is mission
    % specific. This method should be over-ridden with a mission-specific 
    % @[spacecraft]_data_merge object.
    %
            
    error(['This is just a place-holder function. ' ...
           'Overwrite this method to make it data-type/mission specific.'])
end