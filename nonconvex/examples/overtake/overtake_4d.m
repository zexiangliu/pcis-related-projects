function [dyn,A,B,E,D,XU] = overtake_4d()
% the state is [h_1,h_2, v_e, y]
% the input is [a_e, v_y]
constant_4d
A = [1 0 -dt 0
     0 1 -dt 0
    0 0 (1-f1*dt) 0
    0 0 0 1];
B = [0 0
    0 0
    dt 0
    0 dt];
K = zeros(4,0);
E = [dt 0;
    0 dt;
    0 0;
    0 0];
D = Polyhedron('lb',[vL1_min, vL2_min],'ub',[vL1_max,vL2_max]);
XU = Polyhedron('H', [0 0 0 0 1 0 u_max
                      0 0 0 0 -1 0 -u_min
                      0 0 0 0 0 1 vy_max
                      0 0 0 0 0 -1 vy_min]);
dyn = Dyn(A, K, B, XU, [],[],[], {zeros(4,4),zeros(4,4)},{E(:,1),E(:,2)}, D); 
dyn.check;
end