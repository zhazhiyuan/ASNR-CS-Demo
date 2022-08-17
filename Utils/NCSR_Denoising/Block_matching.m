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
f         =  par.win;%f=7 this is ͼ����С
f2        =  f^2;%f2=49
nv        =  par.nblk;%nv=16 �ҵ�ÿ��ͼ�����˹���ƵĿ�
s         =  par.step;%s=1
hp        =  max(12*par.nSig, par.hp);% this is weight factors hp=240 
%2011������Image Deblurring and Super-resolution by Adaptive Sparse Domain
%Selection and Adaptive Regularization ��13ҳ�������h which is factor control of wegiht

N         =  size(im,1)-f+1;%N=250
M         =  size(im,2)-f+1;%M=250
r         =  [1:s:N];%r=1:250
r         =  [r r(end)+1:N];
c         =  [1:s:M];%c=1:250
c         =  [c c(end)+1:M];
L         =  N*M;%L=62500
X         =  zeros(f*f, L, 'single');%49*62500
%��ʼ��ͼ��ֿ�

k    =  0;
for i  = 1:f
    for j  = 1:f
        k    =  k+1;
        blk  =  im(i:end-f+i,j:end-f+j);
        X(k,:) =  blk(:)';
    end
end
%X �ǽ�256*256��С������ͼ��ֳ�7*7��С��ͼ��鹲62500��

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
%���������v�ǵ�ǰ��ͼ��飬���i=1,j=3ʱ�����ʱ��ͼ���Ϊ��501����
%���ͼ����ѡ���ǰ�������ѡȡ�ģ������У���ˣ���һ�еĵ�1��ͼ�����Ϊ1��
%��һ�еĵڶ���ͼ�����Ϊ251����һ�еĵ�����ͼ�����Ϊ501
%��ˣ�i=1,j=3ʱ����ʱ��ͼ�����Ϊ501
%B�ǵ�501��ͼ�����Χ��ͼ��飬���ɸ�������������������501��ͼ�����Χ�Ķ��ٸ�ͼ���
%        
        dis     =   (B(:,1) - v(1)).^2;
        for k = 2:f2
            dis   =  dis + (B(:,k) - v(k)).^2;
        end
        %dis�ǵ�ǰͼ��������ܱ�ͼ�������õ���ֵ�������ҵ��뵱ǰͼ���������Ŀ�
        dis   =  dis./f2;%��õ�ǰͼ���������Χͼ���Ĳ�ֵ����ÿ�����ص����������Ӻ�ȡƽ��
        [val,ind]   =  sort(dis); 
%val�Ǹ�ͼ������������ͼ���Ĳ�ֵ����С�������У�ind������Ӧ��ֵ����С������������Ӧ��ͼ���
%�����1��ͼ����������ǰ16��ͼ���Ĳ�ֵval������Ӧ��ͼ���ind�ֱ�Ϊ��
%val=[0;427.05;444.04;450.90;461.51;462.73;471.59;475.01;479.55;482.71;483.53;484.65;487.07;487.32;489.84;497.96;]
%ind=[1;760;823;761;719;797;342;296;933;313;858;244;919;931;129;556;]
        dis(ind(1))  =  dis(ind(2));
%����B�����ǰ�����ǰͼ���v�ģ�����dis(1)�϶��ǵ���0�ģ���Ϊ������������䱾��
%���԰���������ĵ�2��ͼ�������1��ͼ���
        
                       
        wei         =  exp( -dis(ind(1:nv))./hp );
        wei         =  wei./(sum(wei)+eps);
%%2011������Image Deblurring and Super-resolution by Adaptive Sparse Domain
%Selection and Adaptive Regularization ��13ҳ�������bil.
        indc        =  idx( ind(1:nv) );%�ҵ���v��ӽ���ͼ������ʵ���
        pos_arr(:,off1)  =  indc;
%pos_arrΪ16*62500ÿһ�б�ʾ1��ͼ��飬
%���off1��1,���ʱpos_arr(:,1)��ʾ��1��ͼ�����������Ӧ��ӽ���ͼ���ı�ţ���16�������б�ʾ
        wei_arr(:,off1)  =  wei;
%pos_arrΪ16*62500ÿһ�б�ʾ1��ͼ��飬
%���off1��1,���ʱpos_arr(:,1)��ʾ��1��ͼ�����������Ӧ��ӽ���ͼ���Ĳ�ֵ��С����16��ֵ
    end
end
pos_arr  = pos_arr';%62500*16
wei_arr  = wei_arr';%62500*16%����1623ҳ��ʽ10
%�����ҵ�62500��ͼ�����ÿ��ͼ���������ӽ���ͼ���ı��pos_arr 62500*16,ÿ�з���������ӽ�ͼ���ı��
%�����ҵ�62500��ͼ�����ÿ��ͼ���������ӽ���ͼ���Ĳ�ֵ��С 62500*16,ÿ�з���������ӽ�ͼ���Ĳ�ֵ
%%2011������Image Deblurring and Super-resolution by Adaptive Sparse Domain
%Selection and Adaptive Regularization ��13ҳ�������bil.
