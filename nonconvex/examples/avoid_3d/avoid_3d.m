function [dyn,A,B,E,D,XU] = avoid_3d(param)
% the state is [h, v_e, y]
% the input is [a_e, v_y]

A = [1 param.dt 0
    0 (1-param.f1*param.dt) 0
    0 0 1];
B = [0 0
    param.dt 0
    0 param.dt];
K = zeros(3,0);
E = [-param.dt;0;0];
D = Polyhedron('lb',[param.vL_min],'ub',[param.vL_max]);
XU = Polyhedron('H', [0 0 0 1 0 param.u_max
                      0 0 0 -1 0 -param.u_min
                      0 0 0 0 1 param.vy_max
                      0 0 0 0 -1 param.vy_min]);
dyn = Dyn(A, K, B, XU, [],[],[], {zeros(3,3)},{E}, D); 
dyn.check;
end