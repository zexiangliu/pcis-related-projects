% test the class PrevAuto

function tests = test_PrevAuto
  tests = functiontests(localfunctions);
end

%% Test functions
function testConstructor(testCase)

    num_s = 3;
    ts_array = [0 1 0;0 0 1;1 0 0];
    dyn = {0,0,0};
    t_prev = [0 3 0;0 0 3;3 0 0];
    t_hold = [3 4 5; inf inf inf];
    pa = PrevAuto(num_s,ts_array,dyn,t_prev,t_hold);
    
    % remove_states function
    pa.remove_states(2);
    assertEqual(testCase, pa.ts_array, logical([0 0;1 0]));
    assertEqual(testCase, pa.t_prev, [0 0;3 0]);
    assertEqual(testCase, pa.t_hold, [3 5;inf inf]);
    % add new states
    pa.add_states(3,{1,1,1},[2,2,2;inf,inf,inf]);
    ts = zeros(5);
    ts(1:2,1:2) = [0 0;1 0];
    t_prev = ts*3;
    t_hold = [3,5,2,2,2;inf,inf,inf,inf,inf];
    assertEqual(testCase, pa.ts_array, logical(ts));
    assertEqual(testCase, pa.t_prev, logical(t_prev));
    assertEqual(testCase, pa.t_hold, t_hold);
    pa.add_transitions([1,2,3,4,5],[3,3,1,3,2],[1,1,1,4,3]);
    ts(1,3) = 1;
    ts(2,3) = 1;
    ts(3,1) = 1;
    ts(4,3) = 1;
    ts(5,2) = 1;
    t_prev(1,3) = 1;
    t_prev(2,3) = 1;
    t_prev(3,1) = 1;
    t_prev(4,3) = 4;
    t_prev(5,2) = 3;   
    assertEqual(testCase, pa.ts_array, logical(ts));
    assertEqual(testCase, pa.t_prev, logical(t_prev));
    assertEqual(testCase, pa.t_hold, t_hold);
    pa.check();
end

function testChecker(testCase)

    num_s = 3;
    ts_array = [0 1 0;0 0 1;1 0 0];
    dyn = {0,0,0};
    t_prev = [0 3 0;0 0 3;3 0 0];
    t_hold = [3 3 3; inf inf inf];
    PrevAuto(num_s,ts_array,dyn,t_prev,t_hold);
    t_prev = [3 0 0;0 0 3;3 0 0];
    assertError(testCase,  @() PrevAuto(num_s,ts_array,dyn,t_prev,t_hold),...
        'MATLAB:assertion:failed');
    t_hold = [3 3 2; inf inf inf];
    assertError(testCase,  @() PrevAuto(num_s,ts_array,dyn,t_prev,t_hold),...
        'MATLAB:assertion:failed');
end