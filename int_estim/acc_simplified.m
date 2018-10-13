clc;clear all;close all;
% Compute an invariant set for a simplified ACC model

% Parameters
m = 1650;
f0 = 0.1;
f1 = 5;
f2 = 0.25;
g = 9.82;

% Bounds

vmin = 0;
vmax = 35;
thetamin = sind(-12);
thetamax = sind(10);
umax = 0.2*m*g;
umin = -0.2*m*g;

% Time discretization
h = 0.01;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

A = exp(-f1*h/m);
B = (1-A)/f1;
D = -m*g*B;
K = -f0*B;

X = Polyhedron('A', [1; -1], 'b', [vmax;-vmin]);

XU = Polyhedron('H', [0 1 umax;
				      0 -1 -umin]);
                  
P = Polyhedron('H', [1 thetamax;
                     -1 -thetamin]);

d1 = Dyn(A, K, B, XU, {0}, {D}, P);
% d1 = Dyn(A, K, B, XU);
d2 = Dyn(A, K, B, XU, [],[],[],{0}, {D}, P);


%%
Xinv1 = win_always(d1, X, 0.00, false, 1);

% Pre1 = d1.pre(X,0);

% Pre2 = d2.pre(X,0);

Xinv2 = win_always(d2, X, 0.00, false, 1);

%%
% plot(Xinv, 'alpha', 0.75)
% xlabel('$x$', 'interpreter', 'latex')
% ylabel('$\dot x$', 'interpreter', 'latex')
% zlabel('$\ddot x$', 'interpreter', 'latex')