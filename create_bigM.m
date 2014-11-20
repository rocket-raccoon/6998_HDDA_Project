function [ M ] = create_bigM( m, p )
    M = kron(eye(p), m);
end

