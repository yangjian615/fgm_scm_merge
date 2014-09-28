function [comp] = fcompst(N, del_f, tr_freq, transf)
    %
    %  routine to compute compensate array for transfer function
    %
    %  this computes the complex array comp by interpolation of the
    %   transfer function, transf, at given frequencies, tr_freq,
    %   and puts the complex conjugate values in the upper half of the
    %   compensation array
    %
    %   N is the number of frequencies to compensate and should be EVEN !
    %
    
    % Make sure N is even
    assert(mod(N, 2) == 0, 'N must be even.');
    
    pivot       = N/2;
    freq_out    = (1:pivot)';
    freq_out    = del_f * freq_out;
    comp        = interp1(tr_freq, transf, freq_out, 'linear');
    comp(pivot) = abs( comp(pivot));
    %
    %  values outside the range are effectively removed from the fft 
    %   and the DC value is not changed.
    %
    comp(isnan(comp)) = Inf;
    comp = [ 1 ; comp ; (1:(pivot-1))' ]; 
    for jk = pivot+2:N
        comp(jk) = conj ( comp(N-jk+2));
    end
end