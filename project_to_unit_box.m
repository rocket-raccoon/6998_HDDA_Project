function [ theta ] = project_to_unit_box( theta )
    [d1, d2] = size(theta);
    for i = 1:d1,
       alpha = theta(i,1);
       beta = theta(i,2);
       %Clamp the alpha value
       if alpha < 0,
          alpha = 0; 
       elseif alpha > 1,
          alpha = 1;
       end
       %Clamp the beta value
       if beta < 0,
           beta = 0;
       elseif beta > 1,
           beta = 1;
       end
       %Update theta
       theta(i,:) = [alpha beta];
    end
end

