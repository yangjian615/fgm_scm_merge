classdef rbsp_data_merge < data_merge
    %
    % RBSP_DATA_MERGE Load data, calibrate, and prepare RBSP data for
    % merging
    %
    %   The original merging class was data_merge, but RBSP has
    %   differend calibration and telemetry details, so the relevant
    %   methods were overridden here. Basic differences are:
    %
    %       1. Read FGM, SCM and transfer function data
    %       2. Despin and Rotate to GSE
    %

    %
    %-------------------------------------------------------------------------------------
    % SPACECRAFT NOTES
    %-------------------------------------------------------------------------------------
    %
    % CDF FILES (continuous-burst):
    %
    %   Email from Dan Crawford (daniel-crawford@uiowa.edu):
    %
    %   The continuous burst mode is a series of waveforms, so really
    %   its a time-series stacked in a way that the ISTP is considering 
    %   standardizing. The Epoch variable has 96 time-tags for that
    %   day, and each channel starts at the corresponding time tag
    %   (the first dimension you list below). There are 208896 samples
    %   per channel per start-time, and each sample is separated from 
    %   the next by a time factor equal one over the sample frequency
    %   of 35khz. The variable "timeOffsets" in the CDF is a table 
    %   pre-built of the time differences using this code:
    %
    %       for (int i = 0; i < numSamples; i++) {
    %           timeOffsets[i] = (float) (i / sampleFrequency);
    %
    %
    % AMPLITUDE CORRECTION FACTOR:
    %
    %   The amplitude correction factor is determined by on-the-
    %   ground callibration done before flight. It is the 
    %   multiplicative difference between SCM and FGM amplitudes.
    %
    %   For RBSP data, there is no difference in amplitude EXCEPT
    %   for when the search coil attenuator is on. Email from
    %   Terrance Averkamp (terrance-averkamp@uiowa.edu):
    %
    %   This does not account for any attenuators being on. At the bottom
    %   of the cal file are the attenuator factors.
    %   E.G., if the search coil attenuator is on (it rarely is), then
    %   multiply all data by the factor Buvw=9.351299831
    %
    %-------------------------------------------------------------------------------------
    %
    properties
    end
    
    methods(Static = true)
    end
    
    methods
        % Instantiate
        function obj = rbsp_data_merge()
            obj@data_merge();
            
            obj.mission = 'RBSP';
            %
            % Nothing new to do here yet...
            %
        end
        
        [] = load_fgm(obj)
        [succcess] = load_scm(obj)
        [] = load_transfr_fn(obj)
    end
end