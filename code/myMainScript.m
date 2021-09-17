%% MyMainScript

tic;

%% Reading Images
path1 = "..\data\glassesl.png";
path2 = "..\data\greenparrot_orig.png";
path3 = "..\data\greenparrotmask.png";
path4 = "..\data\glassesmask.png";
path5 = "..\data\lena_text.png";
path6 = "..\data\lena_text_mask.png";
path7 = "..\data\scott_bryson.png";
path8 = "..\data\lena.jpg";

glasses = imread(path1);
mask_glasses = imread(path4);
greenparrot = imread(path2);
mask_greenparrot = imread(path3);
lena = imread(path5);
mask_lena = imread(path6);
scott = imread(path7);
lena2 = imread(path8);


%% Creating Masks
mask_glasses_new = zeros(size(mask_glasses,1),size(mask_glasses,2));
for i = 1:size(mask_glasses,1)
    for j = 1:size(mask_glasses,2)
        if(mask_glasses(i,j,1)==255 && mask_glasses(i,j,2)==255 && mask_glasses(i,j,3)==255)
            mask_glasses_new(i,j)=1;
        end
    end
end
mask_glasses_new = double(mask_glasses_new);

mask_greenparrot_new = zeros(size(mask_greenparrot,1),size(mask_greenparrot,2));
for i = 1:size(mask_greenparrot,1)
    for j = 1:size(mask_greenparrot,2)
        if(mask_greenparrot(i,j,1)==255 && mask_greenparrot(i,j,2)==255 && mask_greenparrot(i,j,3)==255)
            mask_greenparrot_new(i,j)=1;
        end
    end
end
mask_greenparrot_new= double(mask_greenparrot_new);

mask_lena_new = zeros(size(mask_lena,1),size(mask_lena,2));
for i = 1:size(mask_lena,1)
    for j = 1:size(mask_lena,2)
        if(mask_lena(i,j,1)>=240 && mask_lena(i,j,2)>=240 && mask_lena(i,j,3)>=240)
            mask_lena_new(i,j)=1;
        end
    end
end

mask_lena_new= double(mask_lena_new);

mask_scott_new = zeros(size(scott,1),size(scott,2));
for i = 1:size(scott,1)
    for j = 1:size(scott,2)
        if(mod(i,2)==mod(j,2))
            mask_scott_new(i,j) = 1;
        end
    end
end

mask_scott_new= double(mask_scott_new);

mask_lena_new2 = zeros(size(lena,1),size(lena,2));
for i = 1:size(lena,1)
    for j = 1:size(lena,2)
        if(mod(i,2)==mod(j,2))
            mask_lena_new2(i,j) = 1;
        end
    end
end

mask_lena_new2= double(mask_lena_new2);
%% Greenparrot inpainting + little smoothening on the inpainted areas edges

final = myInpainter(greenparrot,mask_greenparrot_new,3,100,11);
final = uint8(final);

filter = fspecial('gaussian',5,3);
final = double(final);
final2 = final;
for i = 2:size(final,1)-1
    for j = 2:size(final,2)-1
        if(mask_greenparrot_new(i,j+1)||mask_greenparrot_new(i+1,j+1)||mask_greenparrot_new(i-1,j+1)||mask_greenparrot_new(i,j)||mask_greenparrot_new(i+1,j)||mask_greenparrot_new(i-1,j)||mask_greenparrot_new(i,j-1)||mask_greenparrot_new(i+1,j-1)||mask_greenparrot_new(i-1,j-1))
            w = floor(size(filter,1)/2);
            
            for z = 1:3
                temp=0;
                temp2=0;
                for k = max(i-w,1):min(i+w,size(final,1))
                    for k1 = max(j-w,1):min(j+w,size(final,2))
                        if(k~=i && k1~=j)
                        temp2 = temp2 + filter(k-i+w+1,k1-j+w+1)*final(k,k1,z);
                        if(final(k,k1,z)~=0)
                            temp = temp + filter(k-i+w+1,k1-j+w+1);
                        end
                        end
                    end
                end
                if(temp>0)
                    final2(i,j,z)=temp2/temp;
                end
            end
        end
    end
end

figure ; subplot(1,4,1) ; imshow(uint8(greenparrot)) ; subplot(1,4,2) ; imshow(uint8(mask_greenparrot)); subplot(1,4,3) ; imshow(uint8(final));
subplot(1,4,4); imshow(uint8(final2));

%% Boy's spectacle inpainting + little smoothening on the inpainted areas edges

final = myInpainter(glasses,mask_glasses_new,3,100,5);
final = uint8(final);
filter = fspecial('gaussian',5,3);
final = double(final);
final2 = final;
for i = 2:size(final,1)-1
    for j = 2:size(final,2)-1
        if(mask_glasses_new(i,j+1)||mask_glasses_new(i+1,j+1)||mask_glasses_new(i-1,j+1)||mask_glasses_new(i,j)||mask_glasses_new(i+1,j)||mask_glasses_new(i-1,j)||mask_glasses_new(i,j-1)||mask_glasses_new(i+1,j-1)||mask_glasses_new(i-1,j-1))
            w = floor(size(filter,1)/2);
            
            for z = 1:3
                temp=0;
                temp2=0;
                for k = max(i-w,1):min(i+w,size(final,1))
                    for k1 = max(j-w,1):min(j+w,size(final,2))
                        if(k~=i && k1~=j)
                        temp2 = temp2 + filter(k-i+w+1,k1-j+w+1)*final(k,k1,z);
                        if(final(k,k1,z)~=0)
                            temp = temp + filter(k-i+w+1,k1-j+w+1);
                        end
                        end
                    end
                end
                if(temp>0)
                    final2(i,j,z)=temp2/temp;
                end
            end
        end
    end
end

figure ; subplot(1,4,1) ; imshow(uint8(glasses)) ; subplot(1,4,2) ; imshow(uint8(mask_glasses)); subplot(1,4,3) ; imshow(uint8(final));
subplot(1,4,4); imshow(uint8(final2));

%% Lena text inpainting

final = myInpainter(lena,mask_lena_new,3,100,11);
final = uint8(final);
figure ; subplot(1,3,1) ; imshow(uint8(lena)) ; subplot(1,3,2) ; imshow(uint8(mask_lena)); subplot(1,3,3) ; imshow(uint8(final));

%% Scott image restoration

final = myInpainter(scott,mask_scott_new,10,1000,11);
final = uint8(final);

scott = double(scott);
scott_masked = scott.*((1-mask_scott_new));
scott_masked = uint8(scott_masked);

figure ; subplot(1,3,1) ; imshow(uint8(scott)) ; subplot(1,3,2) ; imshow(uint8(scott_masked)); subplot(1,3,3) ; imshow(uint8(final));
fprintf("SSIM of the final inpainted image and the original image = %4f\n",ssim(double(final),scott));

%% Lena image restoration

final = myInpainter(lena2,mask_lena_new2,10,1000,11);
final = uint8(final);

lena2 = double(lena2);
lena_masked = lena2.*((1-mask_lena_new2));
lena_masked = uint8(lena_masked);

figure ; subplot(1,3,1) ; imshow(uint8(lena2)) ; subplot(1,3,2) ; imshow(uint8(lena_masked)); subplot(1,3,3) ; imshow(uint8(final));
fprintf("SSIM of the final inpainted image and the original image = %4f\n",ssim(double(final),lena2));


toc;
