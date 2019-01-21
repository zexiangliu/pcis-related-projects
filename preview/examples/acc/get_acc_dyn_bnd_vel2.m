function dyn = get_acc_dyn_bnd_vel2(param)
% acc dynamics with constant lead car velocity.

    % Parameters
    m = param.m;
    f0 = param.f0;
    f1 = param.f1;
    f2 = param.f2;
    g = param.g;

    % Bounds

    vmin = param.vmin;
    vmax = param.vmax;
    thetamin = param.thetamin;
    thetamax = param.thetamax;
    umax = param.umax;
    umin = param.umin;
    v_l = param.v_l;
    
    % Time discretization
    dt = param.h;
    
    A = [1-f1/m*dt 0
        -1*dt          1];
    B = [1/m*dt;0];
    D1 = [-g*dt;0];
    K = [-f0/m*dt;0];
    D2 = [0;dt];
    
    XU = Polyhedron('H', [0 0 1 umax;
                          0 0 -1 -umin]);
                  
    dyn = cell(length(thetamin),1);

    for i = 1:length(thetamin)
        % constraints on the disturbances
        P = Polyhedron('H', [1  0 thetamax(i);
                             -1 0 -thetamin(i);
                             0  1 v_l(2);
                             0 -1 -v_l(1)]);
        dyn{i} = Dyn(A, K, B, XU, [],[],[],{zeros(2),zeros(2)}...
            , {D1,D2}, P);
    end
end