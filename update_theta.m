function new_theta = update_theta(theta, bigL, bigM, Y, omega, eta)

% eta is the step size for the theta update

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


syms x
syms y

for i = 1:p
    
    i
    kron_multiplier = zeros(p,p);
    kron_multiplier(i,i) = 1;
    big_delta = kron(kron_multiplier, delta);
    big_gamma = kron(kron_multiplier, gamma);
    1
    %update alpha i and beta i;
    
    clear L_a L_b L_ainv
    
    L_a(x) = bigL + x * (big_delta + theta(i,2)*big_gamma);
    L_b(y) = bigL + y  * theta(i,1) * big_gamma;
    2
    
    size(L_a(x))
    size(L_b(y))
    size(L_a)
    size(L_b)
    L_ainv = inv(L_a);
    L_binv = inv(L_b);
    
    3
        
    na = norm((L_ainv - bigM*((L_ainv*bigM)'*(L_ainv*bigM))^(-1)*(L_ainv*bigM)'*L_ainv )*vec(Y*omega))^2;
    nb = norm((L_binv - bigM*((L_binv*bigM)'*(L_binv*bigM))^(-1)*(L_binv*bigM)'*L_binv )*vec(Y*omega))^2;
    4
    
    d_L_a = diff(na, x);
    d_L_b = diff(nb, y);
    5
    
    grad(i,1) = d_L_a(0);
    grad(i,2) = d_L_b(0);
    6
end

new_theta = theta - eta * grad;
    
    
    
    