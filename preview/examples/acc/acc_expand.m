load inv_win_rho.mat
mptopt('lpsolver', 'MOSEK', 'qpsolver', 'GUROBI');

W2_expand = dyn_all.expand(W2,X,1,1);
