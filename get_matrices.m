function [ bigL, bigM, psi, A, b ] = get_matrices(theta, omega, n, p, Y)
        
        %Create Big L
        bigL = create_bigL(theta,n);
        
        %Create Big M
        littleM = create_littleM(n);
        bigM = create_bigM(littleM, p);
        
        %Create Psi
        X = inv(bigL)*bigM;
        Yhat = (inv(bigL)*vec(Y*omega));
        psi = inv(X'*X)*X'*Yhat;
        
        %Create A and b
        A = inv(bigL)*kron(eye(p),Y);
        b = inv(bigL)*bigM*psi;

end

