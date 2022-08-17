function [P, mx]=getpca(X, nsig)
%X is 49*57937
%nsig is 20
%X: MxN matrix (M dimensions, N trials)
%Y: Y=P*X
%P: the transform matrix
%V: the variance vector
%PCA 理论：
%首先对样本X共有N=57937个，每个为M=49*1，对样本X求均值mx=49*1
%然后对样本进行中心化，即X=X-mx2 49*57937
%求得样本的协方差矩阵CovX=X*X'/(N-1)为M*M＝49*49大小,
%CovX是一个对称矩阵，对称矩阵covX对角化找到一个正交矩阵P，满足PT(covX)P=V
%具体操作是先对covX进行特征值分解，得到特征值矩阵(对角化)即为V，得到特征向量矩阵并正交化，即为P。
%显然P，V是M*M维的。
%假如，我们取最大的前p（p<M）个特征值对应的维度，那么这p个特征值组成的新的对角矩阵V1是p*p维的，
%对应的p个特征向量组成的新的特征向量矩阵P1是M*p维

[M,N]=size(X);%M＝49，N＝57937

mx   =  mean(X,2);%49*1% 求得57937个图像块样本的均值
mx2  =  repmat(mx,1,N);%49*57937

X=X-mx2;%49*57937 归一化处理

CovX=X*X'/(N-1);%57937个图像块样本的协方差%49*49
%设定限制条件
CovX  =  CovX - diag(nsig^2*ones(size(CovX,1),1));%49*49
ind = find(CovX<0); 
CovX(ind) =0.0001; 

[P,V]=eig(CovX);
%[V,D]=eig(A)：求矩阵A的全部特征值，构成对角阵D，并求A的特征向量构成V的列向量
%V：49*49 特征值矩阵(对角阵)对称矩阵
%P：49*49 特征向量正交矩阵
%由于V中的特征值都挺大的，因此，无需省略小的矩阵
V=diag(V);%49*1此时所有的特征值
[t,ind]=sort(-V);%t是特征值从小到大排列ind是特征值所对应的顺序
% V=V(ind);
P=P(:,ind);%P是我们所求的字典
P=P';%此时的P是我们所求字典的逆
% Y=P*X;

return;

