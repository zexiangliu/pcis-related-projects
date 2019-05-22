clear all;
load LinearizeModel.mat

dt = 0.01; 

% System matrices: already discrete-time
Adt0 = eye(4) + A0*dt; 
Adt1 = A1*dt;

% 
Bdt = B0*dt;

C = C0;


% Bounds
xmax = [100; 10; 20; 2];
ymax = 0.95; 
umax = 1e-3*142.73; % see above Fig. 1,  https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=5280801
umin = -umax;

QQ = diag(1./xmax);
Adt0 = QQ*Adt0/QQ;
Adt1 = QQ*Adt1/QQ;
Bdt = QQ*Bdt;
xmax = [1; 1; 1; 1];
C = C/QQ;

X = Polyhedron('A', [eye(4); -eye(4); C; -C], 'b', [xmax; xmax; ymax; ymax]);
%  X = Polyhedron('A', [C; -C], 'b', [ymax; ymax]);

XU = Polyhedron('H', [0 0 0 0 1 umax;
				      0 0 0 0 -1 umax]);
                  
P = Polyhedron('lb',-1, 'ub', 1);

d = Dyn(Adt0, -Bdt*umax, zeros(4,1), XU,{Adt1}, {zeros(4,1)}, P);


rho = 1e-4;
num_iter = 200;
% 
tic;
[Xinv2,log2] = win_always(d, X, rho, 0, 1, 20);
t2 = toc

%%
tic;
[Xinv1,log1] = win_always_rho_inv(d, X, @(n) rho, 0, 1, 20);
t1 = toc;

%%
% tic;
% [Xinv2,log2] = win_always_rho_inv(d, X, @(n) rho, 0, 1,20);
% t2 = toc;
% tic;
% [Xinv3,log3] = win_always_rho_var(d, X, @(n) rho, 0, 1,num_iter);
% t3 = toc;
%%

figure('position',[100 100 600 500]);
plot(1:length(log1.time)+1,[0,log1.time],'linewidth',2);
hold on;
plot(1:length(log2.time)+1,[0,log2.time],'linewidth',2);
% plot(1:num_iter+2,[0,log3.time]);

xlabel('iteration');
ylabel('cumulative time');
legend('new rho method','old rho method');
% legend('new rho ball','old rho ball', 'rand rho_ball')


figure('position',[100 100 600 500]);
plot(1:length(log1.time)+1,[size(X.A,1),log1.num_cons]);
hold on;
plot(1:length(log2.time)+1,[size(X.A,1),log2.num_cons]);
% plot(1:num_iter+2,[size(X.A,1),log3.num_cons]);
xlabel('iteration');
ylabel('number of constraints');
legend('new rho method','old rho method');
% legend('new rho ball','old rho ball','rand rho_ball')

%%

samples = 10*randn(5,10000);
counter = 0;
for i = 1:10000
    if Xinv2.A*samples(:,i) <= Xinv2.b
        counter = counter +1
    end
end
    

