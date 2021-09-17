function final = myInpainter(X,mask,iterations,t,window_size)
    X = double(X);
    final = X.*((1-mask));
    final = double(final);
    %window_size = 15;
    for iter = 1:iterations
        imx = X;
        imy = X;
        [imx(:,:,1), imy(:,:,1)] = imgradientxy(final(:,:,1),'sobel');
        [imx(:,:,2), imy(:,:,2)] = imgradientxy(final(:,:,2),'sobel');
        [imx(:,:,3), imy(:,:,3)] = imgradientxy(final(:,:,3),'sobel');
        gauss = fspecial('gaussian',3,1);
        for i = 1:size(X,1)
            for j = 1:size(X,2)
                if(mask(i,j)==1)
                    w = floor(window_size/2);
                    
                    imrxx = imx(i,j,1)*imx(i,j,1);
                    imrxy = imx(i,j,1)*imy(i,j,1);
                    imryy = imy(i,j,1)*imy(i,j,1);
                    imbxx = imx(i,j,2)*imx(i,j,2);
                    imbxy = imx(i,j,2)*imy(i,j,2);
                    imbyy = imy(i,j,2)*imy(i,j,2);
                    imgxx = imx(i,j,3)*imx(i,j,3);
                    imgxy = imx(i,j,3)*imy(i,j,3);
                    imgyy = imy(i,j,3)*imy(i,j,3);
                    

                    ixx = (imrxx+imbxx+imgxx);
                    ixy = (imrxy+imbxy+imgxy);
                    iyy = (imryy+imbyy+imgyy);
                    
                    G = [ixx ixy; ixy iyy];
                    G = imfilter(G,gauss);
                    [V, D] = eig(G);
                    [D,I] = sort(diag(D));
                    D = flip(D);
                    D = diag(D);
                    V =  V(:, flip(I));
                    thieta_plus = V(:,1);
                    thieta_minus = V(:,2);
                    lambda_plus = D(1,1);
                    lambda_minus = D(2,2);
                    T = (1/sqrt(1+(lambda_plus+lambda_minus)))*(thieta_minus*thieta_minus');
                    T = T + (1/(1+(lambda_plus+lambda_minus)))*(thieta_plus*thieta_plus');
                    T = inv(T);
                    for z = 1:3
                        temp=0;
                        temp2=0;
                    for k = max(i-w,1):min(i+w,size(X,1))
                        for k1 = max(j-w,1):min(j+w,size(X,2))
%                             if(k~=i && k1~=j)
                            x = [k-i;k1-j];
                            temp2 = temp2 + (exp(-1*(x'*T*x)/(4*t))*final(k,k1,z));
                            if(final(k,k1,z)~=0)
                            temp = temp + (exp(-1*(x'*T*x)/(4*t)));
                            end
%                             end
                        end
                    end
                        if(temp>0)
                         final(i,j,z)=temp2/temp;
                        end
                    end
                end
            end
        end
    end             
end