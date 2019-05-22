function [C_inv,volume, C_hier, T_min] = win_always(pa,X,pre,vol,inter,isEmpty,...
    isContain,W,verbose)
% Compute the invariant set in the preview automaton
% Inputs: pa  --- preview automaton
%         X   --- the cell of safe sets of states in the preview automaton
%         pre --- function handle of the pre operator corresponding to the
%                 dynamics.
%         vol --- function handle that measure the volume of sets
%         inter --- function handle for intersection of two sets
%         isEmpty --- function handle, return 1 if the set is empty
%         isContain --- function handle, isContain(S1,S2) == 1 if S1 <= S2
%         W   --- the cell of warm-starting winning sets for each state 
%                 in the preview automaton
%         verbose --- debug mode
% Outputs: C_inv --- the cell of winning sets of each state
%          volume --- the list of volumes of the winning sets
%          C_hier --- the hierarchic winning sets in the structure of
%                     equivalent transition system.
%          T_min --- the list of minimum time that enables all the preview

assert(length(X) == pa.num_s);

if nargin == 6
    verbose = false;
elseif nargin == 5 || isempty(W)
    C_inv = X;
else
    C_inv = W;
end

is_C_hier = 0;
if nargout >= 3
    is_C_hier = 1;
end

num_s = pa.num_s;

% record the history volume
volume = compute_vol(C_inv,vol);

% record the history C_inv
C_hist = X;

bool_hist = zeros(num_s,1,'logical');
counter = 0;

% initialize the C_hier
if is_C_hier
    T_min = zeros(num_s,1);
    C_hier=cell(num_s,1);
    for i = 1:num_s
        C_hier{i}={cell(pa.t_hold(1,i),1),cell(max(pa.t_prev(:,i)),1)};
    end
end
% heuristic order of iterating the states
best_order = directedspantree(pa.ts_array');
while(1)
    tic;
    for i = best_order
        if isEmpty(C_inv{i})
            continue;
        end
        
        post = pa.ts_array(i,:);
        t_prev = pa.t_prev(i,post);
        C_tmp = C_inv(post);
        th_max = pa.t_hold(2,i);
        th_min = pa.t_hold(1,i);
        t_min = min(t_prev);
        
        % if all the post states have temporary converge, then skip
        if(all(bool_hist(post)))
            continue;
        end
        
        if is_C_hier
            T_min(i) = t_min;
            idx_post = find(post);
        end
        
        for j = 1:length(C_tmp)
           for k = 1:t_prev(j)
               C_tmp{j} = inter(pre(pa.dyn{i},C_tmp{j}),X{i});
               
               % save C_hier
               if is_C_hier
                   C_hier{idx_post(j)}{2}{k} = C_tmp{j};
               end
           end
        end
        
        if isinf(th_max)
            if verbose    
                disp("start cinv of state "+num2str(i));
            end
            C_i = Inv(pa.dyn{i},interUnion(C_tmp,inter),pre,...
                vol,inter, isContain,verbose);
            C_i_old = C_i;
            
            % save C_hier
            if is_C_hier
                if t_min ~= 0                
                    C_hier{i}{1}{t_min} = C_i;
                else
                    C_hier{i}{1}{1} = C_i;
                end
            end
            
            for j = t_min+1:th_min
                C_i = inter(pre(pa.dyn{i},C_i),X{i});
                t_left = t_prev >= j;
                if(all(~t_left))
%                     C_i = inter(C_i,X{i});
%                     if isContain(C_i_old,C_i) % ??? the direction may be
%                                               % wrong
                    if isContain(C_i, C_i_old)
                        
                        % save C_hier
                        if is_C_hier
                            for k = j:th_min
                                C_hier{i}{1}{k} = C_i;
                            end
                        end
                        
                        break;
                    else
                        C_i_old = C_i;
                        
                        % save C_hier
                        if is_C_hier
                            C_hier{i}{1}{j} = C_i;
                        end
                    end
                else
                    C_i = inter(C_i,interUnion(C_tmp(t_left)));
                    % save C_hier
                    if is_C_hier
                        C_hier{i}{1}{j} = C_i;
                    end
                end
            end
        else
            C_i = interUnion(C_tmp(t_prev==t_min),inter);
            C_i_old = C_i;
            for j = t_min+1:th_max
                C_i = pre(pa.dyn{i},C_i);
                t_left = (t_prev<=j) & (th_max-j+t_prev >= th_min);
                if(all(~t_left))
                    C_i = inter(C_i,X{i});
%                     if isContain(C_i_old, C_i)
                    if isContain(C_i, C_i_old)
                        break;
                    else
                        C_i_old = C_i;
                    end
                else
                    C_i = inter(C_i,interUnion(C_tmp(t_left),inter));
                end
            end
        end
        C_inv{i} = C_i;
    end
    
    % termination condition
    bool_hist = compare_C_inv(C_inv, C_hist, isContain);
    if(all(bool_hist))
        break;
    else
        C_hist = C_inv;
    end
    
    counter = counter + 1;
    if verbose    
        volume = compute_vol(C_inv,vol);
        str1 = sprintf("the %d th iteration: ",counter);
        str2 = ["volume: "+ num2str(volume','%0.2f ')];
        str3 = [",time "+num2str(toc)+"s"];
        disp(str1+str3);
        disp(str2);
    end
end
if verbose    
    disp("the winning set converges.")
    volume = compute_vol(C_inv,vol);
    str1 = sprintf("the %d th iteration: ",counter+1);
    str2 = ["volume: "+ num2str(volume','%0.2f ')];
    str3 = [",time "+num2str(toc)+"s"];
    disp(str1+str3);
    disp(str2);
end
    
end

% compare if all C_hist are contained by C_inv
function bool_list = compare_C_inv(C_inv, C_hist, isContain)
    bool_list = zeros(length(C_inv),1,"logical");
    for i = 1:length(C_inv)
        if isContain(C_hist{i}, C_inv{i})
            bool_list(i) = true;
        end
    end
end

function volume = compute_vol(W,vol)
    volume = zeros(length(W),1);
    for i = 1:length(W)
        volume(i) = vol(W{i});
    end 
end

function C = interUnion(C_Union,inter)
    C = C_Union{1}; 
    if(length(C_Union)>=2)
        for i = 2:length(C_Union)
            C = inter(C,C_Union{i});
        end
    end
end

function C_inv = Inv(dyn, X, pre, vol, inter,isContain, verbose)
    C_inv = X;
    
    C_hist = C_inv;
    disp("   Getting into Inv:");
    while(1)
        C_inv = pre(dyn,C_inv);
        C_inv = inter(C_inv,X);
        volume = vol(C_inv);
        if verbose
            disp("  within inv: " + num2str(volume)+".");
        end
        if(isContain(C_hist,C_inv))
            break;
        else
            C_hist = C_inv;
        end
    end
end

