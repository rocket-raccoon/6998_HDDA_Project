function [ omega, theta ] = run_algorithm(file_path, lambda)
    %Get the Y matrix and associated dimensions
    %Y = csvread(file_path,1,1);
    Y = csvread(file_path, 1,1, [1 1 10 20]);
    [n, p] = size(Y);
    %Initialize guesses for parameters
    omega = eye(p);
    omega_new = omega;
    theta = .5.*ones(p,2);
    theta_new = theta;
    %Iterate until convergence
    while(1)
        %Create Big L
        bigL = create_bigL(theta,n);
        %Create Big M
        littleM = create_littleM(n);
        bigM = create_bigM(littleM, p);
        %Create Psi
        X = inv(bigL)*bigM;
        Yhat = (inv(bigL)*vec(Y*omega));
        psi = inv(X'*X)*X'*Yhat;
        %Update omega
        A = inv(bigL)*kron(eye(p),Y);
        b = inv(bigL)*bigM*psi;
        omega_new = LassoBlockCoordinate(A, b, lambda);
        %Update theta
        eta = .1;
        theta = update_theta(theta, bigL, bigM, Y, omega, eta);
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




