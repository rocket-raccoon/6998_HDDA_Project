function [ Li ] = create_littleL( a, B, n )
    Li = eye(n);
    for i = 1:n,
        for j = 1:n,
            if i > j,
               Li(i,j) = (1 + (i-j)*B)*a; 
            end
        end
    end
end

