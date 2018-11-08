b1 = Polyhedron('H',[1 5;-1 5]);
b2 = Polyhedron('H',[1 3;-1 6]);
b3 = Polyhedron('H',[1 3;-1 5]);

B = PolyUnion([b1,b2]);