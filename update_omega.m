function [ x ] = update_omega( A, b, lambda )

epsilon = 0.01;
p = size(A,2);
x = zeros(p, 1);
set_to_one = [1:sqrt(p)+1:sqrt(p)^2];
for i = set_to_one,
   x(i)=1; 
end
itr_values = setdiff([1:sqrt(p)^2], [1:sqrt(p)+1:sqrt(p)^2]);
iter = 0;
maxIters = 100;

%Iterate until convergence
keep_itr = true;
while keep_itr,
    new_x = x;
    %for j = 1:p
    for j = itr_values,
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
        %Save update weight vector and objective value
        obj_val = .5*(norm(b-A*new_x)^2) + lambda*norm(new_x, 1)
    end
    %Check whether or not to keep iterating
    if norm(x - new_x,'fro') <= epsilon
       keep_itr = false; 
    end
    x = new_x;
    obj_val = .5*(norm(b-A*x)^2) + lambda*norm(x, 1);
end

end

