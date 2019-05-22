ops = sdpsettings('solver','linprog');
ops = sdpsettings(ops,'verbose',1);
d = sdpvar(1);
u = sdpvar(1,1);
Constraints = [H*(dyn.A*x+dyn.B*u+dyn.Fd{1}*0.1736+dyn.Fd{2}*d + dyn.Fd{2}*27.5 + dyn.F) <= h, ...
    H*(dyn.A*x+dyn.B*u-dyn.Fd{1}*0.1736+dyn.Fd{2}*d + dyn.Fd{2}*27.5+ dyn.F) <= h,...
    H*(dyn.A*x+dyn.B*u+dyn.Fd{1}*0.1736-dyn.Fd{2}*d + dyn.Fd{2}*27.5+ dyn.F) <= h,...
    H*(dyn.A*x+dyn.B*u-dyn.Fd{1}*0.1736-dyn.Fd{2}*d + dyn.Fd{2}*27.5 + dyn.F) <= h,...
     XU.A*[x;u]<=XU.b];
Objective = -d;
optimize(Constraints,Objective,ops);
value(d)

%%

pre = dyn.pre(W);
pre_xu = dyn.pre_xu(W);

% u = pre_xu.slice([1,2],x);

u = sdpvar(1);

Consts = [pre_xu.A*[x;u]<=pre_xu.b];

Obj = 1;

optimize(Consts,Obj,ops);


%%
pre_tmp = projection2(pre_xu,[1,2],'vrep')
% pre_tmp.A*x<=pre_tmp.b
plot(pre_tmp)