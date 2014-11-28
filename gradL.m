% Computes the gradiet of L which is an npXnp matrix 
% each nXn block along the diagonal is a lower triangular matrix
% given by (1+(i-j)b)a for each block
function dL=gradL(n,p, a, b)
i_all = [];
j_all = [];
for k=1:p
    [i,j,s] = find(tril(ones(n,n)));
    LkAk = 1+((i-j).*b(k));
    LkBk = ((i-j).*a(k));
    i_all = [i_all;i+max(i_all+1);i+max(i_all+n+1)];
    j_all = [j_all;j+max(j_all+1);j+max(j_all+1)];
    s_all = [LkAk;LkBk];
end
dL = sparse(i_all,j_all,s_all);
end