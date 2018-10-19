M_adj = [0 1 1 0 0 0 0
             0 0 0 1 1 0 0
             0 0 0 0 1 1 0
             0 0 0 0 0 0 0
             0 0 0 0 0 0 0
             0 0 0 0 0 0 0
             0 0 1 0 0 1 0];
         
    best_order = directedspantree(M_adj);