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
        size(bigL)
        %Create Big M
        littleM = create_littleM(n);
        bigM = create_bigM(littleM, p);
        size(bigM)
        %Create Psi
        X = inv(bigL)*bigM;
        size(X)
        Yhat = (inv(bigL)*vec(Y*omega));
        size(Yhat)
        psi = inv(X'*X)*X'*Yhat;
        size(psi)
        %Update omega
        A = inv(bigL)*kron(eye(p),Y);
        b = inv(bigL)*bigM*psi;
        omega_new = LassoBlockCoordinate(A, b, lambda);
        omega_new
        break;
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

