function c=simulation_algorithm(Y, k)
    c = zeros(k);
    for i=1:k
        for j=1:k
            para=Y;
            [ao,bo] = fmincon(@(a,b)theta_density(a, b,para), [0, 0], [],[],[],[],[i/k, j/k]-1/k, [i/k, j/k]);
            c(i,j) = -1*theta_density(ao,bo, Y);
        end
    end
end