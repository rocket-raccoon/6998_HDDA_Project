%Our results with theta and omega optimization
function [omega, theta, returns, CI, obj_vals, times] = test2(Y, lambda, eta)
    
    times = 0;
    
    Y = log(Y(2:end, :)) - log(Y(1:(end-1), :));
   
    [n, p] = size(Y);
    
    %Initialize guesses for parameters
    epsilon = .1;
%     eta = .1;
    omega = eye(p);
    theta = .5*ones(p,2);
    obj_vals = [];
    iter = 0;
    maxIters = 20;
    final_res = zeros(n*p,1);
    
    %Iterate until convergence
    while(1),
        
%         fprintf(1,'Iteration: %g\n', iter);
        
        theta = .5*ones(p,2);
        
        tic;
        %Update theta
        theta_new = theta_update(theta, omega, Y, eta, epsilon);
        [bigL, bigM, psi, A, b] = get_matrices(theta_new, omega, n, p, Y);
        obj_val1 = norm(A*vec(omega)-b,'fro');
        
        %Ensure direction isn't going crazy after theta update
        if exist('obj_val2','var')==1 && abs(obj_val2-obj_val1)>obj_val2,
            break;
        else
            obj_vals = [obj_vals obj_val1];
        end
        
        fprintf('Updated theta: %3.3fs\n', toc/1000);
        
        tic
        fprintf('Computing Omega..');
        
        %Iterate on omega until convergence
        omega_new = update_omega(A,b,lambda);
        obj_val2 = norm(A*vec(omega_new)-b,'fro');

        %Ensure direction isn't going crazy after omega update
        if abs(obj_val2-obj_val1)>obj_val1,
            break;
        else,
         obj_vals = [obj_vals obj_val2];
         theta = theta_new;
        end
        
        omega_new = vec2mat(omega_new, p);
        fprintf('\nOmega computed: %3.3fs \n', toc/1000);
        
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
        lambda = lambda * 10;
        
    end
    
    % Plot predictions
    returns = forecast_time_series(omega, theta, Y*omega, 1, lambda)'*inv(omega);    
    
    [bigL, bigM, psi, A, b] = get_matrices(theta_new, omega, n, p, Y);
    epsilon=A*vec(omega)-b;
    
    devs = std(epsilon); % keep devs for CI

    ub = returns(:)+(devs(:)./2);
    lb = returns(:)+(devs(:)./2);
    
    CI = [lb(:), ub(:)];
%     figure
%     plot(VP)
%     
%     times = [Y*omega; predictions'];
%     figure
%     plot(times)
%     
%     times2 = [Y; predictions'/omega];
%     figure
%     plot(times2)
%     
%     figure
%     imagesc(eye(p)-omega)
% 
%     figure
%     errorbar_groups(predictions'/omega,((2*eye(p)-abs(omega))*sqrt(var(Y)'))');
    
end

