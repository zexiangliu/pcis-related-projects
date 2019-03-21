function dyn = get_lk_dyn2(param)
% dynamics of lane keeping for longitudinal speed as a disturbance.

% parameters
C_af = param.C_af;
C_ar = param.C_ar;
m = param.m;
b = param.b;
Iz = param.Iz;
a = param.a;

d_f_max = param.steer_max;
d_f_min = param.steer_min;

rd_min = param.rd_min;
rd_max = param.rd_max;

ud_min = param.ud_min;
ud_max = param.ud_max;

A0 = [0 1 0 0;
    0 0 0 0;
    0 0 0 1;
    0 0 0 0];
A1 = @(f1) [0 0 f1 0;
           0 0 0 -f1;
           0 0 0 0
           0 0 0 0];
A2 = @(f2) [0 0 0 0;
            0 -f2*(C_af+C_ar)/m 0 f2*(b*C_ar - a*C_af)/m;
            0 0 0 0;
            0 f2*(b*C_ar-a*C_af)/Iz 0 -f2*(a^2*C_af + b^2*C_ar)/Iz] 

B = [0; C_af/m; 0; a*C_af/Iz];

K = [0;0;0;0];

D = [0;0;-1;0];

XU = Polyhedron('H', [0 0 0 0 1 d_f_max;
                      0 0 0 0 -1 -d_f_min]);


dyn = cell(length(rd_min)*length(ud_min),1);

for i = 1:length(dyn)
    [sub_r,sub_u] = ind2sub([length(rd_min),length(ud_min)],i);
    V = ch_u(ud_min(sub_u),ud_max(sub_u));
    % constraints on the disturbances
    P = Polyhedron('H', [1 rd_max(sub_r);
                         -1 -rd_min(sub_r)]);
    dyn{i} = cell(4,1);
    for k = 1:4
        A = A0 + A1(V(k,1)) + A2(V(k,2));
        dyn{i}{k} = Dyn(A, K, B, XU, [],[],[],{zeros(4,4)}, {D}, P);
    end
end

if length(dyn) == 1
    dyn = dyn{1};
end
end

