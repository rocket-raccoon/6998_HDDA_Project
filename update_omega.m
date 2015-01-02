function [ x ] = update_omega( A, b, lambda )

epsilon = 0.05;
maxIters = 100;

p = size(A,2);
x = zeros(p, 1);
set_to_one = [1:sqrt(p)+1:sqrt(p)^2];
for i = set_to_one,
   x(i)=1; 
end
itr_values = setdiff([1:sqrt(p)^2], [1:sqrt(p)+1:sqrt(p)^2]);

%Iterate until convergence
keep_itr = true;
iter = 0;
while keep_itr,
    iter = iter+1;
    new_x = x;
    %for j = 1:p
    cou = 0;
    for j = itr_values,
        cou = cou+1;
        %Calculate the residual
        if j ~= 1 && j ~= p
            r = A(:, 1:j-1)*new_x(1:j-1,1) + A(:, j+1:end)*new_x(j+1:end,1) - b;
        elseif j == 1
            r = A(:, 2:end)*new_x(2:end,1) - b;
        elseif j == p
            r = A(:, 1:end-1)*new_x(1:end-1,1) - b; 
        end
        top = transpose(A(:,j))*r;
        %Calculate the soft thresholding
        if top > lambda
           new_x(j) = (-top + lambda) / norm(A(:,j))^2; 
        elseif top < -lambda
           new_x(j) = (-top - lambda) / norm(A(:,j))^2;
        elseif top >= -lambda && top <= lambda
           new_x(j) = 0;
        end
        if (~mod(cou, 20))
            fprintf(1,'.');
        end
    end
    % Print objective value
    obj_val = .5*(norm(b-A*new_x)^2) + lambda*norm(new_x, 1);
    fprintf(1, '%3.5f', obj_val );
    
    %Check whether or not to keep iterating
    if norm(x - new_x,'fro') <= epsilon || iter >= maxIters
       keep_itr = false; 
    end
    x = new_x;
    obj_val = .5*(norm(b-A*x)^2) + lambda*norm(x, 1);
end

end

