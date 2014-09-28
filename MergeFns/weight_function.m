function [w] = weight_function(pwr_fgm, pwr_scm, ref_pwr_fgm, ref_pwr_scm)
    %
    % Calculate the weight that FGM and SCM should be given when
    % combining their respective data.
    %

    % Calculate the power level that is above the noise floor
    PLevel_FGM = (pwr_fgm - ref_pwr_fgm);
    PLevel_SCM = (pwr_scm - ref_pwr_scm);

    % Create a weight function that is the percent of the total
    % power level above the noise floor that makes up the FGM power
    % level.
    w = PLevel_FGM ./ (PLevel_FGM + PLevel_SCM);

    % At those frequencies,
    % if both FGM < 0 and SCM < 0 then average the two (w = 0.5)
    % if FGM < 0, then only use SCM data (w = 0)
    % if SCM < 0, then only use FGM data (w = 1)
    w(PLevel_FGM <= 0 & PLevel_SCM <= 0) = .5;
    w(PLevel_FGM <= 0) = 0;
    w(PLevel_SCM <= 0) = 1;
end