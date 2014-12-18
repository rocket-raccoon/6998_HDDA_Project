%This function is purely to test whether the theta optimization on it's own
%Is working
function [ omega, theta, final_res, obj_vals, times ] = test1(file_path, lambda, simulateData)

    %Get the Y matrix and associated dimensions
    if simulateData == 0,
        Y = simulate_data(25, 2,1000);
        Y=Y/norm(Y,'fro')
    else
        Y = csvread(file_path, 1,1, [1 1 5 10]);
    end
    [n,p] = size(Y);

    %Initialize guesses for parameters
    epsilon = .0001;
    eta = .005;
    omega = eye(p);
    theta = .5*ones(p,2);
    obj_vals = [];
    iters = 0;
    maxIters = 100;
    final_res = zeros(n*p,1);

    %Iterate until convergence
    while(1),

        %Record current objective value
        [bigL, bigM, psi, A, b] = get_matrices(theta, omega, n, p, Y);
        obj_val = norm(A*vec(omega)-b,'fro');
        obj_val
        obj_vals = [obj_vals obj_val];

        %Update theta
        theta_new = theta_step(theta, bigL, bigM, Y, omega, eta);
        theta_new = project_to_unit_box(theta_new);

        %Check for convergence
        if norm(theta_new - theta) < epsilon,
            theta = theta_new;
            break;
        end
        iters = iters + 1;
        if iters == maxIters,
            theta = theta_new;
            break;
        end
        theta = theta_new;
    end

    [bigL, bigM, psi, Aomega, bomega] = get_matrices2(theta, omega, n, p, Y)
    
    omeganew = update_omega(Aomega,bomega,lambda);
    epsilon=Aomega*(vec(vec2mat(omeganew,p)-eye(p)))-bomega
    obj_vals = [obj_vals norm(epsilon,'fro')];
    plot(obj_vals)
    spy(vec2mat(omeganew,p))
    vec2mat(omeganew,p)

    %Plot predictions
    predictions = forecast_time_series(omega, theta, Y*omega, 3, .10, final_res);
    times = [Y; predictions'];
    plot(times)

end

