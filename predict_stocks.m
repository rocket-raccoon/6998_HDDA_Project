function [Y_new, LB, UP]=predict_stocks(Y, lambda, k)
m = (1/k)*sum(Y(end-k:end, :) - Y((end-k:end)-1, :));
Y_new = Y(end, :) + m;
UP = Y_new;
LB = UP;
end