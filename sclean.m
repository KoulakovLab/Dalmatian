function sclean(chA, chB, prefix)
%SBATCH performs serial call of runme for the entire folder
%   sclean(chA, chB)
%   You have to run it in your active directory with z-stack subfolders
%
%   USAGE: sclean(1, 3)
%
%   Input-output specs
%   ==================
%
%   CHA         - number (of first channel to compare)
%   CHB         - number (of first channel to compare)
%
%   Author
%   ======
%   Sergey Shuvaev, 2014. sergey.shuvaev@phystech.edu

%For every subfolder

ds = dir;

mkdir('result');

for i = 1 : length(ds)
    if (ds(i).isdir && ~strncmp(ds(i).name, '.', 1))
        ds(i).name
        cd(ds(i).name);
        
        mkdir('../result', ds(i).name);
        
        %Copy unused files
        
        unf = dir;
        
        for j = 1 : length(unf)
            if (~strncmp(unf(j).name, '.', 1) && ...
                isempty(strfind(unf(j).name, strcat(prefix, num2str(chA)))) && ...
                isempty(strfind(unf(j).name, strcat(prefix, num2str(chB)))))
                copyfile(unf(j).name, ...
                        strcat('../result/', ds(i).name, '/', unf(j).name));
            end
        end
        
        %Perform cleaning
        
        IM1 = sload(strcat('*', prefix, num2str(chB), '*'));
        IM0 = sload(strcat('*', prefix, num2str(chA), '*'));
        IM0t = histeq(IM0(:) / max(IM0(:)), ...
               imhist(IM1(:) / max(IM1(:)), 1000)) * max(IM1(:));
        IM0(:) = IM0t(:);
        ImA = (IM0 - IM1) .* (IM0 - IM1 > 0);
        ImB = (IM1 - IM0) .* (IM1 - IM0 > 0);
        
        %Normalize for TIFF format
        
        ImA = ImA / max(ImA(:));
        ImB = ImB / max(ImB(:));
        
        %Saving result
        
        cd('../result');
        cd(ds(i).name);
        
        for j = 1 : size(ImA, 3)
            imwrite(ImA( : , : , j ), strcat('image_C', num2str(chA), ...
                    '_Z',  sprintf('%.3d', j - 1), '.tif'), 'tif');
        
            imwrite(ImB( : , : , j ), strcat('image_C', num2str(chB), ...
                    '_Z',  sprintf('%.3d', j - 1), '.tif'), 'tif');
        end
        
        cd('../../');
        close all
    end
end

end

