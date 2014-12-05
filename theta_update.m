function new_theta = theta_update(theta, bigL, bigM, Y, omega, eta)

[n, p] = size(Y);

A = ones(n);
delta = A - triu(A);

gamma = zeros(n,n);
for i=1:n
    for j=1:n
        gamma(i,j) = i - j;
    end
end
gamma = gamma - triu(gamma);

grad = zeros(p,2);

for i = 1:p
    for k = 1:2

        bigLinv = bigL^(-1);

        X = bigLinv*bigM;

        kron_multiplier = zeros(p,p);
        kron_multiplier(i,i) = 1;
        
        if k == 1
            diff_bigL = kron(kron_multiplier,delta)+kron(theta(i,2)*kron_multiplier,gamma);
        else
            diff_bigL = kron(theta(i,1)*kron_multiplier,gamma);
        end

        
        
        diff_X = - bigLinv^2*diff_bigL*bigM;

        a = X*(X'*X)^(-1)*X';
        diff_a = -2*X*(X'*X)^(-2)*X'*diff_X*X' + X*(X'*X)^(-1)*diff_X' + diff_X * (X'*X)^(-1)*X';

        A = bigLinv*vec(Y*omega) - a * bigLinv*vec(Y*omega);
        diff_A = - diff_a * bigLinv * vec(Y*omega) - bigLinv^(2)*diff_bigL*vec(Y*omega) + a * bigLinv^(2)*diff_bigL*vec(Y*omega);

        grad(i,k) = 2 * A' * diff_A;
        
    end
end

new_theta = theta - eta*grad;
