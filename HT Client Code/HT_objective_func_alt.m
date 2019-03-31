function [fitness_val,qt,V,totalCost,eff] = HT_objective_func_alt(chrom,bc)
    
   % Individual Structure: N,w,t,l,fin_type,material
    
   % [Af,At,Volume] = calcGeom(ind,BCdata); % Calculate geometric props. given the type
   % nf = singleEfficiency(ind,BCdata); % Single fin efficiency  
    
   
   % N, fin_type, and material are discrete variables
   chrom(1) = round(chrom(1));
   chrom(end-1) = round(chrom(end-1));
   chrom(end) = round(chrom(end));    
    
    N = chrom(1);
    w = chrom(2);    
    t = chrom(3);
    L = chrom(4);
    fin_type = chrom(end-1);  
    k = bc.Mats{chrom(end)}.K;
    h = bc.h;
    m = ((2*h)/(k*t))^(1/2); 
    
    switch(fin_type)
        case 1
            %rectangular fin
            Lc = L + (t/2);
            Af = 2 * w * Lc;
            Ap = t * L;     
            nf = tanh(m*Lc) / (m*Lc); 
            manufacturing_factor = 1;
         case 2
            %triangular fin 
            Af = 2 * w * sqrt(L^2 + (t/2)^2);
            Ap = (t/2)*L;
            I0 = besseli(0,2*m*L);
            I1 = besseli(1,2*m*L);
            nf = ( 1 / (m*L) ) * ( I1/I0 );
            manufacturing_factor = 1.5;
        case 3
            %parabolic fin
            C1 = sqrt(1+(t*L)^2);
            Af = w * ( (C1*L) + ((L^2)/t) * log( (t/L) + C1 ) );
            Ap = (t/3)*L;
            nf = 2 / (sqrt( (4 * (m*L)^2) + 1) + 1); 
            manufacturing_factor = 2;
    end  
    
    V = N*w*Ap;
    At = N*Af + ((bc.W * bc.H) - (N*t*w));
     
    qt = bc.h*At*(1-(N*Af/At)*(1-nf))*bc.ThetaBase;
    
    % factor * cost per kg * density * volume
    totalCost = manufacturing_factor * bc.Mats{chrom(end)}.cost * bc.Mats{chrom(end)}.rho * V;
    
    
    qb = bc.h * (bc.W * bc.H) * bc.ThetaBase;
    eff= qt/qb;
    
    fitness_val = eff; 
        
    
    % Fitness Penalization
    if(totalCost > bc.budget)
        fitness_val = fitness_val/1000;
    end
    
    if(V > bc.maxVol)
        fitness_val = fitness_val/50;
    end
    
    if(qt < bc.minQt)
        fitness_val = fitness_val/1000;
    end
end


