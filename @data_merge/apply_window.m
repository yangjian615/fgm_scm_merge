function [field] = apply_window(field, win, undo)
    %
    % Apply an FFT window to each component of a vector array
    %

    % check if the window is to be applied or undone
    if nargin == 3 && undo ~= 0
        undo = 1;
    else
        undo = 0;
    end

    % undo the windowing
    if undo
        field(:,1) = field(:,1) ./ win;
        field(:,2) = field(:,2) ./ win;
        field(:,3) = field(:,3) ./ win;

    % apply the window
    else
        field(:,1) = field(:,1) .* win;
        field(:,2) = field(:,2) .* win;
        field(:,3) = field(:,3) .* win;
    end
end