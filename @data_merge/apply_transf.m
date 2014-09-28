function [field] = apply_transf(field, comp, undo)
    %
    % Apply the components 1, 2, and 3 of a transfer function to
    % the respective components of a vector field array.
    %

    % check if the window is to be applied or undone
    if nargin == 3 && undo ~= 0
        undo = 1;
    else
        undo = 0;
    end

    % use the compnents of the transfer function to correct the 
    % field
    if ~undo
        field(:,1) = field(:,1) .* comp(:,1);
        field(:,2) = field(:,2) .* comp(:,2);
        field(:,3) = field(:,3) .* comp(:,3);
    else
        % no reason to undo so far
        error('Undo not implemented.');
    end
end