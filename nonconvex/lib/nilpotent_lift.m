function [A_new,B_new,E_new,D_new,S_new,K,h] = nilpotent_lift(A,B,E,D,S)
% take in the system matrices A,B, the disturbance set D and the state-input 
% safe set S, return the nilpotent system with input lifting A_new, B_new with the
% corresponding disturbance set D_new and safe set S_new, as well as the
% feedback law K (u = -Kx + v).
% A-BK is nilpotent

% first nilpotent, then input lifting


[n,m] = size(B);
p = zeros(n,1);
K = zeros(m,n);

%% change the system to controllable canonical form to do pole placement
% TODO: find a LMI solution instead of doing change of coordinates
% construct controllability matrix
C = zeros(n,n*m);
for i = 1:n
    C(:,(i-1)*m + (1:m))=A^(i-1)*B;
end

if rank(C)~=n
    error("The system is not controllable!");
end

% construct C_bar, the matrix consisting of the first n independent
% columns of C

r = 1;
C_bar = C(:,1);
mu = zeros(m,1); % list of control indices
mu(1) = 1;
for i=2:n*m
    col = C(:,i);
    % get the column index in B such that col = A^k B_cont
    cont = mod(i,m);
    if cont == 0
        cont = m;
    end
    if rank([C_bar, col])>rank(C_bar)
        mu(cont) = mu(cont)+1;
        C_bar = [C_bar, col];
    end
    if size(C_bar,2)==n
        break;
    end
end
assert(sum(mu)==n);
% the current C_bar has wrong order of columns. we need to regenerate C_bar
% based on mu
C_bar = zeros(n,n);
count = 1;
for i = 1:m
    for j = 1:mu(i)
        C_bar(:,count) = A^(j-1)*B(:,i);
        count = count + 1;
    end
end
assert(rank(C_bar)==n);

% construct P matrix
C_bar_inv = inv(C_bar);
P = zeros(n,n);
count = 1;
mu_acc = 0;
for i=1:m
    mu_acc = mu_acc + mu(i);
    q_i = C_bar_inv(mu_acc,:);
    for j = 1:mu(i)
        P(count,:) = q_i*A^(j-1);
        count = count + 1;
    end
end

A_c = P*A/P;
B_c = P*B;

% construct K matrix
K_c = zeros(m,n);
mu_acc = n;
for i = m:-1:1
    K_c(i,:) = A_c(mu_acc,:);
    for j=i+1:m
        K_c(i,:) = K_c(i,:) - B_c(mu_acc,j)*K_c(j,:);
    end
    mu_acc = mu_acc - mu(i);
end
%% new dynamics 
% x_c = Px, x=P\x_c
K = K_c*P;
A_new = A - B*K;
B_new = B;
D_new = D;
E_new = E;

S_new = [];
T = [eye(n) zeros(n,m)
    -K eye(m,m)];
for i = 1:length(S)
    H = S(i).A;
    h = S(i).b;
    S_new = [S_new, Polyhedron('A', H*T,'b', h)];
    S_new.minHRep;
end

%% input lifting -- add one-step delay in inputs
A_new = [A_new B_new;zeros(m,n+m)];
B_new = [zeros(n,m);eye(m,m)];
E_new = [E_new;zeros(m,size(E_new,2))];
h = max(mu)+1; % add 1 due to the one-step delay
