function X=create_littleX(a, B, n)
    X = inv(create_littleL( a, B, n )) * create_littleM( n );
end