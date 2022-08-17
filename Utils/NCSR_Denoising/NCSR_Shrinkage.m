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
function  [im_out]  =  NCSR_Shrinkage( im, par, alpha, beta, Tau1, Dict, flag )
%the first iteration:
%im which is noise image  256*256
%par which is the varies of  parmeters.
%Dict which is include Dictionary inforamtion,
%namely:
%Dict.PCA_D： wich is 2401*63,即63个聚类质心求得49*49的噪声图像字典的逆
%Dict.cls_idx ：62500个高通图像块中的每个图像块所对应的聚类质心，其中强度方差v小于delta的图像块共有27569块，聚类质心为0
%Dict.s_idx：s_idx是每个质心按0号到63号质心排列，每个质心所对应的图像块的编号按照顺序排列，0号质心所对应的图像块就是强度方差v小于delta的图像块
%Dict.seg: which is 65*1,[0;27569;28176;29169;29508;29764;29969;30977...]
%0号质心即(强度方差v小于delta的图像块共有27569-1+1块)，1号质心有28176－27569+1个图像块
%2号质心有29169－28176+1个图像块，3号质心有29508－29169+1个图像块
%Dict.D0: 49*49 强度方差v小于delta的噪声图像块进行PCA学习得到噪声图像字典的逆 49*49
%Tau1:正则化系数 49*62500
%alpha：噪声图像的稀疏系数 49*62500
%beta：原图像通过噪声图像非局部图像块估计进行平均后的稀疏系数 49*62500
[h w ch]   =   size(im);%h=256;w=256;ch=1
A          =   Dict.D0;%A is 49*49, 强度方差v小于delta的噪声图像块进行PCA学习得到噪声图像字典的逆
PCA_idx    =   Dict.cls_idx;%PCA_idx=62500*1，表示每个图像块所对应的63个聚类的质心
s_idx      =   Dict.s_idx;% s_idx＝62500*1，
%表示聚类质心按照0－63排列，每个质心中所含有的图像块，
%这些图像块按照顺序排列，从0号质心开始，63号质心结束，0号质心所对应的图像块就是强度方差v小于delta的图像块
seg        =   Dict.seg;% which is 65*1,
%namely:[0;27569;28176;29169;29508;29764;29969;30977...]
%0号质心即(强度方差v小于delta的图像块共有27569-1+1块)，1号质心有28176－27569+1个图像块
%2号质心有29169－28176+1个图像块，3号质心有29508－29169+1个图像块
b          =   par.win;%窗口大小为7
b2         =   b*b*ch;%b2=49
Y          =   zeros(b2, size(alpha,2), 'single' );%Y is 49*62500

idx          =   s_idx(seg(1)+1:seg(2));%此时的idx是强度方差v小于delta的所对应的图像块，共有27569块
tau1         =   par.tau1;%0.1 初始化正则化参数
if  flag==1
    tau1    =   Tau1(:, idx);% tau1=49*27569
end
Y(:, idx)    =   A'*(soft( alpha(:,idx)-beta(:,idx), tau1 ) + beta(:,idx));%文献1624页公式19 49*27569
%A'是49*49, 强度方差v小于delta的噪声图像块进行PCA学习得到噪声图像字典
%alpha(:,idx)=(soft( alpha(:,idx)-beta(:,idx), tau1 ) + beta(:,idx))稀疏系数的更新
%以上是强度方差v小于delta的噪声图像块重建的结果

for   i  = 2:length(seg)-1   
    idx    =   s_idx(seg(i)+1:seg(i+1));    
    cls    =   PCA_idx(idx(1));
    P      =   reshape(Dict.PCA_D(:, cls), b2, b2);
    tau1         =   par.tau1;
    if  flag==1 
        tau1    =   Tau1(:, idx);
    end
    Y(:, idx)    =   P'*(soft( alpha(:,idx)-beta(:,idx), tau1 ) + beta(:,idx));
end
%以上是强度方差v大于delta的噪声图像块重建的结果
s     =  par.step;%s=1
N     =  h-b+1;%N=250
M     =  w-b+1;%M=250
r     =  [1:s:N];%r=1:250
r     =  [r r(end)+1:N];%r=1:250
c     =  [1:s:M];%c=1:250
c     =  [c c(end)+1:M];%c=1:250
N     =   length(r);%N=250
M     =   length(c);%M=250
im_out   =  zeros(h,w);%im_out=256*256
im_wei   =  zeros(h,w);%im_wei=256*256
k        =  0;
for i  = 1:b
    for j  = 1:b
        k    =  k+1;
        im_out(r-1+i,c-1+j)  =  im_out(r-1+i,c-1+j) + reshape( Y(k,:)', [N M]);
        %if k=1，则Y(1,:)'表示每个图像块的第一个像素值
        %对于输出的图像的每个像素进行填充
        im_wei(r-1+i,c-1+j)  =  im_wei(r-1+i,c-1+j) + 1;
    end
end

im_out  =  im_out./(im_wei+eps);
 %对于输出的图像的每个像素进行填充，因为每个像素填充不止一次，因此，最终对于每个像素需要取其平均
%figure;imshow(uint8(im_out));
return;
