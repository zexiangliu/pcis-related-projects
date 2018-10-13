% test the class PrevAuto

function tests = PrevAutoTest
  tests = functiontests(localfunctions);
end

%% Test functions
function testConstructor(testCase)

    num_s = 3;
    ts_array = [0 1 0;0 0 1;1 0 0];
    dyn = {0,0,0};
    t_prev = [0 3 0;0 0 3;3 0 0];
    t_hold = [3 2 1; inf inf inf];
    PrevAuto(num_s,ts_array,dyn,t_prev,t_hold);
    
    pa = PrevAuto();
    pa.add_states(3,{1,1,1},[2,2,2]);
    pa.add_transitions([1,2,3],[3,2,1],[1,1,1])
    
end

function testChecker(testCase)

    num_s = 3;
    ts_array = [0 1 0;0 0 1;1 0 0];
    dyn = {0,0,0};
    t_prev = [0 3 0;0 0 3;3 0 0];
    t_hold = [3 2 1; inf inf inf];
    PrevAuto(num_s,ts_array,dyn,t_prev,t_hold);
    t_prev = [3 0 0;0 0 3;3 0 0];
    assertError(testCase,  @() PrevAuto(num_s,ts_array,dyn,t_prev,t_hold),...
        'MATLAB:assertion:failed');
end