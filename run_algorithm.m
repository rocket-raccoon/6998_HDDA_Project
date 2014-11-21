function [ omega, theta ] = run_algorithm(file_path, lambda)
    %Get the Y matrix and associated dimensions
    Y = csvread(file_path,1,1);
    [n, p] = size(Y);
    %Initialize guesses for parameters
    omega = eye(p);
    omega_new = omega;
    theta = rand(p,2);
    theta_new = theta;
    %Iterate until convergence
    while(1)
        %Create Big L
        bigL = create_bigL(theta,n);
        size(bigL)
        size(omega)
        size(Y)
        %Create Big M
        littleM = create_littleM(n);
        bigM = create_bigM(littleM, p);
        %Create Psi
        X = bigM\bigL;
        size(X)
        Yhat = (vec(Y*omega)\bigL)';
        size(Yhat)
        size(X' \ (X'*X))
        psi = X'\(X'*X)*Yhat;
        size(psi)
        %Update omega
        omega_new = LassoBlockCoordinate(Y\bigL, -bigM\bigL*psi, lambda);
        omega_new
        %Update theta
        theta = rand(p,2);
        %Get new objective function value
        obj_val = norm(Y/bigL*omega_new-bigM/bigL*psi,'fro')+lambda*norm(omega_new,1);
        %Check for convergence
        if norm(omega_new-omega) < epsilon && norm(theta_new-theta) < epsilon,
            omega = omega_new;
            theta = theta_new;
            break; 
        end
    end
end

