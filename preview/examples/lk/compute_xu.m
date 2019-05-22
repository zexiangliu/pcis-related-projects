function W_hier_XU = compute_xu(pa,W_hier,T_min)
    W_hier_XU = cell(pa.num_s,1);

    for i = 1:pa.num_s
        for j = T_min(i):length(W_hier{i}{1})
            W_hier_XU{i}{1}{j} = pa.dyn{i}.pre_xu(W_hier{i}{1}{j});
        end
        for j = 1:length(W_hier{i}{2})
            W_hier_XU{i}{2}{j} = pa.dyn{i}.pre_xu(W_hier{i}{2}{j});
        end
    end

end