%Our results with theta and omega optimization
function [omega, theta, final_res, obj_vals, times] = test2(Y, lambda, simulateData)
    
    %Get the Y matrix and associated dimensions
    if simulateData == 0,
        Y = simulate_data(25, 2, 11);
        
    end
    [n, p] = size(Y);
    
    %Initialize guesses for parameters
    epsilon = .1;
    eta = .1;
    omega = eye(p);
    theta = .5*ones(p,2);
    obj_vals = [];
    iter = 0;
    maxIters = 20;
    final_res = zeros(n*p,1);
    
    %Iterate until convergence
    while(1),
        
        iter
        
        theta = .5*ones(p,2);
        
        %Update theta
        theta_new = theta_update(theta, omega, Y, eta, epsilon)
        [bigL, bigM, psi, A, b] = get_matrices(theta_new, omega, n, p, Y);
        obj_val1 = norm(A*vec(omega)-b,'fro')
        
        if exist('obj_val2','var')==1 && abs(obj_val2-obj_val1)>obj_val2,
            break;
        else
            obj_vals = [obj_vals obj_val1];
        end
        
        'Updated theta'
        
        %Iterate on omega until convergence
        omega_new = update_omega(A,b,lambda);
        obj_val2 = norm(A*vec(omega_new)-b,'fro')
        if abs(obj_val2-obj_val1)>obj_val1,
            break;
        else,
         obj_vals = [obj_vals obj_val2];
         theta = theta_new

        end
        
        omega_new = vec2mat(omega_new, p);
        'updated omega'
        
        %Check for convergence
        if norm(theta_new-theta)<epsilon && norm(omega_new-omega)<epsilon,
            omega = omega_new;
            theta = theta_new;
            break;
        end
        
        %Break if max iterations has been reached
        iter = iter + 1;
        
        %Bring the new omega, theta values forwards
        omega = omega_new;
        theta = theta_new;
        lambda=lambda*10
        
        %predictions = forecast_time_series(omega, theta, Y*omega, 10, .10, final_res,lambda);
        %times = [Y; predictions'];
        %figure
        %plot(times)

        %figure
        %plot(obj_vals)
        
    end
    
    %Plot predictions
    predictions = forecast_time_series(omega, theta, Y*omega, 1, lambda);
    VP=forecast_time_series(omega, theta, Y*omega, 1,lambda)
    
    figure
    plot(VP)
    
    times = [Y*omega; predictions'];
    figure
    plot(times)
    
    times2 = [Y; predictions'/omega];
    figure
    plot(times2)
    
    figure
    imagesc(eye(p)-omega)

    figure
    errorbar_groups(predictions'/omega,((2*eye(p)-abs(omega))*sqrt(var(Y)'))');

    %figure
    %errorbar_groups(predictions',sqrt(var(Y*omega)));
    %errorbar_groups(predictions',predictions'-quantile(Y,0.1),predictions'+quantile(Y,0.90));

    
    %figure
    %plot(Y)

   % figure
   % Yfinal=Y*omega
    %plot(Yfinal)
end

