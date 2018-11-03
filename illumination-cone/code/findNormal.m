function [albedo,normal] = findNormal(V,i)
%n :# of images
    i = double(i);
    I_diag = diag(i');
    V_ = I_diag * V;
    i_ = I_diag * i;
    if rank(V_' * V_)<3
        g = [0;0;0];
    else 
        g = (V_'*V_)\(V_'*i_);
    end
    
    albedo = norm(g);
    if (albedo == 0)
        normal = [0;0;0];
    else
        normal = g ./ albedo;
    end
end



