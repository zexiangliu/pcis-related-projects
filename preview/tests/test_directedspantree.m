% test directedspantree

function tests = test_directedspantree
  tests = functiontests(localfunctions);
end

%% Test functions
function testSpanTree(testCase)

    M_adj = [0 1 1 0 0 0 0
             0 0 0 1 1 0 0
             0 0 0 0 1 1 0
             0 0 0 0 0 0 0
             0 0 0 0 0 0 0
             0 0 0 0 0 0 0
             0 0 1 0 0 1 0];
         
    best_order = directedspantree(M_adj);
    assert(all(best_order == [1 2 7 3 4 5 6]));

    M_adj = [0 1 1 0 0 0 0
             0 0 0 1 1 0 0
             0 0 0 1 1 1 0
             0 0 0 0 0 0 0
             0 0 0 0 0 0 0
             0 0 0 0 0 0 0
             0 0 0 0 5 1 0];
         
    best_order = directedspantree(M_adj);
    assert(all(best_order == [1 2 3 4 7 5 6]));
    
    M_adj = [0 1 1 0 0 0 0 0
             0 0 0 1 1 0 0 0
             0 0 0 1 1 1 0 0
             0 0 0 0 0 0 0 0
             0 0 0 0 0 0 0 0
             0 0 0 0 0 0 0 0
             0 0 0 0 0 0 0 1
             0 0 0 0 0 1 0 0];
         
    best_order = directedspantree(M_adj);
    assert(all(best_order == [1 2 3 4 5 7 8 6]));

    M_adj = [0 1 1 0 0 0 0 0
             0 0 0 1 1 0 0 0
             0 0 0 1 1 1 0 0
             0 0 0 0 0 0 0 0
             0 0 0 0 0 0 0 0
             0 0 0 0 0 0 0 0
             1 0 0 0 0 0 0 1
             0 0 0 0 0 1 0 0];
         
    best_order = directedspantree(M_adj);
    assert(all(best_order == [7 1 8 2 3 6 4 5]));
end