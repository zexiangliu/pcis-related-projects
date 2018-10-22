function [list_dyn_ann, list_dyn_caut, dyn_ann, dyn_caut] = get_pwadyn(u,dt,param)
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
v_ex = param.v_ex;
y_e = param.y_e;
h = param.h;
v_lx = param.v_lx;
w_ex = param.w_ex;
w_ey = param.w_ey;
w_Lx = param.w_Lx;
beta = param.beta;
v_ex_db = param.v_ex_db;

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
% % x-u constraints
H_xu = [eye(5);-eye(5)];
h_xu = [v_ex(2);y_e(2);h(2);v_lx(2);0;-v_ex(1);-y_e(1);-h(1);-v_lx(1);0];
XU = Polyhedron('A', H_xu, 'b', h_xu);
% % disturbance constraints
H_d = [eye(4);-eye(4)];
h_d1 = [w_ex(2) w_ey(2) w_Lx(2) dA(2) -w_ex(1) -w_ey(1) -w_Lx(1) -dA(1)]';
h_d2 = [w_ex(2) w_ey(2) w_Lx(2) dC(2) -w_ex(1) -w_ey(1) -w_Lx(1) -dC(1)]';
D1 = Polyhedron('A', H_d, 'b', h_d1);
D2 = Polyhedron('A', H_d, 'b', h_d2);

for i = 1:size(u,2)
    list_dyn_ann{i} = Dyn(A1, F1(u(:,i)), B1, XU, [], [],[], Ad, Fd1, D1);
    list_dyn_caut{i} = Dyn(A2, F2(u(:,i)), B2, XU, [], [],[], Ad, Fd2, D2);
end


%% input in a bound (piecewise dynamics)

dyn_ann_list = cell(3,1);
dyn_caut_list = cell(3,1);
reg_list = cell(3,1);

% ==== Domains ====
H_x = [eye(4);-eye(4)];
h_x = [v_ex(2);y_e(2);h(2);v_lx(2);-v_ex(1);-y_e(1);-h(1);-v_lx(1)];
domain = Polyhedron('A',H_x,'b',h_x);

H_reg1 = [1 0 0 0;-1 0 0 0];
h_reg1 = [v_ex_db;-v_ex(1)];
h_reg2 = [v_ex_db,v_ex_db+v_ey(2)/beta];
h_reg3 = [v_ex_db+v_ey(2)/beta,v_ex(2)];
reg_list{1} = Polyhedron('A',H_reg1,'b',h_reg1);
reg_list{2} = Polyhedron('A',H_reg1,'b',h_reg2);
reg_list{3} = Polyhedron('A',H_reg1,'b',h_reg3);

% ==== System Matrices of Annoying Driver ====
%   states are [v_ex, y_e, h, v_Lx]
F_ann = [0;0;0;0];
%%% For the case v_ex in region 1
Fd_ann = {[dt 0 0 0]',[0 dt 0 0]',[0 0 0 dt]',...
    [dt 0 0 0]',[0 0 0 dt]'};
Hd_ann = [eye(5);-eye(5)];
hd_ann = [w_ex(2) w_ey(2) w_Lx(2) a_ex(2) dA(2)...
            -w_ex(1) -w_ey(1) -w_Lx(1) -a_ex(1) -dA(1)]';
D_ann = Polyhedron('A', Hd_ann, 'b', hd_ann);
Ad = {zeros(4),zeros(4),zeros(4),zeros(4),zeros(4)};
Ew = [0 dt 0 0]';
XW_v = {[0 0 0 0 0],[0 0 0 0 0]}; % not sure about this part
dyn_ann_list{1} = Dyn(A1, F_ann, B1, XU, [], [],[], Ad, Fd_ann, D_ann,...
                    [],[],Ew,XW_v);
%==============================
% For the case v_ex in region 2
%==============================

% % the coefficient matrix of v_ey
Ew = [0 dt 0 0]';
XW_v = {[beta 0 0 0 0],[beta 0 0 0 0]}; % not sure about this part
dyn_ann_list{2} = Dyn(A1, F_ann, B1, XU, [], [],[], Ad, Fd_ann, D_ann,...
                    [],[],Ew,XW_v);
                
%==============================
% For the case v_ex in region 3
%==============================

% Disturbances [w_ex, w_ey, w_Lx, u1, u2, dA]
Ew = [0 dt 0 0]';
XW_v = {[0 0 0 0 v_ey(2)],[0 0 0 0 -v_ey(1)]}; % not sure about this part
dyn_ann_list{3} = Dyn(A1, F_ann, B1, XU, [], [],[], Ad, Fd_ann, D_ann,...
                    [],[],Ew,XW_v);

dyn_ann = PwDyn(domain,reg_list,dyn_ann_list);

% ==== System Matrices of Cautious Driver ====
F_caut = [0 0 0 KC1*vdes*dt]';
%%% For the case v_ex in region 1
% Disturbances [w_ex, w_ey, w_Lx, u1, dC]
Fd_caut = {[dt 0 0 0]',[0 dt 0 0]',[0 0 0 dt]',...
           [dt 0 0 0]',[0 0 0 dt]'};
       
Hd_caut = [eye(5);-eye(5)];
hd_caut = [w_ex(2) w_ey(2) w_Lx(2) a_ex(2) dC(2) ...
                -w_ex(1) -w_ey(1) -w_Lx(1) -a_ex(1) -dC(1)]';
D_caut = Polyhedron('A', Hd_caut, 'b', hd_caut);

Ad = {zeros(4),zeros(4),zeros(4),zeros(4),zeros(4)};

Ew = [0 dt 0 0]';
XW_v = {[0 0 0 0 0],[0 0 0 0 0]}; % not sure about this part
dyn_caut_list{1} = Dyn(A2, F_caut, B2, XU, [], [],[], Ad, Fd_caut,...
                        D_caut,[],[],Ew,XW_v);

% =============================
% For the case v_ex in region 2
% =============================
Ew = [0 dt 0 0]';
XW_v = {[beta 0 0 0 0],[beta 0 0 0 0]}; % not sure about this part
dyn_caut_list{2} = Dyn(A2, F_caut, B2, XU, [], [],[], Ad, Fd_caut,...
                        D_caut,[],[],Ew,XW_v);

% =============================                    
% For the case v_ex in region 3
% =============================
Ew = [0 dt 0 0]';
XW_v = {[0 0 0 0 v_ey(2)],[0 0 0 0 -v_ey(1)]}; % not sure about this part
dyn_caut_list{3} = Dyn(A2, F_caut, B2, XU, [], [],[], Ad, Fd_caut,...
                        D_caut,[],[],Ew,XW_v);

dyn_caut = PwDyn(domain,reg_list,dyn_caut_list);
end