function x_sample = hit_run(x,in_S)
% provide a function handle "inside_S", return true if a point is in 
% the set S. We need S to be convex.
% sample a point using hit and run method, with starting point x
if ~in_S(x)
    error("x should be a point in S");
end
% obtain a direction
dx = rand(length(x),1)-0.5;
dx = dx/norm(dx);

%% line search to find an upper bound of alpha
alpha_max = 1;
beta = 1.5;
while(in_S(x+alpha_max*dx))
    alpha_max = beta*alpha_max;
end

% line search to find the max bound of alpha
eps = 1e-10;
alpha_mid = 0;
while(abs(alpha_max - alpha_mid)>eps)
    alpha = (alpha_mid + alpha_max)/2;
    if in_S(x+alpha*dx)
        alpha_mid = alpha;
    else
        alpha_max = alpha;
    end
end
alpha_max = alpha_mid;

%% line search to find a lower bound of alpha
alpha_min = -1;
beta = 1.5;
while(in_S(x+alpha_min*dx))
    alpha_min = beta*alpha_min;
end

% line search to find the max bound of alpha
eps = 1e-10;
alpha_mid = 0;
while(abs(alpha_min - alpha_mid)>eps)
    alpha = (alpha_mid + alpha_min)/2;
    if in_S(x+alpha*dx)
        alpha_mid = alpha;
    else
        alpha_min = alpha;
    end
end
alpha_min = alpha_mid;

%% sample
r = rand();

x_sample = x + (alpha_min + r*(alpha_max-alpha_min))*dx;