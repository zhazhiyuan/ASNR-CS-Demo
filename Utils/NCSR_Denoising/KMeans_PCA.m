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
function  Dict   =  KMeans_PCA( im, par, cls_num )
%im is 256*256 noise image ,cls_num is 70 cluster,par which are pararmeters.
b         =   par.win;%窗口为b=7*7
psf       =   fspecial('gaussian', par.win+2, par.sigma);%9*9大小的高斯低通滤波器
[Y, X]    =   Get_patches(im, b, psf, 1, 1);
%Y是高通的图像块，Y is 49*62500, 7*7大小共62500块。X是噪声图像块,X is 49*62500，7*7大小共62500块
for i=2:2:6  
   [Ys, Xs]   =   Get_patches(im, b, psf, 1, 0.8^i);
   Y          =   [Y Ys];% 共有7*7大小的高通图像块101109块 
   X          =   [X Xs];%共有7*7大小的噪声图像块101109块
end

delta       =   sqrt(par.nSig^2+16);%delta=20.3916
%定义图像块的强度方差的阀值.
%见 Image Deblurring and Super-resolution by Adaptive Sparse Domain Selection and Adaptive Regularization
%第7页第7行

v           =   sqrt( mean( Y.^2 ) );%1*101109
%定义图像块的强度方差v,同上文献第7页第7行
[a, i0]     =   find( v<delta );%i0=57937，共57937块，并且列出了具体哪块
%找到强度方差v小于delta的图像块
if length(i0)<par.m_num
    D0      =   dctmtx(par.win^2);
    %D = dctmtx(N) 式中D是返回N×N的DCT变换矩阵
else
    %D0      =   getpca( X(:, i0), par.nSig );%D0=49*49 Dictionary Inverse when v<delta.
    D0      =   getpca( X(:, i0), par.nSig );
end
set         =   1:size(Y, 2);%1*101109
set(i0)     =   [];
Y           =   Y(:,set);%抹去高通图像块里面的强度方差v<delta的图像块，共43172块
X           =   X(:,set);%抹去噪声图像块里面的强度方差v<delta的图像块，共43172块

itn       =   14;%聚类算法的迭代次数
m_num     =   par.m_num;%每个聚类中图像块的数目m_num=250
rand('seed',0);
%生成固定的随机数
%seed 用来控制 rand 和 randn ,如果没有设置seed，每次运行rand或randn产生的随机数都是不一样的
%用了seed，比如设置rand('seed',0);，那么每次运行rand产生的随机数是一样的，这样对调试程序很有帮助
[cls_idx, vec, cls_num]   =  Clustering(Y, cls_num, itn, m_num);
%输入：
%Y：49*43172,高通图像块共43172块,
%cls_num初始化质心数目为70
%itn:聚类算法共迭代14次
%m_num对于每个质心中的图像块进行设定，如果小于250块，则不进行PCA操作
%输出：
%此时的cls_idx为高通图像块共43172块进行聚类操作，得到，cls_idx为43172*1，每个图像块所对应的质心
%vec为63*49，进行计算后，此时的质心共有63个
%cls_num质心数目为63
vec   =  vec';%49*63,每一列为一个质心共63个


[s_idx, seg]   =  Proc_cls_idx( cls_idx );
%s_idx=43172*1,seg=64*1
 %s_idx是每个质心按1号到63号质心排列，每个质心所对应的图像块的编号按照顺序排列
 %seg是找到每个质心里面共有多少块图像块，按照质心顺序对应,即
 %0，676，1664，2236，2991....
 %即1号质心有676个图像块，2号质心有1664－676个图像块
PCA_D          =  zeros(b^4, cls_num);%2401*63
for  i  =  1 : length(seg)-1%i=1:63
   
    idx    =   s_idx(seg(i)+1:seg(i+1)); %if i=1,则   seg(i)+1:seg(i+1)＝1：676
    %if i=1，则idx is 1号质心所对应的图像块的所有索引集
    cls    =   cls_idx(idx(1));%1号质心    
    X1     =   X(:, idx);%1号质心所对应的噪声图像块共676块，idx是属于1号质心里面的图像块的索引号

    [P, mx]   =  getpca(X1, par.nSig);%P is 49*49 %此时的P是我们所求字典的逆
    PCA_D(:,cls)    =  P(:);%噪声图像块学习得到的字典
    %此时的PCA_D is 2401*63中，每列代表每个聚类中的噪声图像块进行PCA学习得到的字典49*49，变成列形式就是2401*1
    %所以63个质心中的噪声图像块通过PCA学习得到63个字典，每个字典大小为49*49
end

[Y, X]      =   Get_patches(im, b, psf, par.step, 1);
%Y is 生成高通图像块共62500块，即49*62500
%X is 生成噪声图像块共62500块，即49*62500
cls_idx     =   zeros(size(Y, 2), 1);%62500*1 zeros

v           =   sqrt( mean( Y.^2 ) );%1*62500
%定义图像块的强度方差v
%delta       =   sqrt(par.nSig^2+16);%delta=20.3916
[a, ind]    =   find( v<delta ); %ind=1*27569
%ind=27569，共27569块，并且列出了具体哪块
%找到强度方差v小于delta的图像块

set         =   1:size(Y, 2);%set: 1:62500
set(ind)    =   [];% set: 1*34931%抹去高通图像块里面的强度方差v<delta的图像块，共34931块
L           =   size(set,2);%34931
vec         =   vec';%63*49,现在的聚类质心，共63行，63个聚类质心
b2          =   size(Y, 1);%b2=49

for j = 1 : L%1:34931
    dis   =   (vec(:, 1) -  Y(1, set(j))).^2;
    for i = 2 : b2
        dis  =  dis + (vec(:, i)-Y(i, set(j))).^2;
    end
  %63个聚类质心与34931个图像块的距离，其中每列代表着一个图像块分别与每个质心的距离
  %比如第一个图像块与63个质心的距离为63*1，第一行代表着该图像块与第1个聚类质心的距离
  %同理，第63行代表着第1个图像与第63个聚类质心的距离
    [val ind]      =   min( dis );
    %如果是第一个图像块，求得val=6.4291e+04,ind=33,
    %也就是说第33个质心与第1个图像块最近，把第1个图像块分给第33个聚类质心
    cls_idx( set(j) )   =   ind;
end

[s_idx, seg]   =  Proc_cls_idx( cls_idx );
    %s_idx是每个质心按1号到63号质心排列，每个质心所对应的图像块的编号按照顺序排列
    %seg是找到每个质心里面共有多少块图像块，按照质心顺序对应,即
    %0，27569,28176,29169,29508,29764,29969;]
    %即0号质心有27569个图像块(强度方差v小于delta的图像块)，1号质心有28176－27569个图像块
    %2号质心有29169－28176个图像块，3号质心有29508－29169个图像块

Dict.PCA_D       =   PCA_D;%2401*63
Dict.cls_idx     =   cls_idx;%62500*1
Dict.s_idx       =   s_idx;%62500*1
Dict.seg         =   seg;%65*1
Dict.D0          =   D0;%49*49


