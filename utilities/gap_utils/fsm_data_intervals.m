%
% Name:
%   fsm_data_intervals
%
% Purpose:
%   Find continuous, overlapping segments of data among two monoton
%   datasets.
%
% Calling Sequence:
%   fgm_intervals = fsm_data_intervals(TIME_FGM, TIME_SCM)
%       Given two monotonic vectors, TIME_FGM and TIME_SCM, find continuous
%       intervals in TIME_FGM that overlatp with continuous intervals of
%       TIME_SCM. FGM_INTERVALS represents the starting and stopping index
%       values of each interval.
%
%   [fgm_intervals, scm_intervals] = fsm_find_closes(TIME_FGM, TIME_SCM)
%       Return also the start and stop intervals within TIME_SCM.
%
% Parameters:
%   TIME_FGM:       in, required, type = N-element array
%   TIME_SCM:       in, required, type = N-element array
%
% Returns:
%   FGM_INTERVALS:  out, required, type = 2xN integer array
%   SCM_INTERVALS:  out, optional, type = 2xN integer array
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% Tests:
%   See test_fsm_data_intervals.m
%
function [fgm_intervals scm_intervals] = fsm_data_intervals(time_fgm, time_scm)

	% Data lengths
	n_fgm = length(time_fgm);
	n_scm = length(time_scm);
	dn    = 1.5;

	% Data sampling interval
	si_fgm = mode(diff(time_fgm));
	si_scm = mode(diff(time_scm));

	% Allocate memory to outputs.
	fgm_intervals = zeros(2,300);
	scm_intervals = zeros(2,300);
	icount = 0;

	% Initial loop conditions
	istart_fgm = 1;
	istart_scm = 1;
	istop_fgm  = 1;
	istop_scm  = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Starting Point                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%
	% Advance SCM until it is at least equal to FGM
	%
	%       advance
	%       |------>|
	%       ^ First SCM datum
	%
	%
	% SCM   |||||||||||||||||
	% FGM            |      |
	%                ^ First FGM datum
	%

	% While SCM is before FGM
	while time_scm(istop_scm) < time_fgm(istart_fgm) && istart_scm < n_scm
		% Advance to the next time
		istop_scm = istop_scm + 1;

		% Did we advance over a data gap
		dt_scm = abs( time_scm(istop_scm) - time_scm(istop_scm-1) );
		if dt_scm > si_scm * dn
			% Store the interval
			icount = icount + 1;
			fgm_intervals(:,icount) = [istart_fgm istop_fgm];
			scm_intervals(:,icount) = [istart_scm istop_scm-1];
	
			% Next interval
			istart_scm = istop_scm;
		end
	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step Through All FGM Points   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	while istop_fgm <= n_fgm
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% While SCM < FGM               %
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%
	% We are looking ahead for data gaps, so there two cases:
	%   1. The current FGM datum occurs after a data gap.
	%   2. The current FGM datum is dt away from the previous (and possibly
	%       preceeds a data gap).
	%
	% In the former case, SCM is fast forwarded as close to the current
	% FGM point as possible. All intermediate SCM data (and data gaps)
	% falling within the FGM data gap are skipped.
	%
	% In the latter case, SCM was advanced as close to the *previous*
	% FGM point as possible without surpassing it. SCM data gaps will have
	% been taken into account.
	%
	% We must now advance SCM forward until it is greater than or equal to
	% the current FGM datum.
	%
	%                     advance
	%                     |------>|
	%   Current SCM datum ^
	%
	%              SCM     ||||||||
	%              FGM   (|)      |
	%
	%  Previous FGM datum ^       ^ Current FGM datum
	%
	%
		while istop_scm <= n_scm && time_scm(istop_scm) <= time_fgm(istop_fgm)

		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% SCM Data Gap?                 %
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
			% Sampling interval
			if istop_scm < n_scm
				dt_scm = abs( time_scm(istop_scm+1) - time_scm(istop_scm) );
			end
		
			% Data gap:
			%                 |           |
			%   Start of gap  ^           ^ End of gap
			%
			%   SCM          ||    ...    |
			%   FGM         |       |       |
			%               ^ Closest FGM datum
			%
			if (dt_scm > si_scm * dn) % || (istop_scm == n_scm)
			
				% Search for the FGM datum closest to the current SCM
				% datum.
				%   - Adjust FGM to mark the end of the data interval
				istop_fgm = fsm_find_closest(time_scm(istop_scm), time_fgm, istop_fgm);
			
				% Store the interval
				icount = icount + 1;
				fgm_intervals(:,icount) = [istart_fgm istop_fgm];
				scm_intervals(:,icount) = [istart_scm istop_scm];

				% Next interval
				istart_scm = istop_scm + 1;
			
				if istart_scm < n_scm
					istart_fgm = fsm_find_closest(time_scm(istart_scm), time_fgm, istop_fgm, 1);
					istop_fgm  = istart_fgm;
				else
					istart_scm = istop_scm;
				end
			end
		
			% Advance to the next point
			istop_scm = istop_scm + 1;
		end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% FGM Data Gap?                 %
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%
	% SCM has been advanced up to the current FGM point. Now, we must look
	% ahead in FGM to see if there is a data gap.
	%

		% Sample interval
		if istop_fgm < n_fgm
			dt_fgm = time_fgm(istop_fgm+1) - time_fgm(istop_fgm);
		end
	
		% Data gap?
		if (istop_fgm == n_fgm) || (dt_fgm > si_fgm * dn)

			% Search for the interval in SCM that matches
			%   - Adjust SCM to mark the end of the data interval
			istop_scm = fsm_find_closest(time_fgm(istop_fgm), time_scm, istop_scm);
		
			% Set the end of the interval
			icount = icount + 1;
			fgm_intervals(:,icount) = [istart_fgm istop_fgm];
			scm_intervals(:,icount) = [istart_scm istop_scm];
		
			% Beginning of the next interval
			istart_fgm = istop_fgm + 1;
		
			if istart_fgm < n_fgm
				istart_scm = fsm_find_closest(time_fgm(istart_fgm), time_scm, istop_scm, 1);
				istop_scm  = istart_scm;
			else
				istart_fgm = istop_fgm;
			end
		end

		% Advance to the next point
		istop_fgm = istop_fgm + 1;
	end
		
	% Reached the end of the FGM interval
%    istart_fgm = istop_fgm;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step to End of SCM            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%
	% If FGM terminated before SCM, advance SCM to its end.
	%
	%               advance
	%              |------->|
	%                       ^ Last SCM datum
	%
	% SCM   |||||||||||||||||
	% FGM   |      |
	%              ^ Last FGM datum
	%
	if istop_scm < n_scm
		while istop_scm <= n_scm

			if istop_scm < n_scm
				dt_scm = abs( time_scm(istop_scm+1) - time_scm(istop_scm) );
			end

			% Data gap?
			if (istop_scm == n_scm) || (dt_scm > si_scm * dn)
				% Store the interval
				icount = icount + 1;
				fgm_intervals(:,icount) = [istart_fgm istop_fgm];
				scm_intervals(:,icount) = [istart_scm istop_scm];

				% Next interval
				istart_scm = istop_scm;
			end

			% Advance to the next point
			istop_scm = istop_scm + 1;
		end
	end

	% Trim output
	fgm_intervals = fgm_intervals(:,1:icount);
	scm_intervals = scm_intervals(:,1:icount);
end



%
% Name:
%   fsm_find_closest
%
% Purpose:
%   Find the point in the time array closest to a reference time.
%
% Calling Sequence:
%   IT = fsm_find_closes(REF_TIME, TIME, INDEX)
%       Find the index IT in a monotonic TIME array that is closest to the
%       reference time, REF_TIME, starting the search at INDEX.
%
%   IT = fsm_find_closes(REF_TIME, TIME, INDEX, DIRECTION)
%       Find the index IT in a monotonic TIME array that is closest to the
%       reference time, REF_TIME, starting the search at INDEX. Search only
%       in the direction indicated by DIRECTION.
%
% Parameters:
%   REF_TIME:       in, required, type = integer
%   TIME:           in, required, type = N-element array
%   INDEX:          in, required, type = integer
%   DIRECTION:      in, optional, type = integer, default=0
%                   Possible values include:
%                       -1      Search backwards from INDEX
%                        0      Search forward and backward from INDEX (default)
%                        1      Search forward from INDEX
%
% Returns:
%   IT              out, required, type = integer 
%
% MATLAB release(s): MATLAB 7.14.0.739 (R2012a)
% Required Products: None
%
function [it] = fsm_find_closest(ref_time, time, index, direction)
	% Number of points total
	npts = length(time);
	it   = index;

	if nargin < 4
		direction = 0;
	end

	if index > npts
		it = index-1;
		return
	end

	% Look ahead one point to see if it is closer to the reference time.
	if direction >= 0 && it < npts
		dt0 = abs( time(it)   - ref_time );
		dt1 = abs( time(it+1) - ref_time );

		% If the next point is smaller, advance forward again.
		while (dt1 < dt0) && (it < npts)
			it  = it + 1;
			dt0 = dt1;
			dt1 = abs( time(it+1) - ref_time );
		end
	end

	% If the next point was larger, check backward.
	if direction <= 0 && ( (it == npts) || ( (it <= index+1) && (dt1 > dt0) ) )
		it  = index;
		dt0 = abs( time(it)   - ref_time );
		dt1 = abs( time(it-1) - ref_time );
	
		% Keep moving backward
		while dt1 < dt0 && it > 1
			it  = it - 1;
			dt0 = dt1;
			dt1 = abs( time(it-1) - ref_time );
		end
	end
end