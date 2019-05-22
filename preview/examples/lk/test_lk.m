clc;clear all;
mptopt('lpsolver', 'GUROBI', 'qpsolver', 'GUROBI');
% safety constraints      
y_max = 0.9;
y_min = -0.9;
v_max = 1.2;
v_min = -1.2;
Phi_max = 0.05;
Phi_min = -0.05;
dPhi_max = 0.3;
dPhi_min = -0.3;
Safe = Polyhedron("H",...
    [1 0 0 0 y_max
    -1 0 0 0 -y_min
    0 1 0 0 v_max
    0 -1 0 0 -v_min
    0 0 1 0 Phi_max
    0 0 -1 0 -Phi_min
    0 0 0 1 dPhi_max
    0 0 0 -1 -dPhi_min]);

% vehicle parameters
param.C_af = 133000;
param.C_ar = 98800;
param.m = 1800;
param.u = 30;
param.b = 1.59;
param.Iz = 2315;
param.a = 1.11;
param.steer_max = pi/2; 
param.steer_min = -pi/2;

param.dt = 0.1;

% the dynamics with large rd range
param.rd_min = -0.05;
param.rd_max = 0.05;

dyn_all = get_lk_dyn(param);

% the dynamics with preview
num_seg = 5;
rd = linspace(-0.05,0.05,num_seg+1);

param.rd_min = rd(1:num_seg);
param.rd_max = rd(2:num_seg+1);

dyn_list = get_lk_dyn(param);
ts = [0 1 0 0 0; 
      1 0 1 0 0;
      0 1 0  1 0;
      0 0 1 0 1;
      0 0 0 1 0];

t_prev = 5*[0 1 0 0 0; 
          1 0 1 0 0;
          0 1 0 1 0;
          0 0 1 0 1;
          0 0 0 1 0];
t_hold = [[1 1 1 1 1]*1;
          inf inf inf inf inf];
pa = PrevAuto(num_seg,ts,dyn_list,t_prev,t_hold);

pre = @(dyn,X) dyn.pre(X,0);
vol = @(X) X.volume*10^6;
isContain = @(C1,C2) C1 <= C2;
inter = @(X1,X2) minHRep(X1.intersect(X2));
isEmpty = @(X) isEmptySet(X);
%%
% W_all = dyn_all.win_always(Safe,0,0,1);
% W3 = dyn_list{4}.win_always(Safe,0,0,1);
%%
X_list = {Safe,Safe,Safe,Safe,Safe};
[W,volume, W_hier, T_min] = pa.win_always(X_list,pre,vol,inter,isEmpty,isContain,[],1);

%% visualization
dim = [1 2 4];
fig=figure;
for i = 1:1
    hold on;
    visual(W{i},dim,fig,'g',1);
    view(-90.5,40)
end

W_new = Polyhedron('A',W_all.A,'b',W_all.b+1e-4);
visual(W_new,dim,fig,'r');