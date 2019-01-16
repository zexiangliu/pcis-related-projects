function dyn = get_simple_acc_dyn(param)
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
    
    A = [exp(-f1*dt/m) 0
        -1*dt          1];
    B = [(1-A(1,1))/f1;0];
    D = [-m*g*B(1);0];
    K = [-f0*B(1);v_l*dt];
    
    XU = Polyhedron('H', [0 0 1 umax;
                          0 0 -1 -umin]);
                  
    dyn = cell(length(thetamin),1);

    for i = 1:length(thetamin)
        % constraints on the disturbances
        P = Polyhedron('H', [1 thetamax(i);
                             -1 -thetamin(i)]);
        dyn{i} = Dyn(A, K, B, XU, [],[],[],{zeros(2)}...
            , {D}, P);
    end
end