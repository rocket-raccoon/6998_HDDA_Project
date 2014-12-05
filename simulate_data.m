function [ Y ] = simulate_data( t, p, sigma )
    
    m1 = 0;
    m2 = 2;
    b = 2;
    Y = zeros(t,p);
    
    for i = 1:p,
       for j = 1:t,
            noise = normrnd(0, sigma);
            Y(j,i) = m1*j^2 + m2*j + b + noise;
       end
    end
    
end

