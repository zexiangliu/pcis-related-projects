function dyn = get_acc_dyn(param)

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

    % Time discretization
    h = param.h;
    
    A = exp(-f1*h/m);
    B = (1-A)/f1;
    D = -m*g*B;
    K = -f0*B;
    
    XU = Polyhedron('H', [0 1 umax;
                      0 -1 -umin]);
                  
    dyn = cell(length(thetamin),1);
    for i = 1:length(thetamin)
        
        % constraints on the disturbances
        P = Polyhedron('H', [1 thetamax(i);
                             -1 -thetamin(i)]);
        % Non-measurable disturbance
        dyn{i} = Dyn(A, K, B, XU, {0}, {D}, P);
%         dyn{i} = Dyn(A, K, B, XU, [],[],[],{0}, {D}, P);
    end
end