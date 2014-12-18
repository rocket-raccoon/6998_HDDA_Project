%Keep updating theta via gradient descent until convergence
function [ theta ] = theta_update( theta, omega, Y, eta, epsilon )

    %Set parameters for algorithm
    iters = 0;
    maxIters = 1000;
    [n,p] = size(Y);
    
    %Iterate on theta until convergence
    while(1),
        
        %Take a gradient step in theta
        [bigL, bigM, psi, A, b] = get_matrices(theta, omega, n, p, Y);
        theta_new = theta_step(theta, bigL, bigM, Y, omega, eta);
        theta_new = project_to_unit_box(theta_new)
        
        %Check for convergence
        iters = iters + 1;
        if norm(theta_new - theta) < epsilon,
            theta = theta_new;
            break;
        end
        if iters == maxIters,
            theta = theta_new;
            break;
        end
        theta = theta_new;
    end

end

