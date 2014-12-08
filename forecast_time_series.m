function [P] = forecast_time_series(omega, theta, Y, q, a, res)
    
    %Get dimensions from observed time series Y
    [n,p] = size(Y);
    
    %Initialize P
    P = zeros(q*p,1);
    
    %Create M1 and M2
    littleM = create_littleM(n+q);
    littleM1 = littleM(1:n,:);
    littleM2 = littleM(n+1:n+q,:);
    M1 = create_bigM(littleM1, p);
    M2 = create_bigM(littleM2, p);
    
    %Calculate psi
    bigL = create_bigL(theta, n);
    X = inv(bigL)*M1;
    Yhat = (inv(bigL)*vec(Y*omega));
    psi = inv(X'*X)*X'*Yhat;
    psi = vec2mat(psi, p);
    
    %Create L1, L21 and L2
    L1 = zeros(n*p, n*p);
    L21 = zeros(q*p, n*p);
    L2 = zeros(q*p, q*p);
    for i = 1:p,
       %Grab the current alpha and beta
       alpha = theta(i,1);
       beta = theta(i,2);
       %Create the ith components of the L1,L21,L2 matrices
       Li = create_littleL(alpha, beta, n+q);
       L1i = Li(1:n,1:n);
       L21i = Li(n+1:n+q, 1:n);
       L2i = Li(n+1:n+q, n+1:n+q);
       
       ei = inv(L1i)*(Y(:,i)-littleM1*psi(:,i));
       pi = littleM2*psi(:,i) + L21i*ei;
       P((i-1)*q+1:i*q, 1) = pi;
       
       %Insert the ith components into the larger L1,L21,L2 matrices
       %L1(n*(i-1)+1:n*i, n*(i-1)+1:n*i) = L1i;
       %L21(q*(i-1)+1:q*i, n*(i-1)+1:n*i) = L21i;
       %L2(q*(i-1)+1:q*i, q*(i-1)+1:q*i) = L2i;
    end
    
    P = inv(omega)*vec2mat(P,q);
    
    %Forecast the data out for q time points into the future
    %vec_Ynew = inv(kron(omega, eye(q)))*(M2*vec(psi) + L21*inv(L1)*(vec(Y)-M1*vec(psi)));
    %Ynew = vec2mat(vec_Ynew', p);
    
    %Get the confidence interval (lower bound and right bound)
    %[lb, ub] = get_bounds(res, a, p, q);
    
    %vec_Ynew_lb = inv(kron(omega, eye(q)))*(M2*vec(psi) + L21*inv(L1)*(vec(Y)-M1*vec(psi)) + L2*vec(lb));
    %Ynew_lb = vec2mat(vec_Ynew_lb', p);
    %vec_Ynew_ub = inv(kron(omega, eye(q)))*(M2*vec(psi) + L21*inv(L1)*(vec(Y)-M1*vec(psi)) + L2*vec(ub));
    %Ynew_ub = vec2mat(vec_Ynew_ub', p);
    
end






