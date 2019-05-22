clc;clear all;close all;
load acc_data.mat
colorOrder = get(gca, 'ColorOrder');

W = W2;
dyn = dyn_all;
A = dyn.A;
B = dyn.B;
XU = dyn.XU;
E = dyn.Fd{2};
K = dyn.F;

%%
% subplot(1,2,1);
% hold on;
% eps_list = 2.5 - (1:5)*0.1;
% 
% 
% for i = length(eps_list):-1:1
%     D_tmp = Polyhedron('H', [1 0 0.1736;
%                              -1 0 0.1736;
%                              0 1 eps_list(i);
%                              0 -1 eps_list(i)]);
%     dyn_tmp = Dyn(A, K + E*27.5, B, XU,[],[],[], {zeros(2),zeros(2)},dyn_all.Fd,D_tmp);
% %     X_tmp = X.intersect(dyn_tmp.pre(W,0));
%     X_tmp = dyn_tmp.expand(W,X,0,1,5);
%     hold on;
%     plot(X_tmp,'color', colorOrder(mod(i,7)+1,:));
% %     plot(W);
% end

%%
ops = sdpsettings('solver','gurobi');
ops = sdpsettings(ops,'verbose',0);

H = W.A;
h = W.b;

x_list = linspace(24.09,24.6,50);
y_list = linspace(42,51,30);

[X_mesh,Y_mesh] = meshgrid(x_list,y_list);

C = zeros(size(X_mesh));
% subplot(1,2,1);
plot(W);
for i = 1:size(X_mesh,1)
    i
    for j = 1:size(X_mesh,2)
        x = [X_mesh(i,j);Y_mesh(i,j)];
%         if any(W.A*x > W.b)
%             continue;
%         end
        
        d = sdpvar(1);
        u = sdpvar(1,1);
        Constraints = [H*(dyn.A*x+dyn.B*u+dyn.Fd{1}*0.1736+dyn.Fd{2}*d + dyn.Fd{2}*27.5 + dyn.F) <= h, ...
            H*(dyn.A*x+dyn.B*u-dyn.Fd{1}*0.1736+dyn.Fd{2}*d + dyn.Fd{2}*27.5+ dyn.F) <= h,...
            H*(dyn.A*x+dyn.B*u+dyn.Fd{1}*0.1736-dyn.Fd{2}*d + dyn.Fd{2}*27.5+ dyn.F) <= h,...
            H*(dyn.A*x+dyn.B*u-dyn.Fd{1}*0.1736-dyn.Fd{2}*d + dyn.Fd{2}*27.5 + dyn.F) <= h,...
             XU.A*[x;u]<=XU.b];
        Objective = -d;
        optimize(Constraints,Objective,ops);
        C(i,j) = value(d);
        hold on;
        plot3(x(1),x(2),value(d),'.','markersize',20);
        drawnow;
    end
end
%%
% subplot(1,2,1);
% plot(W,'FaceAlpha',1);
axis([24,24.6,42,51]);
% subplot(1,2,2);
hold on;
contourf(X_mesh,Y_mesh,C,25);

plot(W,'edgecolor','r','alpha',0);

colorbar;
% caxis([0 3500])
axis([24,24.6,42,51]);
