function IMOUT = ssubr(IM, SC)
%SSUBR Subresolves and renormalizes image IM with scale SC
%   IMOUT = SSUBR(IM, SC)
%   Subresolves image if the data resolution is unnecessarily large
%
%   Input-output specs
%   ==================
%   IM          - double (image)
%   SC          - double (scale to subresolve)
%   
%   Author
%   ======
%   Sergey Shuvaev, 2014. sshuvaev@cshl.edu

%Denoising the data

f = ones(5, 5, 5) / (5 ^ 3);
IM = imfilter(IM, f, 'same');

%Resizing the data

IMOUT = imresize(IM(:, :, 1 : SC : size(IM, 3)), 1 / SC, 'nearest');

%Normalizing the data

IMOUT = (IMOUT - min(IMOUT(:))) / (max(IMOUT(:)) - min(IMOUT(:)));
IMOUT = IMOUT / max(IMOUT(:)) * max(IM(:));

end
