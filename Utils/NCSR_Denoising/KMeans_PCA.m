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
b         =   par.win;%����Ϊb=7*7
psf       =   fspecial('gaussian', par.win+2, par.sigma);%9*9��С�ĸ�˹��ͨ�˲���
[Y, X]    =   Get_patches(im, b, psf, 1, 1);
%Y�Ǹ�ͨ��ͼ��飬Y is 49*62500, 7*7��С��62500�顣X������ͼ���,X is 49*62500��7*7��С��62500��
for i=2:2:6  
   [Ys, Xs]   =   Get_patches(im, b, psf, 1, 0.8^i);
   Y          =   [Y Ys];% ����7*7��С�ĸ�ͨͼ���101109�� 
   X          =   [X Xs];%����7*7��С������ͼ���101109��
end

delta       =   sqrt(par.nSig^2+16);%delta=20.3916
%����ͼ����ǿ�ȷ���ķ�ֵ.
%�� Image Deblurring and Super-resolution by Adaptive Sparse Domain Selection and Adaptive Regularization
%��7ҳ��7��

v           =   sqrt( mean( Y.^2 ) );%1*101109
%����ͼ����ǿ�ȷ���v,ͬ�����׵�7ҳ��7��
[a, i0]     =   find( v<delta );%i0=57937����57937�飬�����г��˾����Ŀ�
%�ҵ�ǿ�ȷ���vС��delta��ͼ���
if length(i0)<par.m_num
    D0      =   dctmtx(par.win^2);
    %D = dctmtx(N) ʽ��D�Ƿ���N��N��DCT�任����
else
    %D0      =   getpca( X(:, i0), par.nSig );%D0=49*49 Dictionary Inverse when v<delta.
    D0      =   getpca( X(:, i0), par.nSig );
end
set         =   1:size(Y, 2);%1*101109
set(i0)     =   [];
Y           =   Y(:,set);%Ĩȥ��ͨͼ��������ǿ�ȷ���v<delta��ͼ��飬��43172��
X           =   X(:,set);%Ĩȥ����ͼ��������ǿ�ȷ���v<delta��ͼ��飬��43172��

itn       =   14;%�����㷨�ĵ�������
m_num     =   par.m_num;%ÿ��������ͼ������Ŀm_num=250
rand('seed',0);
%���ɹ̶��������
%seed �������� rand �� randn ,���û������seed��ÿ������rand��randn��������������ǲ�һ����
%����seed����������rand('seed',0);����ôÿ������rand�������������һ���ģ������Ե��Գ�����а���
[cls_idx, vec, cls_num]   =  Clustering(Y, cls_num, itn, m_num);
%���룺
%Y��49*43172,��ͨͼ��鹲43172��,
%cls_num��ʼ��������ĿΪ70
%itn:�����㷨������14��
%m_num����ÿ�������е�ͼ�������趨�����С��250�飬�򲻽���PCA����
%�����
%��ʱ��cls_idxΪ��ͨͼ��鹲43172����о���������õ���cls_idxΪ43172*1��ÿ��ͼ�������Ӧ������
%vecΪ63*49�����м���󣬴�ʱ�����Ĺ���63��
%cls_num������ĿΪ63
vec   =  vec';%49*63,ÿһ��Ϊһ�����Ĺ�63��


[s_idx, seg]   =  Proc_cls_idx( cls_idx );
%s_idx=43172*1,seg=64*1
 %s_idx��ÿ�����İ�1�ŵ�63���������У�ÿ����������Ӧ��ͼ���ı�Ű���˳������
 %seg���ҵ�ÿ���������湲�ж��ٿ�ͼ��飬��������˳���Ӧ,��
 %0��676��1664��2236��2991....
 %��1��������676��ͼ��飬2��������1664��676��ͼ���
PCA_D          =  zeros(b^4, cls_num);%2401*63
for  i  =  1 : length(seg)-1%i=1:63
   
    idx    =   s_idx(seg(i)+1:seg(i+1)); %if i=1,��   seg(i)+1:seg(i+1)��1��676
    %if i=1����idx is 1����������Ӧ��ͼ��������������
    cls    =   cls_idx(idx(1));%1������    
    X1     =   X(:, idx);%1����������Ӧ������ͼ��鹲676�飬idx������1�����������ͼ����������

    [P, mx]   =  getpca(X1, par.nSig);%P is 49*49 %��ʱ��P�����������ֵ����
    PCA_D(:,cls)    =  P(:);%����ͼ���ѧϰ�õ����ֵ�
    %��ʱ��PCA_D is 2401*63�У�ÿ�д���ÿ�������е�����ͼ������PCAѧϰ�õ����ֵ�49*49���������ʽ����2401*1
    %����63�������е�����ͼ���ͨ��PCAѧϰ�õ�63���ֵ䣬ÿ���ֵ��СΪ49*49
end

[Y, X]      =   Get_patches(im, b, psf, par.step, 1);
%Y is ���ɸ�ͨͼ��鹲62500�飬��49*62500
%X is ��������ͼ��鹲62500�飬��49*62500
cls_idx     =   zeros(size(Y, 2), 1);%62500*1 zeros

v           =   sqrt( mean( Y.^2 ) );%1*62500
%����ͼ����ǿ�ȷ���v
%delta       =   sqrt(par.nSig^2+16);%delta=20.3916
[a, ind]    =   find( v<delta ); %ind=1*27569
%ind=27569����27569�飬�����г��˾����Ŀ�
%�ҵ�ǿ�ȷ���vС��delta��ͼ���

set         =   1:size(Y, 2);%set: 1:62500
set(ind)    =   [];% set: 1*34931%Ĩȥ��ͨͼ��������ǿ�ȷ���v<delta��ͼ��飬��34931��
L           =   size(set,2);%34931
vec         =   vec';%63*49,���ڵľ������ģ���63�У�63����������
b2          =   size(Y, 1);%b2=49

for j = 1 : L%1:34931
    dis   =   (vec(:, 1) -  Y(1, set(j))).^2;
    for i = 2 : b2
        dis  =  dis + (vec(:, i)-Y(i, set(j))).^2;
    end
  %63������������34931��ͼ���ľ��룬����ÿ�д�����һ��ͼ���ֱ���ÿ�����ĵľ���
  %�����һ��ͼ�����63�����ĵľ���Ϊ63*1����һ�д����Ÿ�ͼ������1���������ĵľ���
  %ͬ����63�д����ŵ�1��ͼ�����63���������ĵľ���
    [val ind]      =   min( dis );
    %����ǵ�һ��ͼ��飬���val=6.4291e+04,ind=33,
    %Ҳ����˵��33���������1��ͼ���������ѵ�1��ͼ���ָ���33����������
    cls_idx( set(j) )   =   ind;
end

[s_idx, seg]   =  Proc_cls_idx( cls_idx );
    %s_idx��ÿ�����İ�1�ŵ�63���������У�ÿ����������Ӧ��ͼ���ı�Ű���˳������
    %seg���ҵ�ÿ���������湲�ж��ٿ�ͼ��飬��������˳���Ӧ,��
    %0��27569,28176,29169,29508,29764,29969;]
    %��0��������27569��ͼ���(ǿ�ȷ���vС��delta��ͼ���)��1��������28176��27569��ͼ���
    %2��������29169��28176��ͼ��飬3��������29508��29169��ͼ���

Dict.PCA_D       =   PCA_D;%2401*63
Dict.cls_idx     =   cls_idx;%62500*1
Dict.s_idx       =   s_idx;%62500*1
Dict.seg         =   seg;%65*1
Dict.D0          =   D0;%49*49


