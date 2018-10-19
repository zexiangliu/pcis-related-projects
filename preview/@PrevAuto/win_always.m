function [C_inv,volume] = win_always(pa,X,pre,vol,inter,W,verbose)
% Compute the invariant set in the preview automaton
% Inputs: pa  --- preview automaton
%         X   --- the cell of safe sets of states in the preview automaton
%         pre --- function handle of the pre operator corresponding to the
%                 dynamics.
%         vol --- function handle that measure the volume of sets
%         inter --- function handle for intersection of two sets
%         W   --- the cell of warm-starting winning sets for each state 
%                 in the preview automaton
%         verbose --- debug mode
% Outputs: C_inv --- the cell of winning sets of each state
%          volume --- the list of volumes of the winning sets


assert(length(X) == pa.num_s);

if nargin == 6
    verbose = false;
elseif nargin == 5 || isempty(W)
    C_inv = X;
else
    C_inv = W;
end

num_s = pa.num_s;

% record the history volume
volume_hist = compute_vol(C_inv,vol);
volume_hist2 = zeros(length(volume_hist),1);
volume = volume_hist2;

counter = 0;

% heuristic order of iterating the states
best_order = directedspantree(pa.ts_array');

while(1)
    tic;
    for i = best_order
        if isEmptySet(C_inv{i})
            continue;
        end
        
        post = pa.ts_array(i,:);
        t_prev = pa.t_prev(i,post);
        C_tmp = C_inv(post);
        th_max = pa.t_hold(2,i);
        th_min = pa.t_hold(1,i);
        t_min = min(t_prev);
        
        % if all the post states have the same volume, then skip
        if(all(volume_hist(post)==volume_hist2(post)))
            continue;
        end
        
        for j = 1:length(C_tmp)
           for k = 1:t_prev(j)
               C_tmp{j} = intersect(pre(pa.dyn{i},C_tmp{j}),X{i});
           end
        end
        
        if isinf(th_max)
            C_i = Inv(pa.dyn{i},interUnion(C_tmp,inter),pre,...
                vol,inter,verbose);
            vol_old = vol(C_i);
            for j = t_min+1:th_min
                C_i = inter(pre(pa.dyn{i},C_i),X{i});
                t_left = t_prev >= j;
                if(all(~t_left))
                    C_i = inter(C_i,X{i});
                    vol_new = vol(C_i);
                    if(vol_new == vol_old)
                        break;
                    else
                        vol_old = vol_new;
                    end
                else
                    C_i = inter(C_i,interUnion(C_tmp(t_left)));
                end
            end
        else
            C_i = interUnion(C_tmp(t_prev==t_min));
            vol_old = vol(C_i);
            for j = t_min+1:th_max
                C_i = pre(pa.dyn{i},C_i);
                t_left = (t_prev<=j) & (th_max-j+t_prev >= th_min);
                if(all(~t_left))
                    C_i = inter(C_i,X{i});
                    vol_new = vol(C_i);
                    if(vol_old == vol_new)
                        break;
                    else
                        vol_old = vol_new;
                    end
                else
                    C_i = inter(C_i,interUnion(C_tmp(t_left)));
                end
            end
        end
        C_inv{i} = C_i;
    end
    
    % termination condition
    volume = compute_vol(C_inv,vol);
    if(all(volume_hist <= volume))
        break;
    else
        volume_hist2 = volume_hist;
        volume_hist = volume;
    end
    
    counter = counter + 1;
    if verbose
        str1 = sprintf("the %d th iteration: ",counter);
        str2 = ["volume: "+ num2str(volume','%0.2f ')];
        str3 = [",time "+num2str(toc)+"s"];
        disp(str1+str3);
        disp(str2);
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

function C_inv = Inv(dyn, X, pre, vol, inter, verbose)
    C_inv = X;
    
    vol_hist = vol(C_inv);
    
    while(1)
        C_inv = pre(dyn,C_inv);
        C_inv = inter(C_inv,X);
        volume = vol(C_inv);
        if verbose
            disp("  Within Inv: " + num2str(volume)+".");
        end
        if(vol_hist <= volume)
            break;
        else
            vol_hist = volume;
        end
    end
end

