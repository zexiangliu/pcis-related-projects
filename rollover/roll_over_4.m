% Compute an invariant set for a triple integrator system


g = 9.81;
m = 1224;
Jxx = 362.6;
Jzz = 1280;
lv  = 1.102;
lh  = 1.25;
T   = 1.51;
h   = 0.375;
c   = 4000;
k   = 36075;
Cv  = 90240;
Ch  = 180000;

% Definitions: see (1), (2)
Jxeq = Jxx+m*h^2;
sg   = Cv+Ch;
rho  = Ch*lh-Cv*lv;
kp   = Cv*lv^2+Ch*lh^2; % note kp (kappa) is different from k

v_nominal = 22.5;

delta_A = [(sg*Jxeq)/(m*Jxx*v_nominal^2)  -(rho*Jxeq)/(m*Jxx*v_nominal^2)-1  0  0;...
           -rho/(Jzz*v_nominal^2)  kp/(Jzz*v_nominal^2)  0  0;
           (h*sg)/(Jxx*v_nominal^2)   -(h*rho)/(Jxx*v_nominal^2)   0  0;
           0   0   0   0];

dt = 0.01; 
delta_Adt = delta_A*dt;

% System matrices: already discrete-time
Adt = [0.8646  -0.1382  -0.0379  -0.2869;...
       0.0379   0.8701  -0.0008  -0.0062;
      -0.1081   0.0595   0.8938  -0.8054;
      -0.0006   0.0003   0.0095   0.9959];

% Bdt = 1e-3*[0.9351; 0.7450; 0.8422; 0.0044];
Bdt = [0.9351; 0.7450; 0.8422; 0.0044];

C = [0 0 -0.4412 -3.9793];

% K = dlqr(Adt, Bdt, C'*C, 1);
K = [0 0 0 0];
Adt = Adt - Bdt*K;

% Bounds
% xmax = [100; 10; 20; 2];
xmax = [20; 3.5; 3.5; 1.5];
ymax = 0.95; 
umax = 1e-3*142.73; % see above Fig. 1,  https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=5280801

QQ = diag(1./xmax);
Adt = QQ*Adt/QQ;
Bdt = QQ*Bdt;
xmax = [1; 1; 1; 1];
C = C/QQ;

X = Polyhedron('A', [eye(4), zeros(4,1); -K, 1; -eye(4), zeros(4,1); K, -1; [C, 0]; [-C, 0]], 'b', [[xmax; umax]; [xmax; umax]; ymax; ymax]);
%  X = Polyhedron('A', [C; -C], 'b', [ymax; ymax]);


Adt = [Adt, Bdt; 0 0 0 0 1];
delta_Adt = [delta_Adt, zeros(4,1); zeros(1,5)];

P = Polyhedron('H', [1 1; -1 1]); % 0.1 -> 34, 1->45

d = Dyn(Adt,[], [], [], {delta_Adt},{[0;0;0;0;0]},P);


Xinv = win_always(d, X, 0.00001, false, 1);

save data_0309.mat

%plot(Xinv, 'alpha', 0.75)
%xlabel('$x$', 'interpreter', 'latex')
%ylabel('$\dot x$', 'interpreter', 'latex')
%zlabel('$\ddot x$', 'interpreter', 'latex')


