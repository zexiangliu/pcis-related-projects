function pre_x = pre_ch(dyn,X,rho)
    pre1 = dyn{1}.pre(X,rho);
    pre2 = dyn{2}.pre(X,rho);
    pre3 = dyn{3}.pre(X,rho);
    pre4 = dyn{4}.pre(X,rho);
    
    pre_x = Polyhedron('H',[pre1.H;pre2.H;pre3.H;pre4.H]);
    pre_x.minHRep;