function checked_chrom = HT_constraints(chrom, BCData)
     % Individual Structure: N,w,t,l,fin_type,material  
     chrom(1) = round(chrom(1));
     chrom(end-1) = round(chrom(end-1));
     chrom(end) = round(chrom(end));
     N =  round(chrom(1));
     d =  BCData.min_pitch;
     t_bound = (BCData.H/N) - ( (N-1)/N ) * d;
     k = BCData.Mats{chrom(end)}.K;   
     h = BCData.h;      
     if chrom(3) > t_bound 
        chrom(3) = t_bound;
     end
     % Pg. 165 Incropera
     m = ((2*h)/(k*chrom(3)))^(1/2); 
     if chrom(4) > 2.65/m
        chrom(4) = 2.65/m;
     end
     checked_chrom = chrom;
end