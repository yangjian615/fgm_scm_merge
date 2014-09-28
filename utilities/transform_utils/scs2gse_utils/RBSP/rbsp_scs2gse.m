function [b_gse] = rbsp_scs2gse(b_uvw, et, sc, varargin)
    %
    % Transform from the RBSP science system (UVW) to GSE
    %
    % b_gse = rbsp_scs2gse(b_uvw, et, sc, ...
    %                      'kernel', kernel -- The filename of the kernel containing the
    %                                          necessary clock information. Not necesary
    %                                          if kernels have already been loaded.
    %                      'n_sec', n_sec)  -- The number of seconds to manually despin.
    %

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check Inputs \\\\\\\\\\\\\\\\%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    inputs = inputParser;
    inputs.addRequired('b_uvw');
    inputs.addRequired('et');
    inputs.addRequired('sc');
    inputs.addParamValue('kernel', '');
    inputs.addParamValue('n_sec', 0);
    
    inputs.parse(b_uvw, et, sc, varargin{:});
    
    inputs = inputs.Results;
    b_uvw = inputs.b_uvw;
    et = inputs.et;
    sc = inputs.sc;
    kernel = inputs.kernel;
    n_sec = inputs.n_sec;
    clear inputs
    
    % Get the NAIF name for the RBSP science frame 
    switch sc
        case 'A'
            asc_spice_science = 'RBSPA_SCIENCE';
        case 'B'
            asc_spice_science = 'RBSPB_SCIENCE';
    end
    
    % Load the kernel if one was given.
    if ~strcmp(kernel, '')
        cspice_furnsh(kernel);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Transform to GSE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    twopi = 2*pi;
    
    % Allocate memory for the new data arrays
    b_gse = zeros(size(b_uvw));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Transform Each Point Using CSPICE? \\\\\\\\\\\ %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if n_sec == 0
    
        for ii = 1:length(et)
            if mod(ii, 1000) == 0
                msg = sprintf('Transforming Point %i of %i', ii, length(et));
                disp(msg)
            end
            
            % Get the state and transformation matrix to GSE
            xform = cspice_sxform(asc_spice_science, 'GSE', et(ii));
            rbsp_sci2gse = cspice_xf2rav(xform);
            
            % Rotate to GSE
            b_gse(ii, :) = rbsp_sci2gse * b_uvw(ii, :)';
        end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Or Manually Despin 'n_sec' Blocks of Data First? \\\\ %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        % Allocate memory to the partially despun array
        b_uvw_prime = b_gse;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Break Data into Blocks 'n_sec' Seconds Long \\\\ %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        % Create an array to bin the times. Make sure the last element is
        % included.
        edges = et(1):n_sec:et(end);
        if edges(end) ~= et(end)
            edges = [edges et(end)];
        end
        n_edges = length(edges);
        
        % Find the indices that fall within edges(k) <= t < edges(k+1). The
        % last point in "t" will be put in its own bin. Fix this by putting
        % it in the previous bin.
        [~,bins] = histc(et, edges);
        bins(end) = bins(end-1);
        
        [~, unique_bin_inds] = unique(bins);
        times_to_despin = et(unique_bin_inds);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Despin Each Block and Transform to GSE \\\\\\\\\ %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for ii = 1:n_edges-1
            % Get the transformation matrix and the spacecraft's angular
            % velocity for the current block of data.
            xform = cspice_sxform(asc_spice_science, 'GSE', times_to_despin(ii));
            [rbsp_sci2gse, angular_velocity] = cspice_xf2rav(xform);

            % Get the spin rate and period
            spin_rate = cspice_vnorm(angular_velocity);
            spin_period = twopi / spin_rate;

            % Find the indices of the current bin.
            this_bin = find(bins == ii);
            istart = this_bin(1);
            
            % Calculate how far the spacecraft has rotated since the first
            % bin time.
            theta = twopi * (et(this_bin) - et(istart))/spin_period;
            costheta = cos(theta)';
            sintheta = sin(theta)';
            
            % Despin the data.
            b_uvw_prime(this_bin, 1) = ...
                b_uvw(this_bin, 1) .* costheta - ...
                b_uvw(this_bin, 2) .* sintheta;
            
            b_uvw_prime(this_bin, 2) = ...
                b_uvw(this_bin, 1) .* sintheta + ...
                b_uvw(this_bin, 2) .* costheta;
            
            b_uvw_prime(this_bin, 3) = ...
                b_uvw(this_bin, 3);
            
            % Transform to GSE.
            b_gse(this_bin, :) = rotate_vector_array(rbsp_sci2gse, b_uvw_prime(this_bin, :));
        end
    end
    
    % Unload the kernel.
    if ~strcmp(kernel, '')
        cspice_unload(kernel);
    end
    
end