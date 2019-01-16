function vol = volumePolyUnion(P)
    
    vol = 0;
    
    if isa(P,'PolyUnion')
        for i = 1:P.Num
            vol = vol + P.Set(i).volume;
        end
    else
        vol = P.volume;
    end

end