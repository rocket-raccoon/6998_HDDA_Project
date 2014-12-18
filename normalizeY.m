Y=load_stock_data()

sizeM=size(Y)
for i = 1:sizeM(2)
colsum = sum(Y(:,i))
Y(:,i) = Y(:,i)*1/colsum
%Y(:,i) = Y(:,i)-Y(1,i)
end