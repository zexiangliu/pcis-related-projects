% test_pwa_expand2.m
% Simple example where safe set is nonconvex and we use our method to try
% to generate a controlled invariant set.

% We will talk about a particle that we can control moving in a grid world
% with 2 obstacles.

%% Constants %%
clear;close all;clc;

X = Polyhedron('lb',[-5 -5],'ub',[5;5]);

obst1 = Polyhedron('lb',[0;0],'ub',[2,2]);
obst2 = Polyhedron('lb',[-2 -1],'ub',[-1 1]);

S = X \ obst1;
S = S \ obst2;

figure;
plot(S)

% Get Dynamics
figure;
plot(S(4))

%Create Dynamics for each region in S.
n = 2; m = 2;
XU = Polyhedron('lb',[-inf(1,n) -ones(1,m)],'ub',[inf(1,n) ones(1,m)]);
D = Polyhedron('lb',[0],'ub',[1] );

d1 = Dyn(eye(n),zeros(n,1),eye(n), XU, ...
            {}, {}, Polyhedron(), ...
            {zeros(n)},{[0.5;0]}, D );

d2 = Dyn(eye(n),zeros(n,1),eye(n), XU, ...
            {}, {}, Polyhedron(), ...
            {zeros(n)},{[0;0.5]}, D );

d3 = Dyn(eye(n),zeros(n,1),eye(n), XU, ...
            {}, {}, Polyhedron(), ...
            {zeros(n)},{[0;-0.5]}, D );

d4 = Dyn(eye(n),zeros(n,1),eye(n), XU, ...
            {}, {}, Polyhedron(), ...
            {zeros(n)},{[0;-0.5]}, D );

d5 = Dyn(eye(n),zeros(n,1),eye(n), XU, ...
            {}, {}, Polyhedron(), ...
            {zeros(n)},{[0;-1]}, D );

d6 = Dyn(eye(n),zeros(n,1),eye(n), XU, ...
            {}, {}, Polyhedron(), ...
            {zeros(n)},{[0;1]}, D );

d7 = Dyn(eye(n),zeros(n,1),eye(n), XU, ...
            {}, {}, Polyhedron(), ...
            {zeros(n)},{[0.5;0.5]}, D );

%Create PwDyn Construction String.
dyn_list_str = ['{'];
reg_list_str = ['{'];
for ind = 1:7
    dyn_list_str = [ dyn_list_str 'd' num2str(ind) ];
    reg_list_str = [ reg_list_str 'S(' num2str(ind) ')' ];
    if ind ~= 7
        dyn_list_str = [ dyn_list_str ',' ];
        reg_list_str = [ reg_list_str ',' ];
    end
end
dyn_list_str = [ dyn_list_str '}' ];
reg_list_str = [ reg_list_str '}' ];


pwd0 = PwDyn( X , eval(reg_list_str) , eval(dyn_list_str) );

%% Create Safe Set and Small Invariant Set

% Safe set 
S2 = PolyUnion(S); 
% figure;clf;hold on
% for s=1:S.Num
%     plot(S.Set(s).projection([2 3]));
% end
% set(gca,'Xdir','reverse','Ydir','reverse');
% xlabel('y');
% ylabel('h');
    

% cinv set
C = S(end);

% reach
rhoPre = 1e-6;
Xr = expand(pwd0, S2, C, rhoPre);

figure;
hold on;
for i_cell = 1:length(Xr)
  for i_poly = 1:length(Xr{i_cell})
    plot(Xr{i_cell}(i_poly).projection([2 3]), 'color', 'green')
  end
end
