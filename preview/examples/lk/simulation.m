load lk_inv_1_1.mat

W_hier_XU = compute_xu(pa, W_hier, T_min);

% initial mode, initial state
m0 = 1;
x0 = W{m0}.V(1,:);


t_step = 0.1;