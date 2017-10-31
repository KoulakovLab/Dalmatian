function [S, A, C] = sstat(IM, NTR, R, THRESHOLD, LOWPASS, HIPASS, MINREG)
%SSTAT Calculates statistics of Gaussian candidates in image
%   [S, A, C] = SSTAT(IM, NTR, R, THRESHOLD, LOWPASS, HIPASS, MINREG)
%   filters image IM with Gaussian bandpass filter and saves result to A
%   makes watershed transformation of A and saves regions to C
%   calculates statistics (Gaussian sigmas, intensity) of regions from C
%   and saves it to structure S. Bootstrap algorhitm is used.
%
%   Input-output specs
%   ==================
%   IM          - double (image)
%   NTR         - number (number of trials for bootstrap)
%   R           - double (region of interest radius for bootstrap, pixels)
%   THRESHOLD   - double (noise reduction level for watershed)
%   LOWPASS     - double (sigma for low-pass (noise) filter, pixels)
%   HIPASS      - double (sigma for hi-pass (background) filter, pixels)
%   MINREG      - number (minimal region size for stats calculation, voxels)
%   S           - struct (region statistics)
%   A           - double (filtered image)
%   C           - double (watrsheded regions)
%
%   Author
%   ======
%   Sergey Shuvaev, 2014. sshuvaev@cshl.edu

%original data

figure(1)
IM = double(IM);
imagesc(max(IM, [], 3)), axis image, colormap jet
title('Original image');
drawnow

%bandpass filtering

figure(2)
disp('Preprocessing the image ...')
A = sgauss(IM, LOWPASS, HIPASS);
A = (A - THRESHOLD) .* (A > THRESHOLD);
image(max(A, [], 3),'CDataMapping','scaled'), axis image, colormap jet
title('Preprocessed image')
drawnow

%watersheding

A_ = median(IM(IM > 0));
maxA = max(A(:));
disp('Performing watershed');

figure(3)
C = watershed(- A);
dispC = (C > 0) .* A;
imagesc(dispC(:, :, floor(size(dispC, 3) / 2))), axis image, colormap jet
title('Watersheded image')
drawnow

%computing region properties

disp('Computing region properties');
S = regionprops(C, A, 'PixelIdxList', 'MaxIntensity');

%creating Xs and Ys of the entire data

[N, M, K] = size(A);
x = 1 : N;
y = 1 : M;
z = 1 : K;
[X, Y, Z] = ndgrid(x, y, z);

for i = 1 : length(S)
    
    %getting indices of selected region
    
    ind = S(i).PixelIdxList;
    
    if size(ind, 1) > MINREG
        
        if mod(i, 100) == 0
            fprintf('%2.0f %% done\n', 100 * i/length(S))
        end
        
        %creating Xs, Ys and corresponding values of selected region of unfiltered image
        
        x = X(ind);
        y = Y(ind);
        z = Z(ind);
        a = A(ind);
        im = IM(ind);
        
        %finding absolute maximum of selected region of unfiltered image
        
        [~, iii] = max(a);
        x0 = x(iii);
        y0 = y(iii);
        z0 = z(iii);
        r = sqrt((x - x0) .^ 2 + (y - y0) .^ 2 + (z - z0) .^ 2);
        
        %leaving non-zero only values in certain circle
        
        ind = find(r < R);
        xx = x(ind);
        yy = y(ind);
        zz = z(ind);
        im = im(ind);
        
        %finding eigenvalues (and therefore sigmas) im selected circle
        
        warning('off', 'MATLAB:nearlySingularMatrix');
        warning('off', 'MATLAB:singularMatrix');
        B = sbootstrap(xx - x0, yy - y0, zz - z0, im, A_, NTR);
        
        sigma1 = zeros(size(B, 1), 1);
        sigma2 = zeros(size(B, 1), 1);
        sigma3 = zeros(size(B, 1), 1);
        
        for k = 1 : size(B, 1)
            if ~(isnan(sum(B(k, :))) || isinf(sum(B(k, :))))
                sigma0 = eig([ ...
                    B(k, 2)        B(k, 5) / 2     B(k, 7) / 2
                    B(k, 5) / 2	B(k, 3)         B(k, 6) / 2
                    B(k, 7) / 2    B(k, 6) / 2     B(k, 4)]);
                
                %finding corresponding sigmas
                
                [~, ax] = sort([B(k, 2), B(k, 3), B(k, 4)]);
                
                sigma1(k) = sqrt(abs(B(k, 1) / sigma0(ax(1))) / 2);
                sigma2(k) = sqrt(abs(B(k, 1) / sigma0(ax(2))) / 2);
                sigma3(k) = sqrt(abs(B(k, 1) / sigma0(ax(3))) / 2);
            else
                sigma1(k) = NaN;
                sigma2(k) = NaN;
                sigma3(k) = NaN;
            end
        end
        
        %writing data to the object
        
        S(i).sigma1 = sigma1;
        S(i).sigma2 = sigma2;
        S(i).sigma3 = sigma3;
        S(i).intensity = B(:, 1);
        
        S(i).s1mean = mean(sigma1);
        S(i).s2mean = mean(sigma2);
        S(i).s3mean = mean(sigma3);
        S(i).imean = mean(B(:, 1));
        
        S(i).idiff = max(im(:)) - min(im(:));
        
        S(i).X = x0;
        S(i).Y = y0;
        S(i).Z = z0;
    end
end

%plot statistics

figure

tmp = [S.s1mean];
subplot(2, 2, 1)
hist(tmp .* (tmp < 20), 0.5 : 0.5 : 19.5);
title('lateral sigma 1');

tmp = [S.s2mean];
subplot(2, 2, 2)
hist(tmp .* (tmp < 20), 0.5 : 0.5 : 19.5);
title('lateral sigma 2');

tmp = [S.s3mean];
subplot(2, 2, 3)
hist(tmp .* (tmp < 20), 0.5 : 0.5 : 19.5, 'grey');
title('axial sigma');

tmp = [S.imean];
subplot(2, 2, 4)
tmp = hist(tmp .* (tmp > 0) .* (tmp < 99), 0 : 4096);
tmp(1) = 0;
plot(tmp);
title('intensity');
drawnow

end
