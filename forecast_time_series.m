function [P] = forecast_time_series(omega, theta, Y, q, lambda)
    
    %Get dimensions from observed time series Y
    [n,p] = size(Y);
    
    %Initialize P
    P = zeros(q*p,1);
    VP= zeros(q*p,1);
    
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
    
    %vega
    vega=abs(n-p);
    
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
       
    end
    
    P = (vec2mat(P,q));
    
end






