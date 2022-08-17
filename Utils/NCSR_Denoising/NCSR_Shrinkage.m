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
%Dict.PCA_D�� wich is 2401*63,��63�������������49*49������ͼ���ֵ����
%Dict.cls_idx ��62500����ͨͼ����е�ÿ��ͼ�������Ӧ�ľ������ģ�����ǿ�ȷ���vС��delta��ͼ��鹲��27569�飬��������Ϊ0
%Dict.s_idx��s_idx��ÿ�����İ�0�ŵ�63���������У�ÿ����������Ӧ��ͼ���ı�Ű���˳�����У�0����������Ӧ��ͼ������ǿ�ȷ���vС��delta��ͼ���
%Dict.seg: which is 65*1,[0;27569;28176;29169;29508;29764;29969;30977...]
%0�����ļ�(ǿ�ȷ���vС��delta��ͼ��鹲��27569-1+1��)��1��������28176��27569+1��ͼ���
%2��������29169��28176+1��ͼ��飬3��������29508��29169+1��ͼ���
%Dict.D0: 49*49 ǿ�ȷ���vС��delta������ͼ������PCAѧϰ�õ�����ͼ���ֵ���� 49*49
%Tau1:����ϵ�� 49*62500
%alpha������ͼ���ϡ��ϵ�� 49*62500
%beta��ԭͼ��ͨ������ͼ��Ǿֲ�ͼ�����ƽ���ƽ�����ϡ��ϵ�� 49*62500
[h w ch]   =   size(im);%h=256;w=256;ch=1
A          =   Dict.D0;%A is 49*49, ǿ�ȷ���vС��delta������ͼ������PCAѧϰ�õ�����ͼ���ֵ����
PCA_idx    =   Dict.cls_idx;%PCA_idx=62500*1����ʾÿ��ͼ�������Ӧ��63�����������
s_idx      =   Dict.s_idx;% s_idx��62500*1��
%��ʾ�������İ���0��63���У�ÿ�������������е�ͼ��飬
%��Щͼ��鰴��˳�����У���0�����Ŀ�ʼ��63�����Ľ�����0����������Ӧ��ͼ������ǿ�ȷ���vС��delta��ͼ���
seg        =   Dict.seg;% which is 65*1,
%namely:[0;27569;28176;29169;29508;29764;29969;30977...]
%0�����ļ�(ǿ�ȷ���vС��delta��ͼ��鹲��27569-1+1��)��1��������28176��27569+1��ͼ���
%2��������29169��28176+1��ͼ��飬3��������29508��29169+1��ͼ���
b          =   par.win;%���ڴ�СΪ7
b2         =   b*b*ch;%b2=49
Y          =   zeros(b2, size(alpha,2), 'single' );%Y is 49*62500

idx          =   s_idx(seg(1)+1:seg(2));%��ʱ��idx��ǿ�ȷ���vС��delta������Ӧ��ͼ��飬����27569��
tau1         =   par.tau1;%0.1 ��ʼ�����򻯲���
if  flag==1
    tau1    =   Tau1(:, idx);% tau1=49*27569
end
Y(:, idx)    =   A'*(soft( alpha(:,idx)-beta(:,idx), tau1 ) + beta(:,idx));%����1624ҳ��ʽ19 49*27569
%A'��49*49, ǿ�ȷ���vС��delta������ͼ������PCAѧϰ�õ�����ͼ���ֵ�
%alpha(:,idx)=(soft( alpha(:,idx)-beta(:,idx), tau1 ) + beta(:,idx))ϡ��ϵ���ĸ���
%������ǿ�ȷ���vС��delta������ͼ����ؽ��Ľ��

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
%������ǿ�ȷ���v����delta������ͼ����ؽ��Ľ��
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
        %if k=1����Y(1,:)'��ʾÿ��ͼ���ĵ�һ������ֵ
        %���������ͼ���ÿ�����ؽ������
        im_wei(r-1+i,c-1+j)  =  im_wei(r-1+i,c-1+j) + 1;
    end
end

im_out  =  im_out./(im_wei+eps);
 %���������ͼ���ÿ�����ؽ�����䣬��Ϊÿ��������䲻ֹһ�Σ���ˣ����ն���ÿ��������Ҫȡ��ƽ��
%figure;imshow(uint8(im_out));
return;
