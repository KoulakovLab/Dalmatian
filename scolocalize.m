function scolocalize( DIST, CH1, CH2 )
%SCOLOCALIZE finds colocalization between 2 datasets
%   SCOLOCALIZE( DIST, CH1, CH2 ) colocalizes cells in channels CH1 and CH2
%   in all datasets
%
%   USAGE: SCOLOCALIZE( 7, 'C0', 'C1' )
%
%   Input-output specs
%   ==================
%   DIST        - number (max distance between cells, pixels)
%   CH1         - string (name of 1 channel in dataset)
%   CH2         - string (name of 2 channel in dataset)
%
%   Author
%   ======
%   Sergey Shuvaev, 2014. sshuvaev@cshl.edu

ds = dir;
for i = 1 : length(ds)
    if (ds(i).isdir && ~strncmp(ds(i).name, '.', 1))
        ds(i).name
        
        %Loading images
        
        cd(ds(i).name);
        
        IM1 = max(sload(strcat('*', CH1, '*')), [], 3);
        IM2 = max(sload(strcat('*', CH2, '*')), [], 3);
        
        close all;
        cd('../');
        
        %Loading spots

        fin = fopen(strcat(ds(i).name, '_', CH1, '.dat'), 'r');
        if fin == -1
            continue
        end
        spots1 = fscanf(fin, '%d %d %d', [3, inf]);
        fclose(fin);
        
        fin = fopen(strcat(ds(i).name, '_', CH2, '.dat'), 'r');
        if fin == -1
            continue
        end
        spots2 = fscanf(fin, '%d %d %d', [3, inf]);
        fclose(fin);
        
        if ~isempty(spots1) && ~isempty(spots2)

            X1 = (spots1(1, :))';
            Y1 = (spots1(2, :))';
            Z1 = (spots1(3, :))';

            X2 = (spots2(1, :))';
            Y2 = (spots2(2, :))';
            Z2 = (spots2(3, :))';

            spots1 = spots1';
            spots2 = spots2';

            %Colocalization

            spots1 = DIST * round(spots1 / DIST);
            spots2 = DIST * round(spots2 / DIST);

            ind = find(ismember(spots1, spots2, 'rows') == 1);

            %Generating output

            [a, b] = size(IM1);
            IMRES = zeros(a, b, 3);
            IMRES(:, :, 1) = IM1 / max(IM1(:));
            IMRES(:, :, 2) = IM2 / max(IM2(:));

            image(IMRES), axis image
            hold on

            plot(Y1, X1, 'r+');
            axis image;
            title(sprintf('Number of detected spots: %d', length(ind)));
            hold on
            plot(Y2, X2, 'g+');
            plot(Y1(ind), X1(ind), 'yo');

            hold off

            %Saving data

            X = X1(ind);
            Y = Y1(ind);
            Z = Z1(ind);

            foutname = strcat(ds(i).name, '_coloc_', CH1, CH2);

            hgsave(strcat(foutname, '.fig'));
            close all

            fout = fopen(strcat(foutname, '.dat'), 'w');
            fprintf(fout, '%d\t %d\t %d\n', [X; Y; Z]);
            fclose(fout);
        end
    end
end

