function dtheta = theta_density(Y, a, b)
n = size(Y, 1);
X  = create_littleX(a,b,n);
L  = create_littleL(a,b,n);
PX = create_px(X);
dtheta = -1*(det(X'*X)^(-.5)*((inv(L)*Y)'*(eye(size(PX, 1))-PX)*inv(L)*Y)^(.5*(n-1))); % p=0
end