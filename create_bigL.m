function [L] = create_bigL(theta, n)
    p = size(theta,1);
    L = zeros(n*p, n*p);
    for i = 1:p,
        a = theta(i,1);
        B = theta(i,2);
        lb = n*(i-1) + 1;
        rb = n*i;
        L(lb:rb, lb:rb) = create_littleL(a, B, n);
    end
end

