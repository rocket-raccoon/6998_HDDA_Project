function [ lb, ub ] = get_bounds( residuals, a, p, q)
    
    %Unvec residuals to get nxp matrix
    residuals = vec2mat(residuals, p);
    
    %Calculate the lower und upper quantiles
    lb = quantile(residuals, a / 2);
    ub = quantile(residuals,(1-a)/2);
    
    %Expand to fit matrix
    lb = repmat(lb, [q 1]);
    ub = repmat(ub, [q 1]);
    
end

