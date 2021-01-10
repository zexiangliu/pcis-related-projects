function [C,h] = get_lifted_set(A,B,E,D,S,L,method,L2)

if nargin == 7
    L2 = min(L,10);
end


[A_new,B_new,E_new,D_new,S_new,K,h] = nilpotent_lift(A,B,E,D,S);

n = size(A_new,1);
m = size(B_new,2);
M = 1e6;
% %% debugging
% x0 = [80;0;0;8000;0];
% u0 = [8000;0];
% 
% xi = [x0;u0;ones(h+L,1)];

%% compute S-D_k
% S_shrink = {S-D_0=S, S-D_1, S-D_2, ..., S-D_h} (approximately)
D_whole = E_new*D_new;
D_acc = zeros(n,1);
S_shrink = cell(h+1,1);
S_shrink{1} = S_new;
D_list = cell(h-1,1);
for i=2:h+1
    D_acc = D_acc + A_new^(i-2)*D_whole;
    D_list{i-1} = D_acc;
    for j = 1:length(S_new)
        S_tmp = minkDiff(S_new(j),D_acc);
%         S_tmp.minHRep;
        S_shrink{i}=[S_shrink{i},S_tmp]; 
    end
end

if method=="alg1"
    %% algorithm 1
    % the vector of decision variables is
    % [x0, u_1, ..., u_L, u(0), ..., u(T-1),a_{0,1}, ..., a_{0,L},...,
    % a_{T-1,1}, ..., a_{T-1,L}, s_{0,1}, ...,
    % s_{0,N1},...,s_{T,1},...,s_{T,NT}]
    H_cons1 = [];
    h_cons1 = [];
    n_s = length(S);
    T = h+L^h;
    N = n + m*L +m*T + L*T + (T+1)*n_s;
    u_i = @(i,ind) n+(i-1)*m +ind; % input label u_i
    u_k = @(k,ind) n + m*L + k*m + ind; % input u(k) at time k
    a = @(k,i) n + m*L +m*T + k*L + i; % a_{k,i}
    s = @(k,j) n + m*L +m*T + L*T + k*n_s + j; % s_{k,j}

    % % constraints:  |u(k)-u_i| <= (1-a_{k,i})M*1 and sum_i a_{k,i} >= 1
    for k=0:T-1
        % |u(k)-u_i| <= (1-a_{k,i})M*1
        for i=1:L
            new_row1 = zeros(m,N);
            new_row2 = zeros(m,N);
            new_h = M*ones(m,1);
            for ind=1:m
               new_row1(ind,u_k(k,ind)) = 1; 
               new_row1(ind,u_i(i,ind)) = -1; 
               new_row1(ind,a(k,i)) = M; 
               new_row2(ind,u_k(k,ind)) = -1; 
               new_row2(ind,u_i(i,ind)) = 1;
               new_row2(ind,a(k,i)) = M; 
            end
            H_cons1 = [H_cons1;new_row1;new_row2];
            h_cons1 = [h_cons1;new_h;new_h];
        end
        % sum_i a_{k,i} >= 1
        new_row = zeros(1,N);
        new_row(a(k,1:L)) = -1;
        H_cons1 = [H_cons1;new_row];
        h_cons1 = [h_cons1;-1];
    end

    % constraints: H_{j,k} x_k(x0,u) <= h_{j,k} + (1-s_{k,j})M*1 and
    % sum_j s_{k,j}>=1
    for k = 0:T
        % construction of x_k
        x_k = zeros(n,N);
        if k<h
            x_k(:,1:n) = A_new^k;
        end
        for t = max(k-h,0):k-1
            x_k(:,u_k(t,1:m)) = x_k(:,u_i(mod(t,L)+1,1:m)) + A_new^(k-t-1)*B_new;
        end
        % H_{j,k} x_k(x0,u) <= h_{j,k} + (1-s_{k,j})M*1
        k_true = min(k,h)+1;
        for j=1:n_s
            H_jk = S_shrink{k_true}(j).A;
            h_jk = S_shrink{k_true}(j).b;
            new_row = H_jk*x_k;
            new_row(:,s(k,j)) = M;
            new_h = h_jk + M;
            try
                H_cons1 = [H_cons1;new_row];
                h_cons1 = [h_cons1;new_h];
            catch
                keyboard();
            end
        end
        % sum_j -s_kj <= -1
        new_row = zeros(1,N);
        new_row(s(k,1:n_s)) = -1;
        H_cons1 = [H_cons1;new_row];
        h_cons1 = [h_cons1;-1];
    end

    C = Polyhedron('A',H_cons1,'b',h_cons1);
elseif method == "alg2"
    % the vector of decision variables is
    % [x0, u_1, ..., u_L, s_{0,1}, ...,
    % s_{0,N1},...,s_{T,1},...,s_{h+L-1,N_{h+L-1}}]
    H_cons2 = [];
    h_cons2 = [];
    n_s = length(S);
    T = h+L;
    N = n + m*L + T*n_s;
    u_i = @(i,ind) n+(i-1)*m +ind; % input label u_i
    s = @(k,j) n + m*L + k*n_s + j; % s_{k,j}

    for k=0:h+L-1
     % construction of x_k
        x_k = zeros(n,N);
        if k<h
            x_k(:,1:n) = A_new^k;
        end
        for t = max(k-h,0):k-1
            x_k(:,u_i(mod(t,L)+1,1:m)) =  x_k(:,u_i(mod(t,L)+1,1:m)) + A_new^(k-t-1)*B_new;
        end
         % H_{j,k} x_k(x0,u) <= h_{j,k} + (1-s_{k,j})M*1
        k_true = min(k,h)+1;
        for j=1:n_s
            H_jk = S_shrink{k_true}(j).A;
            h_jk = S_shrink{k_true}(j).b;
            new_row = H_jk*x_k;
            new_row(:,s(k,j)) = M;
            new_h = h_jk + M;
            H_cons2 = [H_cons2;new_row];
            h_cons2 = [h_cons2;new_h];
        end
        % sum_j -s_kj <= -1
        new_row = zeros(1,N);
        new_row(s(k,1:n_s)) = -1;
        H_cons2 = [H_cons2;new_row];
        h_cons2 = [h_cons2;-1];
    end
    C = Polyhedron('A',H_cons2,'b',h_cons2);    
else
    % the vector of decision variables is
    % [x0, u_1, ..., u_L, s_{0,1}, ...,
    % s_{0,N1},...,s_{T,1},...,s_{h+L-1,N_{h+L-1}}]
    H_cons2 = [];
    h_cons2 = [];
    n_s = length(S);
    T = h+L+1;
    N = n + m*L + T*n_s;
    u_i = @(i,ind) n+(i-1)*m +ind; % input label u_i
    s = @(k,j) n + m*L + k*n_s + j; % s_{k,j}
    L1 = L-L2;
    cont = @(t) min(t+1,L1) + (t>=L1)*(mod(t-L1,L2)+1);
    for k=0:T-1
     % construction of x_k
        x_k = zeros(n,N);
        if k<h
            x_k(:,1:n) = A_new^k;
        end
        for t = max(k-h,0):k-1
            x_k(:,u_i(cont(t),1:m)) = x_k(:,u_i(mod(t,L)+1,1:m)) + A_new^(k-t-1)*B_new;
        end
         % H_{j,k} x_k(x0,u) <= h_{j,k} + (1-s_{k,j})M*1
        k_true = min(k,h)+1;
        for j=1:n_s
            H_jk = S_shrink{k_true}(j).A;
            h_jk = S_shrink{k_true}(j).b;
            new_row = H_jk*x_k;
            new_row(:,s(k,j)) = M;
            new_h = h_jk + M;
            H_cons2 = [H_cons2;new_row];
            h_cons2 = [h_cons2;new_h];
        end
        % sum_j -s_kj <= -1
        new_row = zeros(1,N);
        new_row(s(k,1:n_s)) = -1;
        H_cons2 = [H_cons2;new_row];
        h_cons2 = [h_cons2;-1];
    end
    C = Polyhedron('A',H_cons2,'b',h_cons2);
end
end

