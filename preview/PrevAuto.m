classdef PrevAuto
    properties(SetAccess = private)
        num_s;          % number of states
        ts_array;       % ts(i,j)=1: state i ---> state j
        dyn;            % list of dynamics 
        t_prev;         % t_prev(i,j): the preview time from i to j
        t_hold;         % t_hold(1,i): the least holding time 
                        % at system i; t_hold(2,i): the maximum holding
                        % time at system i
    end
    
    methods
        function pa = PrevAuto(num_s,ts_array,dyn,t_prev,t_hold)
            if nargin == 0 || num_s == 0
                pa.num_s = 0;
                pa.ts_array = [];
                pa.dyn = {};
                pa.t_prev = [];
                pa.t_hold = [];
            else
                pa.num_s = num_s;
                pa.ts_array = ts_array;
                pa.dyn = dyn;
                pa.t_prev = t_prev;
                pa.t_hold = t_hold;
            end
            pa.check();
        end
        
        function check(pa)
            % basic check for class members
            num = pa.num_s;
            if(num ~= 0)
                assert(num == size(pa.ts_array,1));
                assert(num == size(pa.ts_array,2))
                assert(num == length(pa.dyn));
                assert(num == size(pa.t_hold,2));
                assert(size(pa.t_hold,1)==2);
                array_and_prev = ~pa.ts_array&pa.t_prev;
                assert(~any(array_and_prev(:)));
            end
        end
        
        function add_transitions(pa,state1,state2,t_prev)
            for i = 1:length(state1)
                pa.ts_array(state1(i),state2(i)) = 1;
                pa.t_prev(state1(i),state2(i)) = t_prev(i);
            end
        end
        
        function add_states(pa, num_new, dyn, t_hold)
            
            new_ts_array = zeros(pa.num_s+num_new,'logical');
            new_ts_array(1:pa.num_s,1:pa.num_s) = pa.ts_array;
            pa.ts_array = new_ts_array;
            new_t_prev = zeros(pa.num_s+num_new,'logical');
            new_t_prev(1:pa.num_s,1:pa.num_s) = pa.t_prev;
            pa.t_prev = new_t_prev;
            pa.num_s = pa.num_s + num_new;
            pa.dyn(end+1:end+num_new) = dyn;
            pa.t_hold(:,end+1:end+num_new) = t_hold;
        end
    end
    
end
    
    