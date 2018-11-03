clc;
clear all;
close all;
% {
a1 = imread('A1.jpg');
a2 = imread('A2.jpg');
a3 = imread('A3.jpg');
a4 = imread('A4.jpg');
a5 = imread('A5.jpg');
%}

[height, width] = size(a1);

%% photonetric stereo part
lll = cos(pi/6)*sin(pi/4);
S1 = [0 0 1];
S2 = [lll -lll 0.5];
S3 = [-lll -lll 0.5];
S4 = [lll lll 0.5];
S5 = [-lll lll 0.5];
V1 = 255*[S1;S2;S3;S4;S5];
% 7x3
V2 = 255*[0.1 0 0.995; 
          0.8 0 0.6; 
          0.707 0 0.707; 
          -0.707 0 0.707; 
          0 0.707 0.707; 
          0.56568 0.56568 0.6; 
          -0.56568 0.56568 0.6];

%% compute albedo and normal
for x = 1:1:height
    for y = 1:1:width
        i1 = [a1(x,y) a2(x,y) a3(x,y) a4(x,y) a5(x,y)]';
        [albedo, normal] = findNormal (V1,i1);
        Albedo(x,y) = albedo;
        if (x == 1 || y == 1)
            N(x,y,:) = [0;0;0];
        else
            N(x,y,:)= normal;
        end
        if (normal(3,1) == 0 || x == 1 || y == 1)
            p1(x,y) = 0;
            q1(x,y) = 0;
        else
            p1(x,y) = normal(1,1) / normal(3,1);
            q1(x,y) = normal(2,1) / normal(3,1);
        end
    end 
end
 
%% compute depth of image
x_start = round(height/2) - 60;
y_start = round(width/2) - 60;
error = 0.5;
z = findDepth(height, width, p1, q1, x_start, y_start, error);

figure(1);
for h = 1:20:height
    for w = 1:20:width
         Z = z(h,w);
         N_1 = N(h,w,1);
         N_2 = N(h,w,2);
         N_3 = N(h,w,3);
         quiver3(h, w, Z, -N_2, N_1, N_3, 'LineWidth',1,'LineStyle','-','MaxHeadSize',2,'AutoScaleFactor',20);
         % quiver3(h, w, 0, -N_2, N_1, 0, 'LineWidth',1,'LineStyle','-','MaxHeadSize',2,'AutoScaleFactor',20);
         hold on;
    end
end   

figure(2);surf(1:10:height,1:10:width,z(1:10:height,1:10:width));
figure(3);surf(z',a1','edgecolor','none','FaceColor','texturemap');

%% show results
figure(4);
alb = cat(3, Albedo, Albedo, Albedo);
norm = cat(3, N(:,:,1), N(:,:,2), N(:,:,3));
B_an = alb.*norm;
B_vec = reshape(B_an, height * width, 3);
circle = zeros(height, width, 3);
count = 1;
video = VideoWriter('circle.avi');
open(video);
theta11 = 0;
theta12 = pi/2;
bb = pi/8;
phi11 = 0;
phi12 = 2 * pi; 
aa = pi/16; 
for theta = theta11:bb:theta12
    for phi = phi11:aa:phi12
        S12 = 255 * [cos(phi)*sin(theta) sin(theta)*sin(phi) cos(theta)]';
        b12 = max(B_vec * S12,0);
        temp_mat = reshape(b12, height, width);
        circle = cat(3, reshape(b12, height,width),reshape(b12, height, width), reshape(b12, height, width));
        imshow(uint8(circle));
        X1_set{count} = temp_mat;
        count = count + 1;
        writeVideo(video, uint8(temp_mat));    
    end
end
image_tensor = cat(3, X1_set{:});
close(video);
