function B = sbootstrap(x, y, z, f, f_, Ntr)
%SBOOTSTRAP Gathering statistics with bootstrap algorhitm
%   B = SBOOTSTRAP(X, Y, Z, F, F_, NTR)
%   calculates statisctics (gaussian sigmas) of a region defined by
%   coordinates X, Y, Z with corresponding grayscale intesities F and
%   background F_.
%   Number of bootstrap trials defined by NTR.
%   Gaussian distribution is linearized.
%
%   Input-output specs
%   ==================
%   X     - number (x coordinates of a region)
%   Y     - number (y coordinates of a region)
%   Z     - number (z coordinates of a region)
%   F     - double (corresponding intensities)
%   F_    - double (background)
%   B     - double (bootstrap statistics (all sigmas))
%
%   Author
%   ======
%   Sergey Shuvaev, 2014. sshuvaev@cshl.edu

%Building coordinate matfix for the fit

f0 = (f - f_) .* (f - f_ > 0);

B = zeros(Ntr, 7);
F0 = ones(length(x), 7);
F0(:, 2) = x .^ 2;
F0(:, 3) = y .^ 2;
F0(:, 4) = z .^ 2;
F0(:, 5) = x .* y;
F0(:, 6) = y .* z;
F0(:, 7) = z .* x;

%For every bootstrap iteration

for tr = 1 : Ntr
    
    %Resample the data
    
    ind = floor(length(x) * rand(length(x), 1)) + 1;
    F = F0(ind, :);
    ff = f0(ind);
    
    %Fit the data with Gaussian distribution
    
    v = F' * ff;
    G = F' * F;
    C = G \ v;
    
    B(tr, :) = C';
    
end

end