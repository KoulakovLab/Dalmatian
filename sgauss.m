function Y = sgauss(X, sz1, sz2)
%SGAUSS Gaussian bandpass filtering of an image
%   Y = SGAUSS(X, SZ1, SZ2)
%   filters image X with Gaussian bandpass filter with sigmas SZ1 and SZ2
%   and saves result into Y. Calculated in Fourier domain to increase speed
%
%   Input-output specs
%   ==================
%   X     - double (image)
%   SZ1   - double (first sigma for Gaussian filter)
%   SZ2   - double (second sigma for Gaussian filter)
%   Y     - double (output image)
%
%   Author
%   ======
%   Sergey Shuvaev, 2014. sshuvaev@cshl.edu

%Generating Fourier image of Gaussian filter

[M, N, K] = size(X);

if mod(N, 2)
    qy = [1 : N] - N / 2 - 0.5;
    qy = qy * 2 * pi / N;
else
    qy = [1 : N] - N / 2 - 1;
    qy = qy * 2 * pi / N;
end

if mod(M, 2)
    qx = [1 : M] - M / 2 - 0.5;
    qx = qx * 2 * pi / M;
else
    qx = [1 : M] - M / 2 - 1;
    qx = qx * 2 * pi / M;
end

if mod(K, 2)
    qz = [1 : K] - K / 2 - 0.5;
    qz = qz * 2 * pi / K;
else
    qz = [1 : K] - K / 2 - 1;
    qz = qz * 2 * pi / K;
end

[Qx, Qy, Qz] = ndgrid(qx, qy, qz);

F1 = exp( - (Qx .^ 2 + Qy .^ 2 + Qz .^ 2) / 2 * sz1 ^ 2);
F2 = exp( - (Qx .^ 2 + Qy .^ 2 + Qz .^ 2) / 2 * sz2 ^ 2);

%Filtering in Fourier domain

Xq = fftshift(fftn(X));
Yq = Xq .* (F1 - F2);
Yq = ifftshift(Yq);
Y = ifftn(Yq);

Y = real(Y);

end
