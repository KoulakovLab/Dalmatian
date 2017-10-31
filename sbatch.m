function sbatch(IMREF, CHANNEL)
%SBATCH performs serial call of runme for the entire folder
%   sbatch()
%   You have to run it in your active directory with z-stack subfolders
%
%   USAGE: sbatch('noref', 'C0')
%
%   Input-output specs
%   ==================
%   IMREF       - number (reference image for equalization)
%   FNAMEFMT    - string (file name format like 's_C001Z*.tif')
%
%   Author
%   ======
%   Sergey Shuvaev, 2014. sshuvaev@cshl.edu

%Load reference image

FNAMEFMT = strcat('*', CHANNEL, '*');

if ~strcmp(IMREF, 'noref')
    cd(IMREF);
    IMREF = sload(FNAMEFMT);
    cd('../');
end

%For every subfolder

ds = dir;
for i = 1 : length(ds)
    if (ds(i).isdir && ~strncmp(ds(i).name, '.', 1))
        ds(i).name
        cd(ds(i).name);
        
        %Perform analysis
        
        [X, Y, Z] = runme('load', IMREF);
        title(sprintf('Number of detected spots: %d', length(X)));
        
        cd('../');
        
        hgsave(strcat(ds(i).name, '_', CHANNEL, '.fig'));
        close all
        
        fout = fopen(strcat(ds(i).name, '_', CHANNEL, '.dat'), 'w');
        fprintf(fout, '%d\t %d\t %d\n', [X; Y; Z]);
        fclose(fout);
    end
end

end
