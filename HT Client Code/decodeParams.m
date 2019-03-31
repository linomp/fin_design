function decoded = decodeParams(individual,bc)
    % Individual Structure: N,w,t,l,fin_type,material
    
    
    chrom = individual.chrom;
    
    decoded = struct();
    decoded.NumFins = round(chrom(1));
    decoded.w = chrom(2)*1000;
    decoded.t = chrom(3)*1000;
    decoded.L = chrom(4)*1000;    
   
    if(chrom(end-1) == 1)
        decoded.finType = 'Rectangular profile';
    elseif(chrom(end-1) == 2) 
        decoded.finType = 'Triangular profile';
    elseif(chrom(end-1) == 3)
        decoded.finType = 'Parabolic profile';
    end 
    
    decoded.Material = bc.Mats{chrom(end)}.name;   
            
    [~,qt,V,cost,eff] = HT_objective_func_alt(chrom,bc);
    decoded.Qt = qt;
    decoded.V = V;
    decoded.eff = eff;
    decoded.cost = cost;
        
    fprintf('\nDECODED PARAMETERS: ');
    fprintf('\nNo. of fins: %i',decoded.NumFins);
    fprintf('\nw = %.3f [mm]', decoded.w); 
    fprintf('\nt = %.3f [mm]', decoded.t);
    fprintf('\nl = %.3f [mm]',decoded.L);  
    fprintf('\nFin type: %s',decoded.finType); 
    fprintf('\nMaterial: %s',decoded.Material); 
    
    fprintf('\nQt: %.3f [W]',qt);
    fprintf('\nEffectiveness: %.3f',eff);
    fprintf('\nV: %.3d [m^3]',V); 
    fprintf('\nCost: USD %f\n',cost);   
        
end