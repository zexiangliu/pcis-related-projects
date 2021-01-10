clc;clear all;close all;
load acc_L_40.mat

h_inf = 50;

B1 = [h_min,v_min,u_min;
      h_inf, v_max,u_max]';
B3 = [-h_inf,v_min,u_min;
    -h_min,v_max,u_max]';

B1 = B1(1:2,:);
B3 = B3(1:2,:);

N = 1000;

%% verification of non-emptyness of alg 1's result
% T = h+L^h;
% bin_var = binvar(L*T + (T+1)*n_s,1); % number of binary variables
% cons_var = sdpvar(n+m*L +m*T,1);
% ops = sdpsettings('solver','gurobi','verbose',1,'gurobi.IterationLimit',10000);
% sol = optimize(C1.A*[cons_var;bin_var]<=C1.b,1,ops);
%% verification of non-emptyness of alg 1's result
% T = h+L^h;
% bin_var = binvar(L*T + (T+1)*n_s,1); % number of binary variables
% cons_var = sdpvar(2+m*L +m*T,1);
% ops = sdpsettings('solver','gurobi','verbose',1);
% x0 = [0;29;1.1];
% sol = optimize(C1.A*[x0;cons_var;bin_var]<=C1.b,1,ops);

%% sample alg 1
% T = h+L^h;
% bin_var = binvar(L*T + (T+1)*n_s,1); % number of binary variables
% cons_var = sdpvar(2+m*L +m*T,1);
% ops = sdpsettings('solver','gurobi','verbose',0,'gurobi.IterationLimit',1000);
% C_win = [];
% C_loss = [];
% list_s = [];
% for i = 1:N
%     i
%     % sample a state in R^3
%     b_ind = randsample([1,2,3],1);
%     if b_ind == 1
%         x0 = sample_box(B1);
%     elseif b_ind == 2
%         x0 = sample_box(B2);
%     else
%         x0 = sample_box(B3);
%     end
%     % setup MILP to find the left states
%     sol = optimize([C1.A*[x0';cons_var;bin_var]<=C1.b],1,ops);
%     
%     if sol.problem == 0
%         C_win = [C_win;x0];
%         list_s = [list_s,[x0';value(cons_var);value(bin_var)]];
%         disp("bingo");
%     else
%         C_loss = [C_loss;x0];
%     end
% end
%% verification of non-emptyness of alg 2's result
% T = h+L;
% bin_var = binvar(T*n_s,1); % number of binary variables
% cons_var = sdpvar(n+m*L,1);
% ops = sdpsettings('solver','gurobi','verbose',1,'gurobi.IterationLimit',10000);
% sol = optimize(C2.A*[cons_var;bin_var]<=C2.b,1,ops);
%% sample alg 2
% T = h+L;
% bin_var = binvar(T*n_s,1); % number of binary variables
% cons_var = sdpvar(m+m*L,1);
% ops = sdpsettings('solver','gurobi','verbose',0,'gurobi.IterationLimit',1000);
% C_win = [];
% C_loss = [];
% list_s = [];
% for i = 1:N
%     i
%     % sample a state in R^3
%     b_ind = randsample([1,3],1);
%     if b_ind == 1
%         x0 = sample_box(B1);
%     else
%         x0 = sample_box(B3);
%     end
%     % setup MILP to find the left states
%     sol = optimize([C2.A*[x0';cons_var;bin_var]<=C2.b],1,ops);
%     
%     if sol.problem == 0
%         C_win = [C_win;x0];
%         list_s = [list_s,[x0';value(cons_var);value(bin_var)]];
%         disp("bingo");
%     else
%         C_loss = [C_loss;x0];
%     end
% end
% C_win_acc= C_win;
% save C_win_acc_alg2.mat C_win_acc

%% verification of non-emptyness of alg 3's result
% T = h+L+1;
% bin_var = binvar(T*n_s,1); % number of binary variables
% cons_var = sdpvar(n+m*L,1);
% ops = sdpsettings('solver','gurobi','verbose',1,'gurobi.IterationLimit',10000);
% sol = optimize(C3.A*[cons_var;bin_var]<=C3.b,1,ops);
%% sample alg 3
T = h+L+1;
bin_var = binvar(T*n_s,1); % number of binary variables
cons_var = sdpvar(m+m*L,1);
ops = sdpsettings('solver','gurobi','verbose',0,'gurobi.IterationLimit',1000);
C_win = [];
C_loss = [];
list_s = [];
for i = 1:N
    i
    % sample a state in R^3
    b_ind = randsample([1,3],1);
    if b_ind == 1
        x0 = sample_box(B1);
    else
        x0 = sample_box(B3);
    end
    % setup MILP to find the left states
    sol = optimize([C3.A*[x0';cons_var;bin_var]<=C3.b],1,ops);
    
    if sol.problem == 0
        C_win = [C_win;x0];
        list_s = [list_s,[x0';value(cons_var);value(bin_var)]];
        disp("bingo");
    else
        C_loss = [C_loss;x0];
    end
end
% C_win_acc= C_win;
% save C_win_acc_alg3.mat C_win_acc

%% visualization
hold on;
S0 = Polyhedron('lb',[-h_inf,v_min,u_min],'ub',[h_inf,v_max,u_max]);
S1 = S0.intersect(S1);
S3 = S0.intersect(S3);
plot(S1.projection([1,2]),'alpha',0.1)
plot(S3.projection([1,2]),'alpha',0.1)
xlabel("h")
ylabel("v_x")

plot(C_loss(:,1),C_loss(:,2),'r.','markersize',10);
plot(C_win(:,1),C_win(:,2),'b.','markersize',10);