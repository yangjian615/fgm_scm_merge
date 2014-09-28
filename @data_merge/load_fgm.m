function [] = load_fgm(obj)
    %
    % Read FGM time and magnetic field data and store them in the object
    % properties 't' and 'b'.
    %
    % Loading data depends on the data type. This just serves as a place-holder
    % for @data_merge objects specific to a mission and data-type. Over-ride this
    % method with your own file reading algorithm.
    %
    
    error(['This is just a place-holder function. ' ...
           'Overwrite this method to make it data-type/mission specific.'])

end