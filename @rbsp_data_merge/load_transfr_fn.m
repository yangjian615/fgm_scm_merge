function [] = load_transfr_fn(obj)
    %
    % Read RBSP transfer functions
    %

    % Create the filename
    filename = [obj.TransfrFn_dir, obj.mission, '_', obj.sc, '_Cals.txt'];

    % Open file
    file_id = fopen(filename);

    % Read lines. ";Index" marks the last line of the header.
    stop = 0;
    while stop == 0
        header = fgetl(file_id);
        if length(header) > 6
            header = header(1:6);
        end

        if strcmp(header, ';Index')
            stop = 1;
        end
    end

    % Allocate data to the E(u,v,w) and B(u,v,w) transfer function arrays.
    stop = 0;
    i = 1;
    index = zeros(1000, 1);
    frequencies = zeros(1000, 1);
    Eu = zeros(1000, 1);
    Ev = zeros(1000, 1);
    Ew = zeros(1000, 1);
    Bu = zeros(1000, 1);
    Bv = zeros(1000, 1);
    Bw = zeros(1000, 1);
    
    % B(u,v,w) transfer function ends at ";".
    while stop == 0
        data = fgetl(file_id);

        if strcmp(data, ';')
            stop = 1;
        else
            num_data = sscanf(data, '%d %f %e %e %e %e %e %e %e %e %e %e %e %e');

            index(i) = num_data(1);
            frequencies(i) = num_data(2);
            Eu(i) = complex(num_data(3), num_data(4));
            Ev(i) = complex(num_data(5), num_data(6));
            Ew(i) = complex(num_data(7), num_data(8));
            Bu(i) = complex(num_data(9), num_data(10));
            Bv(i) = complex(num_data(11), num_data(12));
            Bw(i) = complex(num_data(13), num_data(14));

            i = i + 1;
        end
    end

    fclose(file_id);

    index = index(1:i-1);
    obj.transfr_freqs = zeros(i-1,3);
    obj.transfr_freqs(:,1) = frequencies(1:i-1);
    obj.transfr_freqs(:,2) = frequencies(1:i-1);
    obj.transfr_freqs(:,3) = frequencies(1:i-1);
    Eu = Eu(1:i-1);
    Ev = Ev(1:i-1);
    Ew = Ew(1:i-1);
    obj.transfr_fn(:,1) = Bu(1:i-1);
    obj.transfr_fn(:,2) = Bv(1:i-1);
    obj.transfr_fn(:,3) = Bw(1:i-1);
end