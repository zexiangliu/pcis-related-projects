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
    v_l_max = param.v_l(2);
    v_l_min = param.v_l(1);
    a_l_max = param.a_l(2);
    a_l_min = param.a_l(1);

    % Time discretization
    dt = param.h;
    
    A = [exp(-f1*dt/m) 0 0
        -1*dt          1 1*dt
          0           0 1];
    B = [(1-A(1,1))/f1;0;0];
    D = [-m*g*B(1);0;0];
    Ew = [0;0;dt];
    K = [-f0*B(1);0;0];
    
    XU = Polyhedron('H', [0 0 1  0 v_l_max;
                          0 0 -1 0 -v_l_min;
                          0 0 0 1 umax;
                          0 0 0 -1 -umin]);
                  
    dyn = cell(length(thetamin),1);
    
    % domain 1: v_l_min < v_l < v_l_min - a_l_min*dt
    dom1 = Polyhedron('H', [0 0 1 v_l_min-a_l_min*dt;
                               0 0 -1 -v_l_min]);
    % domain 2: v_l_min-a_l_min*dt < v_l < v_l_max - a_l_max*dt
    dom2 = Polyhedron('H', [0 0 1 v_l_max - a_l_max*dt;
                            0 0 -1 -(v_l_min -a_l_min*dt)]);
    % domain 3: v_l_max - a_l_max*dt < v_l < v_l_max 
    dom3 = Polyhedron('H', [0 0 1 v_l_max;
                            0 0 -1 -(v_l_max - a_l_max*dt)]);
	reg_list = {dom1,dom2,dom3};
    domain = Polyhedron('H',[0 0 0 1]);
    for i = 1:length(thetamin)
        % constraints on the disturbances
        P = Polyhedron('H', [1 thetamax(i);
                             -1 -thetamin(i)]);
        XW_V1 = {[0 0 -1/dt v_l_min/dt],[0 0 0 a_l_max]};
        dyn1 = Dyn(A, K, B, XU, [],[],[],{zeros(3)}...
            , {D}, P,[],[],Ew,XW_V1);
        XW_V2 = {[0 0 0 a_l_min],[0 0 0 a_l_max]};
        dyn2 = Dyn(A, K, B, XU, [],[],[],{zeros(3)}...
            , {D}, P,[],[],Ew,XW_V2);
        XW_V3 = {[0 0 0 a_l_min],[0 0 -1/dt v_l_max/dt]};
        dyn3 = Dyn(A, K, B, XU, [],[],[],{zeros(3)}...
            , {D}, P,[],[],Ew,XW_V3);
        dyn{i} = PwDyn(domain,reg_list,{dyn1,dyn2,dyn3});
    end
end