function [ omega, theta, final_res ] = run_algorithm(file_path, lambda)
    
    %Get the Y matrix and associated dimensions
    %Y = csvread(file_path, 1,1, [1 1 5 10]);
    %Y = csvread(file_path, 1, 1, [1 1 10 40]);
    Y = simulate_data(5, 10, 1);
    [n, p] = size(Y);
    
    %Initialize guesses for parameters
    epsilon = .01;
    omega = eye(p);
    omega_new = omega;
    theta = 1*ones(p,2);
    theta_new = theta;
    obj_vals = [];
    counter = 0;
    final_res = zeros(n*p,1);
    
    %Start by getting an initial value for theta
    bigL = create_bigL(theta,n);
    littleM = create_littleM(n);
    bigM = create_bigM(littleM, p);
    eta = .1;
    theta = theta_update(theta, bigL, bigM, Y, omega_new, eta);
    theta
    theta = project_to_unit_box(theta);
    theta_new = theta;
    
    %Iterate until convergence
    while(1),
        
        %Create Big L
        bigL = create_bigL(theta,n);
        
        %Create Big M
        littleM = create_littleM(n);
        bigM = create_bigM(littleM, p);
        
        %Create Psi
        X = inv(bigL)*bigM;
        Yhat = (inv(bigL)*vec(Y*omega));
        psi = inv(X'*X)*X'*Yhat;
        
        %Create A and b
        A = inv(bigL)*kron(eye(p),Y);
        b = inv(bigL)*bigM*psi;
        
        %Get new objective function value
        obj_val = norm(A*vec(omega)-b,'fro')+lambda*norm(vec(omega),1);
        obj_vals = [obj_vals obj_val];
        
        %Update omega
        %omega_new = update_omega(A,b,lambda);
        %omega_new = LassoBlockCoordinate(A, b, lambda, 'verbose', 0);
        %omega_new = vec2mat(omega_new, p);
        %obj_val = norm(A*vec(omega_new)-b,'fro')+lambda*norm(vec(omega_new),1)
        %'update omega'
        
        %Update theta
        theta_new = theta_update(theta, bigL, bigM, Y, omega_new, eta);
        theta_new = project_to_unit_box(theta_new);
        'updated theta'
        
        %Check for convergence
        if norm(theta_new-theta) < epsilon, %&& norm(omega_new-omega) < epsilon,
            omega = omega_new;
            theta = theta_new;
            final_res = A*vec(omega_new)-b;
            break; 
        else
           omega = omega_new;
           theta = theta_new;
        end
        counter = counter + 1;
        if counter == 10,
           omega = omega_new;
           theta = theta_new;
           final_res = A*vec(omega_new)-b;
           break; 
        end
    end
    
    plot(obj_vals)
    
    predictions = forecast_time_series(omega, theta, Y, 2, .10, final_res);
    size(predictions)
    plot([Y; predictions'])
    
end




