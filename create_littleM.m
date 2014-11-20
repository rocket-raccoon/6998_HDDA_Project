function [ m ] = create_littleM( n )
    m = zeros(n,2);
    for i = 1:n,
        m(i,:) = [1 i];
    end
end

