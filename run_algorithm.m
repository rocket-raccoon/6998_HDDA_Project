function [ omega, theta, final_res ] = run_algorithm(file_path, lambda, simulateData)
    
    %Get the Y matrix and associated dimensions
    if simulateData == 0,
        Y = simulate_data(5, 10, 1);
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
    itr = 0;
    maxItrs = 10;
    final_res = zeros(n*p,1);
    
    %Iterate until convergence
    while(1),
        
        %Record the current objective value
        [bigL, bigM, psi, A, b] = get_matrices(theta, omega, n, p, Y);
        obj_val = norm(A*vec(omega)-b,'fro')+lambda*norm(vec(omega),1);
        obj_vals = [obj_vals obj_val];
        
        %Update omega
        omega_new = update_omega(A,b,lambda);
        omega_new = vec2mat(omega_new, p);
        
        %Update theta
        [bigL, bigM, psi, A, b] = get_matrices(theta, omega_new, n, p, Y);
        theta_new = theta_update(theta, bigL, bigM, Y, omega_new, eta);
        theta_new = project_to_unit_box(theta_new);
        
        %Check for convergence
        if norm(theta_new-theta) < epsilon && norm(omega_new-omega) < epsilon,
            omega = omega_new;
            theta = theta_new;
            final_res = A*vec(omega_new)-b;
            break;
        end
        
        %Check to see if max iterations has been passed
        itr = itr + 1;
        if itr == maxItrs,
           omega = omega_new;
           theta = theta_new;
           final_res = A*vec(omega_new)-b;
           break; 
        end
        
        %Move forward the current and past theta, omega values
        omega = omega_new;
        theta = theta_new;
    end
    
%     figure;
%     subplot(1,2,1);
%     plot(obj_vals);
%     predictions = forecast_time_series(omega, theta, Y, 3, .10, final_res);
%     size(predictions)
%     A = [Y; predictions'];
%     predictions = predictions';
%     matColors = distinguishable_colors(size(Y, 2));
%     subplot(1,2,2);
%     for stocki=1:size(Y, 2)        
%         plot(1:size(A, 1), A(:, stocki),'-',...
%          'LineWidth', 4,...
%          'markersize', 6,...
%          'Color', matColors(stocki, :)); 
%         hold on;
%         plot((1:size(predictions, 1))+size(Y, 1), predictions(:, stocki),'X',...
%          'LineWidth', 4,...
%          'markersize', 12,...
%          'Color', matColors(stocki, :)); 
%     end
    
    %Plot predictions
    predictions = forecast_time_series(omega, theta, Y, 2, .10, final_res);
    plot([Y; predictions']);
    
end




