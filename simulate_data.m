function [ Y ] = simulate_data( t, p, sigma )
    
    m1 = 0.7;
    m2 = 2; %2
    b = 200;
    Y = zeros(t,p);
    
    for i = 1:p,
       for j = 1:t,
            noise = normrnd(0, sigma);
            noise2 = normrnd(0, 2*sigma);
            noise3 = normrnd(0, 2.5*sigma);
            Y(j,i) = exp(0.2*m1*j) + noise-1;
            Y(j,p+i) = exp(0.3*m1*j) + noise2-1;
            Y(j,2*p+i) = 0.4*m1*j + noise3-1;
       end
    end
    
end
