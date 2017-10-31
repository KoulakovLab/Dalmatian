function [X, Y, Z] = sselect(IM, S, CONFLVL, S1MIN, S1MAX, S2MIN, S2MAX,...
                             S3MIN, S3MAX, IMMIN, IMMAX, INTERACT)
%SSELECT Select cells from cell candidates
%   [X, Y, Z] = SSELECT(IM, S, CONFLVL, S1MIN, S1MAX, S2MIN, S2MAX, S3MIN,
%   S3MAX, IMMIN, IMMAX, INTERACT) calculates coordinates X, Y, Z of cells
%   selected from cell candidates defined by statisctics S
%   with appropriate parameters.
%   Shows selected cells on image IM
%
%   Input-output specs
%   ==================
%   IM          - double (image)
%   S           - struct (statistics)
%   CONFLVL 	- double (confidence that spot sigmas match criteria, 0-1)
%   S1MIN       - double (min value of spot 1 sigma, pixels)
%   S1MAX       - double (max value of spot 1 sigma, pixels)
%   S2MIN       - double (min value of spot 2 sigma, pixels)
%   S2MAX       - double (max value of spot 2 sigma, pixels)
%   S3MIN       - double (min value of spot 3 sigma, pixels)
%   S3MAX       - double (max value of spot 3 sigma, pixels)
%   IMMIN       - double (min value of spot intensity)
%   IMMAX       - double (max value of spot intensity)
%   X           - number (x coordinates of cells)
%   Y           - number (y coordinates of cells)
%   Z           - number (z coordinates of cells)
%   INTERACT    - number (1 - yes, 0 - no)
%
%   Author
%   ======
%   Sergey Shuvaev, 2014. sshuvaev@cshl.edu

%For every region

P = ones(length(S), 1);

for i = 1 : length(S)
    
    %Doublecheck that it has nonzero volume
    
    if size(S(i).PixelIdxList, 1) > 10
        
        %Extract the data
        
        sigma1 = S(i).sigma1;
        sigma2 = S(i).sigma2;
        sigma3 = S(i).sigma3;
        idiff = S(i).idiff;
        %intensity = real(S(i).intensity);
        
        %Find the bootstrap repeats matching the user's definition of cell
        
        p = sum((S1MIN <= sigma1) .* (sigma1 <= S1MAX) .* ...
            (S2MIN <= sigma2) .* (sigma2 <= S2MAX) .* ...
            (S3MIN <= sigma3) .* (sigma3 <= S3MAX) .* ...
            (IMMIN <= idiff).*(idiff <= IMMAX));
        %(IMMIN <= intensity).*(intensity <= IMMAX));
        
        %Calculate p-value
        
        P(i) = 1 - p / length(sigma1);
    end
end

figure
imshow(max(IM, [], 3) / max(IM(:))), axis image
title('Original image with detected objects')
hold on

%Save only the sells matching the user's definition with a given p-value

ind = find(P < CONFLVL);

X = [S(ind).X];
Y = [S(ind).Y];
Z = [S(ind).Z];

plot(Y, X, 'r+');
hold off

%If INTERACT is active, reveal the parameters for the mouse-selected cell

while(INTERACT)
    title('Click on a cell to reveal the data. Click outside to exit');
    
    %Save the mouse-selected coordinates
    
    [ysel, xsel] = ginput(1);
    xsel = round(xsel);
    ysel = round(ysel);
    
    %Click outside the image stops the interaction
    
    if(xsel < 1 || ysel < 1 || xsel > size(IM, 1) || ysel > size(IM, 2))
        break
    end
    
    %Find the closest cell and reveal the parameters
    
    [~, N] = min(abs([S.X] - xsel) + abs([S.Y] - ysel));
    title(sprintf('s1 = %.2f, s2 = %.2f, s3 = %.2f, i = %.2f', ...
        S(N).s1mean, S(N).s2mean, S(N).s3mean, S(N).idiff));
end
end
