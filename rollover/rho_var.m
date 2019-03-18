function rho = rho_var(n)

if n<= 5000
    rho = 1e-5;
elseif n<= 10000
    rho = 1e-4;
else
    rho = 1*1e-4;
end
% rho = 1e-3;
