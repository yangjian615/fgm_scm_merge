function [comp] = fcompst(N, del_f, tr_freq, transf)
    %
    %   Routine to compute compensate array for transfer function
    %
    %   This computes the complex array comp by interpolation of the
    %   transfer function, transf, at given frequencies, tr_freq,
    %   and puts the complex conjugate values in the upper half of the
    %   compensation array
    %
    %   NOTE: N is the number of frequencies to compensate and should be EVEN !
    %
    %   NOTE: The NaN value for frequencies outside the range of tr_freq should be
    %
    %                       comp(isnan(comp)) = 0
    %
    %                             OR
    %                       
    %                       comp(isnan(comp)) = Inf 
    %
    %         Depending on whether the spectra is multiplied- or divided-by the transfer
    %         function.
    %
    %         Here, it is assumed that the spectra is multiplied by the transfer function
    %         in 'apply_tranf.m' and so comp(isnan(comp)) = 0.
    %
    pivot = N/2;
    freq_out = (1:pivot)';
    freq_out = del_f * freq_out ;
    comp = interp1(tr_freq, transf, freq_out, 'linear');
    comp(pivot) = abs( comp(pivot));
    %
    %   values outside the range are effectively removed from the fft 
    %   and the DC value is not changed.
    %
    comp(isnan(comp)) = 0;
    comp = [ 1 ; comp ; (1:(pivot-1))' ]; 
    for jk = pivot+2:N
        comp(jk) = conj ( comp(N-jk+2));
    end
end