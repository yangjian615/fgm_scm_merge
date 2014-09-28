function [pwr_ref, fft_ref] = merge_ref_power(inst_obj, clen_other, win)
    %
    % Take an FFT and get the power of the referenced quiet
    % interval.
    %

    %
    % The power spectra of the reference interval must be taken from the complete time
    % and magnetic field arrays because 'inst_obj.t' and 'inst_obj.b' only contain the
    % time and fields of the continuous data interval currently being processed. It also
    % must share many features (see below) with 'inst_obj'. As such, a new instance of
    % the '[mission]_data_merge' class will be created.
    %
    ref_inst = get_inst_obj(inst_obj.mission);
    
    % The reference spectra must come from the same mission, spacecraft, instrument, and
    % instrument mode
    ref_inst.inst = inst_obj.inst;
    ref_inst.sc   = inst_obj.sc;
    ref_inst.mode = inst_obj.mode;
        
    % The reference spectra must also have the same frequency bins as the spectra being
    % merged, i.e., the time interval must be the same length. Therefore, get the index
    % range into the full time and magnetic fields array of the referenced quiet interval.
    istart_ref = inst_obj.iStart_ref;
    istop_ref  = istart_ref + inst_obj.clen - 1;

    % Select the referenced time and field interval
    ref_inst.t = inst_obj.t(istart_ref:istop_ref);
    ref_inst.b = inst_obj.b(istart_ref:istop_ref, :);
    
    % We merely ensured that the reference time interval contains the same number of
    % points as the one being merged. Now we must ensure that the sampling rate is the
    % same.
    ref_inst.get_sample_rate;
    assert(abs(ref_inst.dt - inst_obj.dt) / inst_obj.dt * 100 < 5, ...
        ['The sample rate of the reference FFT interval, %f, does not match the ', ... 
         'sample rate of the current FFT interval, %f.'], ref_inst.dt, inst_obj.dt)

    % Since now we know that the reference interval is the same as the one being analyzed,
    % we can just copy over features from 'inst_obj' to 'ref_inst'. Namely, the 
    % frequencies and their bin size 
    ref_inst.df    = inst_obj.df;
    ref_inst.freqs = inst_obj.freqs;

    % Additionally, 'SCM' needs transfer function data copied over. 
    if strcmp(inst_obj.inst, 'SCM')
        ref_inst.comp = inst_obj.comp;
        clen_scm      = inst_obj.clen;
        clen_fgm      = clen_other;
    else
        clen_fgm = inst_obj.clen;
        clen_scm = clen_other;
    end
    
    % Get calibration details.
    %   FGM: the rotation matrix to the SCM frame
    %   SCM: the amplitude correction factor
    ref_inst.calibrate;

    % Now, take the FFT and apply windows and calibration factors. Then compute the power
    % spectral density of the reference interval.
    ref_inst.take_fft(1, length(ref_inst.b(:,1)), win);
    pwr_ref = weighting_psd(ref_inst.b_fft, ref_inst.dt, clen_fgm, clen_scm);
end