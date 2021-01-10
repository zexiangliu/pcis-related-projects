% test cases

%% test hit_run

in_S = @(x) abs(x)<=1;
rng(0)
assert(hit_run(0,in_S)==0.811583874103998)