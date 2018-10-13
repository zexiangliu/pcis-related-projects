function [list_dyn_ann, list_dyn_caut, dyn_ann, dyn_caut] = get_dyn(u,dt,param)
% Given parameters in the dynamics, control inputs and sampling time,
% return the lists of dynamics for annoying driver and cautious driver for
% each input.

%  INPUTS: u --- list of inputs [u1 u2 u3 u4 ... u_n], ith column is the
%                input at time i;
%          dt --- sampling time
%          param --- the parameters in the system equations. (see the
%          documentations of the model used in the intention estimation.
% OUTPUTS: list_dyn_ann --- cell of annoying dynamics 
%                           at t0, t1, t2, ..., t_n
%          list_dyn_caut --- cell of cautious dynamics 
%                            at t0, t1, t2, ..., t_n
%          dyn_ann --- the dynamics of annoying driver with bounded inputs
%          dyn_caut --- the dynamics of the cautious driver with bounded
%                       inputs

list_dyn_ann = cell(size(u,2),1);
list_dyn_caut = cell(size(u,2),1);

KA = param.KA;
f1 = param.f1;
KC1 = param.KC1;
KC2 = param.KC2;
KC3 = param.KC3;
vdes = param.vdes;
dA = param.dA;
dC = param.dC;
a_ex = param.a_ex;
v_ey = param.v_ey;

%% input fixed
% ==== System Matrices of Annoying Driver ====
%   states are [v_ex, y_e, h, v_Lx]
A1 = [1-f1*dt 0 0 0;
           0 1 0 0;
         -dt 0 1 dt;
       0 0 -KA*dt 1];
B1 = [0;0;0;0];

F1 = @(u) [dt 0 0 0;0 dt 0 0]'*u;
% Disturbances [w_ex, w_ey, w_Lx, dA]
Fd1 = {[dt 0 0 0]',[0 dt 0 0]',[0 0 0 dt]',[0 0 0 dt]'};

% ==== System Matrices of Cautious Driver ====
A2 = [1-f1*dt 0 0 0;
           0 1 0 0;
         -dt 0 1 dt;
       0 -KC2*dt KC3*dt 1-KC1*dt];
B2 = [0;0;0;0];

F2 = @(u) [dt 0 0 0;0 dt 0 0]'*u + [0 0 0 KC1*vdes*dt]';
% Disturbances [w_ex, w_ey, w_Lx, dC]
Fd2 = {[dt 0 0 0]',[0 dt 0 0]',[0 0 0 dt]',[0 0 0 dt]'};

Ad = {zeros(4),zeros(4),zeros(4),zeros(4)};

% Constraints
H_x = [eye(5);-eye(5)];
h_x = [30;4.5;300;25;0;-16;0.9;300;0;0];
XU = Polyhedron('A', H_x, 'b', h_x);

H_d = [eye(4);-eye(4)];
h_d1 = [0 0 0 dA(2) 0 0 0 -dA(1)]';
h_d2 = [0 0 0 dC(2) 0 0 0 -dC(1)]';
D1 = Polyhedron('A', H_d, 'b', h_d1);
D2 = Polyhedron('A', H_d, 'b', h_d2);

for i = 1:size(u,2)
    list_dyn_ann{i} = Dyn(A1, F1(u(:,i)), B1, XU, [], [],[], Ad, Fd1, D1);
    list_dyn_caut{i} = Dyn(A2, F2(u(:,i)), B2, XU, [], [],[], Ad, Fd2, D2);
end


%% input in a bound
%   states are [v_ex, y_e, h, v_Lx]
F_ann = [0;0;0;0];
% Disturbances [w_ex, w_ey, w_Lx, u1, u2, dA]
Fd_ann = {[dt 0 0 0]',[0 dt 0 0]',[0 0 0 dt]',...
    [dt 0 0 0]',[0 dt 0 0]',[0 0 0 dt]'};

Hd_ann = [eye(6);-eye(6)];
hd_ann = [0 0 0 a_ex(2) v_ey(2) dA(2) 0 0 0 -a_ex(1) -v_ey(1) -dA(1)]';
D_ann = Polyhedron('A', Hd_ann, 'b', hd_ann);

% ==== System Matrices of Cautious Driver ====
F_caut = [0 0 0 KC1*vdes*dt]';
% Disturbances [w_ex, w_ey, w_Lx, u1, u2, dC]
Fd_caut = {[dt 0 0 0]',[0 dt 0 0]',[0 0 0 dt]',...
           [dt 0 0 0]',[0 dt 0 0]',[0 0 0 dt]'};
       
Hd_caut = [eye(6);-eye(6)];
hd_caut = [0 0 0 a_ex(2) v_ey(2) dC(2) 0 0 0 -a_ex(1) -v_ey(1) -dC(1)]';
D_caut = Polyhedron('A', Hd_caut, 'b', hd_caut);

Ad = {zeros(4),zeros(4),zeros(4),zeros(4),zeros(4),zeros(4)};

dyn_ann = Dyn(A1, F_ann, B1, XU, [], [],[], Ad, Fd_ann, D_ann);
dyn_caut = Dyn(A2, F_caut, B2, XU, [], [],[], Ad, Fd_caut, D_caut);
end