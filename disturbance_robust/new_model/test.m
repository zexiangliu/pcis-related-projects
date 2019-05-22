clc;close all;clear all;

load A.mat 
load B.mat
load E.mat
load K.mat
colorOrder = get(gca, 'ColorOrder');


XU = Polyhedron('H', [0 0 1 0 150;
                      0 0 -1 0 0;
                      0 0 0 1 50;
                      0 0 0 -1 0]);
D = Polyhedron('H', [1 150;
                    -1 0]);

dyn = Dyn(A, K , B, XU,[],[],[], {zeros(2)},{E},D);

X = Polyhedron('lb', [60;0.5],'ub',[80,0.7]);

W = dyn.win_always(X,0,0,1);

plot(W);

%%

% eps_list = 125 + (1:5)*40;
% 
% for i = 1:length(eps_list)
%     D_tmp = Polyhedron('H', [1 eps_list(i);
%                     -1 eps_list(i)]);
%     dyn_tmp = Dyn(A, K + E*125, B, XU,[],[],[], {zeros(2)},{E},D_tmp);
% %     X_tmp = X.intersect(dyn_tmp.pre(W,0));
%     X_tmp = dyn_tmp.win_always(W,0,0,1,20);
%     hold on;
%     plot(X_tmp,'color', colorOrder(mod(i,7)+1,:));
% end

%%
ops = sdpsettings('solver','gurobi');
ops = sdpsettings(ops,'verbose',0);

H = W.A;
h = W.b;

x_list = [linspace(60,60.4,10),linspace(60.4,80,50)];
y_list = [linspace(0.5,0.695,50),linspace(0.695,0.7,10)];

[X_mesh,Y_mesh] = meshgrid(x_list,y_list);

C = zeros(size(X_mesh));

for i = 1:size(X_mesh,1)
    i
    for j = 1:size(X_mesh,2)
        x = [X_mesh(i,j);Y_mesh(i,j)];
        if any(W.A*x > W.b)
            continue;
        end
        
        d = sdpvar(1);
        u = sdpvar(2,1);
        Constraints = [H*(dyn.A*x+dyn.B*u+dyn.Fd{1}*d + dyn.F) <= h, ...
            H*(dyn.A*x+dyn.B*u + dyn.F) <= h,...
             XU.A*[x;u]<=XU.b];
        Objective = -d;
        optimize(Constraints,Objective,ops);
        C(i,j) = value(d);
%         hold on;
%         plot3(x(1),x(2),value(d),'.','markersize',20);
%         drawnow;
    end
end
%%
contourf(X_mesh,Y_mesh,C,30);
colorbar;
caxis([0 4000])
axis([60-1,80+1,0.5-0.01,0.7+0.01])

%%

contourf(X_mesh,Y_mesh,E,10);
colorbar;
caxis([0 4000])
axis([60-1,80+1,0.5-0.01,0.7+0.01])