function IM = sload(FNAMEFMT)
%SLOAD Loads z-stack
%   IM = SLOAD(FNAMENT) loads images from z-stack in current directory
%   with file name format FNAMEFMT and saved it into variable IM
%
%   Input-output specs
%   ==================
%   FNAMEFMT    - string (file name format like 's_C002Z%03d.tif')
%   IM          - double (image)
%
%   Author
%   ======
%   Sergey Shuvaev, 2014. sshuvaev@cshl.edu

%Building the file list

files = dir(FNAMEFMT);
NUM = length(files);

%Determining ithe mage size

TMP = imread(files(1).name);
TMP = TMP(:, :, 1);
[M, N] = size(TMP);
IM = zeros(M, N, NUM);

%Loading the images

for i = 1 : NUM
    fprintf('%d ', i)
    TMP = imread(files(i).name);
    TMP = TMP(:, :, 1);
    IM(:, :, i) = double(TMP);
end

fprintf('\n')

%Plotting the maximum intensity projection of the result

imagesc(max(IM, [], 3)); axis image; colormap hot; colorbar;

end
