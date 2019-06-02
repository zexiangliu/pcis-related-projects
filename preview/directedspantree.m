function best_order = directedspantree(M_adj)
% generate iteration order by finding 
% the largest sub-tree in a directed graph.
    n = length(M_adj);
    M_adj = double(M_adj);
    forest = cell(n,1);
    num_node = zeros(n,1);
    num_layer = zeros(n,1);
    for i = 1:n
        forest{i} = {};
        I = zeros(n,1);
        I(i) = 1;
        I_old = I;
        forest{i} = i;
        count = 1;
        while(1)
            I = M_adj'*I | I;
            if( sum(I) == sum(I_old))
                break;
            end
            forest{i} = [forest{i},find(I & ~I_old)'];
            I_old = I;
            count = count + 1;
        end
        num_node(i) = sum(I);
        num_layer(i) = count;
    end
    
    % find out the root that has the most children and has the least layer.
    root_cand = find(num_node == max(num_node));
    num_layer = num_layer(root_cand);
    root_cand = root_cand(num_layer == min(num_layer));
    root_cand = root_cand(1);
    
    best_order = forest{root_cand};
    if(length(best_order) == n)
        return;
    end
    % complete the tree to be a forest
    left_nodes = setdiff(1:n,best_order);
    
    while(~isempty(left_nodes))
        left_idx = zeros(length(left_nodes),1,'logical');
        for i = length(left_nodes)
            post = find(M_adj(left_nodes(i),:));
            in_nodes = intersect(post,best_order);
            if(~isempty(in_nodes))
                idx_j = length(best_order);
                for j = in_nodes
                    if(find(best_order == j)< idx_j)
                        idx_j = find(best_order == j);
                    end
                end
                best_order = [best_order(1:idx_j-1),left_nodes(i)...
                    ,best_order(idx_j:end)];
                left_idx(i) = 1;
            end
        end
        left_nodes(left_idx) = [];
    end
end
