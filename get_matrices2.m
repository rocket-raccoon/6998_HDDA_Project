function [ bigL, bigM, psi, Aomega, bomega, epsilon] = get_matrices2(theta, omega, n, p, Y)
        
        %Create Big L
        bigL = create_bigL(theta,n);
        
        %Create Big M
        littleM = create_littleM(n);
        bigM = create_bigM(littleM, p);
        
        %Create Psi
        X = inv(bigL)*bigM;
        Yhat = (inv(bigL)*vec(Y*omega));
        psi = inv(X'*X)*X'*Yhat;
        
        %Create Epsilon
        epsilon=inv(kron(omega',eye(n)))*inv(bigL)*(vec(Y)-bigM*vec(psi));
        epsilon=vec2mat(epsilon,p)
        
        %Create A and b
        Aomega = bigL*kron(eye(p),epsilon);
        bomega = (vec(Y)-bigM*vec(psi));

end
