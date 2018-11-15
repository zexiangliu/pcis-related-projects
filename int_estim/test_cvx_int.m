clc; clear all; close all;
% to run this code, you need to add the path './get_dyn/' and checkout the
% pre_intersect branch under the pcis

addpath('get_dyn')
con = constants_tri();

%% Parameters

[dyn_a , dyn_c] = get_takeover_pwd2();

%% Create Safe Set and Small Invariant Set

X1 = Polyhedron('UB', [con.v_max;   con.y_max;      con.h_max;      Inf],...
                'LB', [con.v_min;   con.y_min;      con.h_min;     -Inf]);
X2 = Polyhedron('UB', [con.v_max;   con.y_max;      con.h_max;     Inf],...
                'LB', [con.v_min;   -con.y_min;     -con.h_max;    -Inf]);
X3 = Polyhedron('UB', [con.v_max;   con.y_max;      -con.h_min;    Inf],...
                'LB', [con.v_min;   con.y_min;      -con.h_max;    -Inf]);

% Safe set 
Safe = PolyUnion([X1 X2 X3]);

% cinv set
V = X2;
rho = 0;

%% Set up Inside-out algorithm

max_iter = 20;
iter_num = 1;
vol = volumePolyUnion(V);

fig =figure;

% profile on;
counter = 0;
while(1)
    counter = counter + 1;
    pre_V = pre(dyn_c, V, rho);
    V_old = V;
    V = IntersectPolyUnion(Safe,pre_V);
    V_saved = V;
    try
        V.merge();
    catch
        V = V_saved;
        V.reduce();
    end
    if(mod(counter,10)==0)
      V_old = IntersectPolyUnion(V_old, react_zone);
      vol = volumePolyUnion(setMinus(...
          IntersectPolyUnion(V,react_zone),V_old));
    end
    
%     fig = figure;
    visual(V,fig);
    if(vol == 0 || iter_num >= max_iter)
        break;
    end
    iter_num = iter_num + 1;
    disp("iter_num: "+num2str(iter_num)+", residual volume: "+num2str(vol));
end
% profile viewer;


