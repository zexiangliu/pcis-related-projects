function [ pwd_A , pwd_C ] = get_takeover_pwd( )
%get_takeover_pwd This function returns the 2 peicewise dynamics defined in
%Yunus Sahin's document
%[https://umich.box.com/s/mf77npzwp13jiifvg72ee126g0x3psqa].
%   
%   Output:
%       pwd_A: The peicewise affine dynamics for the ANNOYING driver.
%

%% Constants

%Maybe I should load some of these.
con = constants_tri;

%% Base Matrices

n_x = 4; %Dimension of the state space
n_u = 2; %Dimension of the input space

A = [ -con.f1 0 0 0;
      0 0 0 0;
      1 0 0 1;
      0 0 0 -1];

B = [eye(2); zeros(2)];

Bw = B;

%% Matrix Modifications for the Annoying driver.

%Region 1, for Annoying Driver
A_r1 = [ zeros(3,4) ;
         0 0 0 -1/con.dt ];
F_r1 = [zeros(3,1); con.vL_max/con.dt];

Bw_r1 = [ B zeros(n_x,1) ];

%Define Polyhedral domain as Hx * x <= h_x
Hx_r1 = -(con.K_ann + [ 0 0 0 1 ]); 
hx_r1 = -(con.vL_max - con.dLmax); 
r1 = Polyhedron('A',Hx_r1,'b',hx_r1);

%Region 2, for Annoying Driver
A_r2 = [zeros(3,4); con.K_ann ];
F_r2 = zeros(n_x,1);
Bw_r2 = [ B [zeros(3,1); 1] ];

Hx_r2 = [   con.K_ann + [ 0 0 0 1 ] ;
            -(con.K_ann + [ 0 0 0 1 ]) ];
hx_r2 = [   con.vL_max - con.dLmax ;
            con.vL_min + con.dLmin];
r2 = Polyhedron('A',Hx_r2,'b',hx_r2);

%Region 3, for Annoying Driver
A_r3 = [ zeros(3,4) ;
         0 0 0 -1/con.dt ];
F_r3 = [zeros(3,1); con.vL_min/con.dt];

Bw_r3 = [B zeros(n_x,1)];

Hx_r3 = con.K_ann + [ 0 0 0 1 ];
hx_r3 = con.vL_min + con.dLmin;
r3 = Polyhedron('A',Hx_r3,'b',hx_r3);

%Create PwDyn Object
dom = Polyhedron('lb',[con.v_min, con.y_min, -inf, con.vL_min ], ...
                 'ub',[con.v_max, con.y_max, inf, con.vL_max] );

D = Polyhedron('lb',[con.dmin_ACC,con.dmin_LK,con.dLmin],'ub',[con.dmax_ACC,con.dmax_LK,con.dLmax]) %Feasible disturbances
XU = Polyhedron('A',[zeros(n_u,n_x) eye(n_u) ; zeros(n_u,n_x) -eye(n_u) ], ...
                'b',[con.umax_ACC ; con.umax_LK ; -con.umin_ACC ; -con.umin_LK ]);

pwd_A = PwDyn(dom, { r1.intersect(dom) , r2.intersect(dom), r3.intersect(dom) } , ...
                { Dyn(A+A_r1, F_r1, B, XU , {} , {} , Polyhedron(), {zeros(n_x)}, {Bw_r1} , D ), ...
                  Dyn(A+A_r2, F_r2, B, XU , {} , {} , Polyhedron(), {zeros(n_x)}, {Bw_r2} , D ), ...
                  Dyn(A+A_r3, F_r3, B, XU , {} , {} , Polyhedron(), {zeros(n_x)}, {Bw_r3} , D )} );

             
clear A_r1 A_r2 A_r3 B_r1 B_r2 B_r3 F_r1 F_r2 F_r3 

%% Matrix Modifications for the Cautious driver.

%Region 1, for Annoying Driver
A_r1 = [ zeros(3,4) ;
         0 0 0 -1/con.dt ];
F_r1 = [zeros(3,1); con.vL_max/con.dt];

Bw_r1 = [ B zeros(n_x,1) ];

%Define Polyhedral domain as Hx * x <= h_x
Hx_r1 = -(con.K_cau + [ 0 0 0 1 ]); 
hx_r1 = -(con.vL_max - con.dLmax); 
r1 = Polyhedron('A',Hx_r1,'b',hx_r1);

%Region 2, for Annoying Driver
A_r2 = [zeros(3,4); con.K_cau ];
F_r2 = zeros(n_x,1);
Bw_r2 = [ B [zeros(3,1); 1] ];

Hx_r2 = [   con.K_cau + [ 0 0 0 1 ] ;
            -(con.K_cau + [ 0 0 0 1 ]) ];
hx_r2 = [   con.vL_max - con.dLmax ;
            con.vL_min + con.dLmin];
r2 = Polyhedron('A',Hx_r2,'b',hx_r2);

%Region 3, for Annoying Driver
A_r3 = [ zeros(3,4) ;
         0 0 0 -1/con.dt ];
F_r3 = [zeros(3,1); con.vL_min/con.dt];

Bw_r3 = [B zeros(n_x,1)];

Hx_r3 = con.K_cau + [ 0 0 0 1 ];
hx_r3 = con.vL_min + con.dLmin;
r3 = Polyhedron('A',Hx_r3,'b',hx_r3);


%Create PwDyn Object
dom = Polyhedron('lb',[con.v_min, con.y_min, -inf, con.vL_min ], ...
                 'ub',[con.v_max, con.y_max, inf, con.vL_max] );

D = Polyhedron('lb',[con.dmin_ACC,con.dmin_LK,con.dLmin],'ub',[con.dmax_ACC,con.dmax_LK,con.dLmax]) %Feasible disturbances
XU = Polyhedron('A',[zeros(n_u,n_x) eye(n_u) ; zeros(n_u,n_x) -eye(n_u) ], ...
                'b',[con.umax_ACC ; con.umax_LK ; -con.umin_ACC ; -con.umin_LK ]);

pwd_C = PwDyn(dom, { r1.intersect(dom) , r2.intersect(dom), r3.intersect(dom) } , ...
                { Dyn(A+A_r1, F_r1, B, XU , {} , {} , Polyhedron(), {zeros(n_x)}, {Bw_r1} , D ), ...
                  Dyn(A+A_r2, F_r2, B, XU , {} , {} , Polyhedron(), {zeros(n_x)}, {Bw_r2} , D ), ...
                  Dyn(A+A_r3, F_r3, B, XU , {} , {} , Polyhedron(), {zeros(n_x)}, {Bw_r3} , D )} );


end

