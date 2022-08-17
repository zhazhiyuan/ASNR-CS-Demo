% =========================================================================
% NCSR for image denoising, Version 1.0
% Copyright(c) 2013 Weisheng Dong, Lei Zhang, Guangming Shi, and Xin Li
% All Rights Reserved.
%
% ----------------------------------------------------------------------
% Permission to use, copy, or modify this software and its documentation
% for educational and research purposes only and without fee is here
% granted, provided that this copyright notice and the original authors'
% names appear on all copies and supporting documentation. This program
% shall not be used, rewritten, or adapted as the basis of a commercial
% software or hardware product without first obtaining permission of the
% authors. The authors make no representations about the suitability of
% this software for any purpose. It is provided "as is" without express
% or implied warranty.
%----------------------------------------------------------------------
%
% This is an implementation of the algorithm for image interpolation
% 
% Please cite the following paper if you use this code:
%
% Weisheng Dong, Lei Zhang, Guangming Shi, and Xin Li.,"Nonlocally  
% centralized sparse representation for image restoration", IEEE Trans. on
% Image Processing, vol. 22, no. 4, pp. 1620-1630, Apr. 2013.
% 
%--------------------------------------------------------------------------
function [pos_arr, wei_arr]  =  Block_matching(im, par)
%im is noise image 256*256 par which is including any parmeter.
S         =  30; % 30
f         =  par.win;%f=7 this is 图像块大小
f2        =  f^2;%f2=49
nv        =  par.nblk;%nv=16 找到每个图像块与斯相似的块
s         =  par.step;%s=1
hp        =  max(12*par.nSig, par.hp);% this is weight factors hp=240 
%2011年文章Image Deblurring and Super-resolution by Adaptive Sparse Domain
%Selection and Adaptive Regularization 第13页最下面的h which is factor control of wegiht

N         =  size(im,1)-f+1;%N=250
M         =  size(im,2)-f+1;%M=250
r         =  [1:s:N];%r=1:250
r         =  [r r(end)+1:N];
c         =  [1:s:M];%c=1:250
c         =  [c c(end)+1:M];
L         =  N*M;%L=62500
X         =  zeros(f*f, L, 'single');%49*62500
%初始化图像分块

k    =  0;
for i  = 1:f
    for j  = 1:f
        k    =  k+1;
        blk  =  im(i:end-f+i,j:end-f+j);
        X(k,:) =  blk(:)';
    end
end
%X 是将256*256大小的噪声图像分成7*7大小的图像块共62500块

I     =   (1:L);%I=1*62500
I     =   reshape(I, N, M);%I=250*250
N1    =   length(r);%N1=250
M1    =   length(c);%M1=250
pos_arr   =  zeros(nv, N1*M1 );%pos_arr=16*62500
wei_arr   =  zeros(nv, N1*M1 );%wei_arr=16*62500 
X         =  X';%X=62500*49

for  i  =  1 : N1
    for  j  =  1 : M1
        
        row     =   r(i);
        col     =   c(j);
        off     =  (col-1)*N + row;
        off1    =  (j-1)*N1 + i;
                
        rmin    =   max( row-S, 1 );
        rmax    =   min( row+S, N );
        cmin    =   max( col-S, 1 );
        cmax    =   min( col+S, M );
         
        idx     =   I(rmin:rmax, cmin:cmax);
        idx     =   idx(:);
        B       =   X(idx, :);        
        v       =   X(off, :);
%上述所求的v是当前的图像块，如果i=1,j=3时，则此时的图像块为第501个，
%这个图像块的选择是按照列来选取的，并非行，因此，第一行的第1个图像块编号为1，
%第一行的第二个图像块编号为251，第一行的第三个图像块编号为501
%因此，i=1,j=3时，此时的图像块编号为501
%B是第501号图像块周围的图像块，若干个，根据上面可以所求第501号图像块周围的多少个图像块
%        
        dis     =   (B(:,1) - v(1)).^2;
        for k = 2:f2
            dis   =  dis + (B(:,k) - v(k)).^2;
        end
        %dis是当前图像块与其周边图像块相减得到的值，便于找到与当前图像块最相近的块
        dis   =  dis./f2;%求得当前图像块与其周围图像块的差值，对每个相素点相减后再相加后取平均
        [val,ind]   =  sort(dis); 
%val是该图像块与其最近的图像块的差值按从小到大排列，ind是所对应差值按从小到大排列所对应的图像块
%比如第1个图像块与其最近前16号图像块的差值val与所对应的图像块ind分别为：
%val=[0;427.05;444.04;450.90;461.51;462.73;471.59;475.01;479.55;482.71;483.53;484.65;487.07;487.32;489.84;497.96;]
%ind=[1;760;823;761;719;797;342;296;933;313;858;244;919;931;129;556;]
        dis(ind(1))  =  dis(ind(2));
%由于B里面是包括当前图像块v的，所以dis(1)肯定是等于0的，因为与其相减的是其本身
%所以把与其最近的第2个图像块给予第1个图像块
        
                       
        wei         =  exp( -dis(ind(1:nv))./hp );
        wei         =  wei./(sum(wei)+eps);
%%2011年文章Image Deblurring and Super-resolution by Adaptive Sparse Domain
%Selection and Adaptive Regularization 第13页最下面的bil.
        indc        =  idx( ind(1:nv) );%找到与v最接近的图像块的真实编号
        pos_arr(:,off1)  =  indc;
%pos_arr为16*62500每一列表示1个图像块，
%如果off1＝1,则此时pos_arr(:,1)表示第1个图像块与其所对应最接近的图像块的编号，共16个，用行表示
        wei_arr(:,off1)  =  wei;
%pos_arr为16*62500每一列表示1个图像块，
%如果off1＝1,则此时pos_arr(:,1)表示第1个图像块与其所对应最接近的图像块的差值最小，共16个值
    end
end
pos_arr  = pos_arr';%62500*16
wei_arr  = wei_arr';%62500*16%文献1623页公式10
%最终找到62500个图像块中每个图像块与其最接近的图像块的编号pos_arr 62500*16,每行放入与其最接近图像块的编号
%最终找到62500个图像块中每个图像块与其最接近的图像块的差值最小 62500*16,每行放入与其最接近图像块的差值
%%2011年文章Image Deblurring and Super-resolution by Adaptive Sparse Domain
%Selection and Adaptive Regularization 第13页最下面的bil.
