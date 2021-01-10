function [dyn,A,B,E,D,XU] = dyn_acc()
% the state is [h, v_e, y]
% the input is [a_e, v_y]
constant_3d
A = [1 -dt
    0 (1-f1*dt)];
B = [0;dt];
K = zeros(2,0);
E = [dt;0];
D = Polyhedron('lb',[vL_min],'ub',[vL_max]);
XU = Polyhedron('H', [0 0  1  u_max
                      0 0 -1 -u_min]);
dyn = Dyn(A, K, B, XU, [],[],[], {zeros(2,2)},{E}, D); 
dyn.check;
end