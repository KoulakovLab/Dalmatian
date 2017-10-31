function [X, Y, Z] = runme(IM, IMREF)
%RUNME Find spots in image
%   [X, Y, Z] = runme(IM, IMREF)
%   You have to run it in your active directory with z-stack.
%   Be sure you have set apporopriate values FNAMEFMT
%   (file name format like like 's_C001Z*.tif').
%
%   USAGE: [X, Y, Z] = runme('load', 'noref');
%
%   Input-output specs
%   ==================
%   FNAMEFMT    - string (file name format like 's_C001Z*.tif')
%   NTR         - number (number of trials for bootstrap)
%   R           - double (region of interest radius for bootstrap, pixels)
%   THRESHOLD   - double (noise reduction level for watershed, 0-4095)
%   LOWPASS     - double (sigma for low-pass (noise) filter, pixels)
%   HIPASS      - double (sigma for hi-pass (background) filter, pixels)
%   MINREG      - number (minimal region size for stats calculation, voxels)
%   S           - struct (region statistics)
%   A           - double (filtered image)
%   C           - double (watrsheded regions)
%   X           - number (x coordinates of cells)
%   Y           - number (y coordinates of cells)
%   Z           - number (z coordinates of cells)
%   CONFLVL 	- double (confidence that spot sigmas match criteria, 0-1)
%   S1MIN       - double (min value of spot 1 sigma, pixels)
%   S1MAX       - double (max value of spot 1 sigma, pixels)
%   S2MIN       - double (min value of spot 2 sigma, pixels)
%   S2MAX       - double (max value of spot 2 sigma, pixels)
%   S3MIN       - double (min value of spot 3 sigma, pixels)
%   S3MAX       - double (max value of spot 3 sigma, pixels)
%   IMMIN       - double (min value of spot intensity)
%   IMMAX       - double (max value of spot intensity)
%   SZ          - number (size of square for task splitting)
%   OVERLAP     - number (size of overlap for task splitting)
%   INTERACT    - number (1 - yes, 0 - no)
%   SCALE       - number (scale to resize image)
%   IMREF       - number (reference image for equalization)
%
%   Author
%   ======
%   Sergey Shuvaev, 2014. sshuvaev@cshl.edu

%Predefined values for sload

FNAMEFMT  = '*C0*.tif';   %To read the first channel of the dataset (regular expression).

%Predefined values for sstat

NTR       = 1000;         %Number of bootstrap trials
R         = 7;            %Radius of the region for the bootstrap
THRESHOLD = 0;            %Intensity threshold (absolute value): no threshold
LOWPASS   = 2;            %Low-pass filter standard deviation (in pixels) to reduce pixel noise
HIPASS    = 100;          %Hi-pass filter standard deviation (in pixels): substantially larger than the cell
MINREG    = 100;          %Minimal region size (in voxels) to calculate the statistics

%Predefined values for sselect

CONFLVL   = 0.1;          %P-value for the putative cell to match the following criteria
S1MIN     = 0;            %Standard deviations of the data (in pixels), fitted with Gaussian distribution:
S1MAX     = Inf;          %no limits
S2MIN     = 0;
S2MAX     = Inf;
S3MIN     = 0;
S3MAX     = Inf;
IMMIN     = 0;            %Signal intensity: no limits
IMMAX     = Inf;

%Task splitting parameters

SZ        = 500;          %Splitting the task into squares of the given size (in pixels) to fit the RAM.
OVERLAP   = 40;           %Overlap of the squares (in pixels) the task is divided into
INTERACT  = 1;            %1 - interact, 0 - no interaction

if strcmp(IM, 'load')
    IM = sload(FNAMEFMT);
end

if ~strcmp(IMREF, 'noref')
    IMlin = histeq(IM(:) / max(IM(:)), ...
        imhist(IMREF(:) / max(IMREF(:)), 1000)) * max(IMREF(:));
    IM(:) = IMlin(:);
end

%Resizing image

SCALE = 1;

if SCALE ~= 1
    IM = ssubr(IM, SCALE);
end

%Splitting task

X = [];
Y = [];
Z = [];

A = size(IM, 1);
B = size(IM, 2);

imax = ceil(A / SZ);
jmax = ceil(B / SZ);

for i = 1 : imax
    for j = 1 : jmax
        fprintf('region (%d, %d) of (%d, %d)\n', i, j, imax, jmax)
        
        im = IM(max(1, 1 + (i - 1) * SZ - OVERLAP) : min(A, i * SZ + OVERLAP), ...
            max(1, 1 + (j - 1) * SZ - OVERLAP) : min(B, j * SZ + OVERLAP), : );
        
        [S, ~, ~] = sstat(im, NTR, R, THRESHOLD, LOWPASS, HIPASS, MINREG);
        [x, y, z] = sselect(im, S, CONFLVL, S1MIN, S1MAX, S2MIN, S2MAX,...
            S3MIN, S3MAX, IMMIN, IMMAX, INTERACT);
        
        %Selecting spots with no overlap
        
        ind = find((x >= 1 + sign(i - 1) * OVERLAP) .* ...
            (x <= 1 + SZ + sign(i - 1) * OVERLAP) .* ...
            (y >= 1 + sign(j - 1) * OVERLAP) .* ...
            (y <= 1 + SZ + sign(j - 1) * OVERLAP));
        
        x = x + (i - 1) * SZ - sign(i - 1) * OVERLAP;
        y = y + (j - 1) * SZ - sign(j - 1) * OVERLAP;
        
        X = [X, x(ind)];
        Y = [Y, y(ind)];
        Z = [Z, z(ind)];
    end
end

%Output total image with detected spots

figure
imagesc(max(IM, [], 3)), axis image, colormap gray;
title('Original image with detected objects')
hold on

plot(Y, X, 'r+', 'MarkerSize', 10, 'linewidth', 0.5);
hold off

end
