function [data_obj] = get_inst_obj(mission)
    %
    % Create an instance of FGM or SCM data object specific to the given
    % mission.
    %

    % Which mission?
    switch mission
        case 'C'
            data_obj = cluster_data_merge();
        case 'RBSP'
            data_obj = rbsp_data_merge();
    end
end