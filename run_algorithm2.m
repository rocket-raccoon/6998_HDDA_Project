function [ omega, theta, final_res, obj_vals ] = run_algorithm2(file_path, lambda, suppress_lasso, simulateData)
    
    %Get the Y matrix and associated dimensions
    if simulateData == 0,
        Y = simulate_data(15, 5, 100);
    else
        Y = csvread(file_path, 1,1, [1 1 5 10]);
    end
    [n, p] = size(Y);
    
    %Initialize guesses for parameters
    epsilon = .01;
    eta = .001;
    omega = eye(p);
    theta = .5*ones(p,2);
    obj_vals = [];
    iter = 0;
    maxIters = 10;
    final_res = zeros(n*p,1);
    
    %Iterate until convergence
    while(1),
        
        %Record current objective value
        [bigL, bigM, psi, A, b] = get_matrices(theta, omega, n, p, Y);
        obj_val = norm(A*vec(omega)-b,'fro')+lambda*norm(vec(omega),1);
        obj_vals = [obj_vals obj_val];
        
        %Update theta
        theta_new = theta_update(theta, omega, Y, eta, epsilon);
        
        %Iterate on omega until convergence
        [bigL, bigM, psi, A, b] = get_matrices(theta_new, omega, n, p, Y);
        omega_new = update_omega(A,b,lambda);
        omega_new = vec2mat(omega_new, p);
        
        %Check for convergence
        if norm(theta_new-theta)<epsilon && norm(omega_new-omega)<epsilon,
            omega = omega_new;
            theta = theta_new;
            break;
        end
        
        %Break if max iterations has been reached
        iter = iter + 1;
        if iter == maxIters,
           omega = omega_new;
           theta = theta_new;
           break; 
        end
    end
    
    %Plot predictions
    predictions = forecast_time_series(omega, theta, Y, 2, .10, final_res);
    
end

