clc;clear all;
load DumpTruckModel_120_New.mat;
load DumpTruckModel_Uncertainty.mat;

dt = 0.03; 

% System matrices: already discrete-time

sys = ss(Ac,Bc,eye(4),[]);
sysd = c2d(sys,dt);

Adt = sysd.A;

Bdt = sysd.B;

C = Cc;

delta_Adt = blkdiag(DAc*dt,0);

% Bounds

xmax = [80; 200; 200; 100];
ymax = 1; 
umax = 160; 

% QQ = diag(1./xmax);
% Adt = QQ*Adt/QQ;
% Bdt = QQ*Bdt;
% C = C/QQ;
% delta_Adt = QQ*delta_Adt/QQ;
% xmax = [1; 1; 1; 1];

X = Polyhedron('A', [eye(5); -eye(5); [C, 0]; [-C, 0]], 'b', [xmax; umax; xmax; umax; ymax; ymax]);

P = Polyhedron('H', [eye(1) 1; -eye(1) 1]); % 1 works
XU = Polyhedron(); % 1 works


d = Dyn([Adt, Bdt; zeros(1,4), 1],[0;0;0;0;0],[], XU, {delta_Adt}, {zeros(5,1)}, P);



rho = 1e-3;
num_iter = 54;

tic;
[Xinv2,log2] = win_always(d, X, rho, 0, 1, num_iter);
t2 = toc


tic;
[Xinv1,log1] = win_always_rho_inv(d, X, @(n) rho, 0, 1, num_iter);
t1 = toc;

save data_rho_complicated.mat
% tic;
% [Xinv3,log3] = win_always_rho_var(d, X, @(n) rho, 0, 1,num_iter);
% t3 = toc;
%%

figure(1);
plot(1:length(log1.time)+1,[0,log1.time],'linewidth',2);
hold on;
plot(1:length(log2.time)+1,[0,log2.time],'linewidth',2);
% plot(1:num_iter+2,[0,log3.time]);

xlabel('iteration');
ylabel('cumulative time');
legend('new method','old method');
% legend('new rho ball','old rho ball', 'rand rho_ball')
set(gca,'fontsize',15)

figure(2);
plot(1:length(log1.time)+1,[size(X.A,1),log1.num_cons]);
hold on;
plot(1:length(log2.time)+1,[size(X.A,1),log2.num_cons]);
% plot(1:num_iter+2,[size(X.A,1),log3.num_cons]);
xlabel('iteration');
ylabel('number of constraints');
legend('new method','old method');
% legend('new rho ball','old rho ball','rand rho_ball')

%%

samples = 10*randn(5,10000);
counter = 0;
for i = 1:10000
    if Xinv2.A*samples(:,i) <= Xinv2.b
        counter = counter +1
    end
end
    

