function  [alpha, beta, Tau1]    =  Cal_Parameters( im, par, Dict, blk_arr, wei_arr )
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
%blk_arr表示62500个图像块每个图像块找到与其最近16个图像块的编号，每行表示一个图像块，列表示与其最近的图像块的编号
%wei_arr表示62500个图像块每个图像块找到与其最近16个图像块的差值，每行表示一个图像块，列表示与其最近的图像块的差值
[h w ch]   =   size(im);%h256,w=256,ch=1
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
k          =   0;%k=0;
s          =   par.step;%s=1

N     =  h-b+1;%N=250
M     =  w-b+1;%M=250
L     =  N*M;%L=62500
r     =  [1:s:N];%r=1:250
r     =  [r r(end)+1:N];%r=1:250
c     =  [1:s:M]; %c=1:250
c     =  [c c(end)+1:M];%c=1:250
X     =  zeros(b*b,L,'single');%49*62500 图像分块初始化
for i  = 1:b
    for j  = 1:b
        k    =  k+1;
        blk  =  im(i:h-b+i,j:w-b+j);
        blk  =  blk(:);
        X(k,:) =  blk';                 
    end
end
%生成62500个噪声图像块，大小为7*7

m_X       =   zeros(length(r)*length(c),b*b,'single');%m_X=62500*49
X1        =   X';%X1=62500*49,共计62500个图像块，每行为1个块

for i = 1:par.nblk %k=1：16 par.nblk是设定相似图像块的个数 16
%blk_arr表示62500个图像块每个图像块找到与其最近16个图像块的编号，每行表示一个图像块，列表示与其最近的图像块的编号 62500*16
%wei_arr表示62500个图像块每个图像块找到与其最近16个图像块的差值，每行表示一个图像块，列表示与其最近的图像块的差值 62500*16
   v            =   wei_arr(:,i);% v=62500*1 
   %if i=1,v是每个图像块与其相似的图像块的差值有权值
   m_X(:,:)     =   m_X(:,:) + X1(blk_arr(:,i),:) .*v(:, ones(1,b2));
   %如果按照行看，很容易看出与11年论文13页最下面的bil*xil很对应
end
%m_X是每个图像块与其最接近的图像块相减的权值乘以该图像块的值，
%即2011年文章Image Deblurring and Super-resolution by Adaptive Sparse Domain Selection and Adaptive Regularization 第13页最下面的(bil*xil)的和.
m_X          =   m_X';%m_X is 49*62500

N            =   length(r);%N＝250
M            =   length(c);%M＝250
L            =   N*M;%L＝62500
ind          =   zeros(N,M);%ind =250*250 zeros
ind(r,c)     =   1;%ind=250*250 all 1

X1           =   X(:, ind~=0);%49*62500 与X相同

alpha        =   zeros(b2, L, 'single' );%49*62500 zeros
beta         =   zeros(b2, L, 'single' );%49*62500 zeros
s0           =   zeros(b2, L, 'single' );%49*62500 zeros

idx            =   s_idx(seg(1)+1:seg(2)); %此时的idx是强度方差v小于delta的所对应的图像块，共有27569块
L0             =   length(idx);%L0＝27569
alpha(:,idx)   =   A*X1(:,idx);%this is文献1623页公式10下面第5行ai=DT*xi, 49*27569
beta(:,idx)    =   A*m_X(:,idx);%this is文献1623页公式10下面第6行ai,q=DT*xi,q, 49*27569
for  k  =  1 : L0
    i           =   idx(k);
    a           =   A*( X(:, blk_arr(i, 1:par.nblk)) - repmat( m_X(:, i), 1, par.nblk ));%|a-B|文献1624页公式14
    s0(:,i)     =   mean(a.^2, 2);%根号|a-B|文献1624页公式14下第一行，求得|a-B|的标准差
end
%以上所求的alpha,beta,s0分别是强度方差v小于delta的所对应的图像块进行学习得到的稀疏系数
%alpha是噪声图像的稀疏系数，文中公式11后面的a，beta是非局部图像块进行平均后的稀疏系数，公式9或者公式11中的B
%s0是|a-B|的标准差，公式17的分母.

for   i  = 2:length(seg)-1  %i=2:63 
    idx            =   s_idx(seg(i)+1:seg(i+1));    
    cls            =   PCA_idx(idx(1));
    P              =   reshape(Dict.PCA_D(:, cls), b2, b2);    
    alpha(:,idx)   =   P*X1(:,idx);
    beta(:,idx)    =   P*m_X(:,idx);
    for  j  =  1 : length(idx)
        k           =   idx(j);
        a           =   P*( X(:,blk_arr(k, 1:par.nblk)) - repmat( m_X(:, k), 1, par.nblk ));
        s0(:,k)     =   mean(a.^2, 2);
    end
end
s0       =   max(0, s0-par.nSig^2);
Tau1     =   (par.c1*sqrt(2)*par.nSig^2)./(sqrt(s0) + eps);%文献1624页公式17
return;

