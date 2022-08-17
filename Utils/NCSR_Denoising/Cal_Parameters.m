function  [alpha, beta, Tau1]    =  Cal_Parameters( im, par, Dict, blk_arr, wei_arr )
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
%blk_arr��ʾ62500��ͼ���ÿ��ͼ����ҵ��������16��ͼ���ı�ţ�ÿ�б�ʾһ��ͼ��飬�б�ʾ���������ͼ���ı��
%wei_arr��ʾ62500��ͼ���ÿ��ͼ����ҵ��������16��ͼ���Ĳ�ֵ��ÿ�б�ʾһ��ͼ��飬�б�ʾ���������ͼ���Ĳ�ֵ
[h w ch]   =   size(im);%h256,w=256,ch=1
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
k          =   0;%k=0;
s          =   par.step;%s=1

N     =  h-b+1;%N=250
M     =  w-b+1;%M=250
L     =  N*M;%L=62500
r     =  [1:s:N];%r=1:250
r     =  [r r(end)+1:N];%r=1:250
c     =  [1:s:M]; %c=1:250
c     =  [c c(end)+1:M];%c=1:250
X     =  zeros(b*b,L,'single');%49*62500 ͼ��ֿ��ʼ��
for i  = 1:b
    for j  = 1:b
        k    =  k+1;
        blk  =  im(i:h-b+i,j:w-b+j);
        blk  =  blk(:);
        X(k,:) =  blk';                 
    end
end
%����62500������ͼ��飬��СΪ7*7

m_X       =   zeros(length(r)*length(c),b*b,'single');%m_X=62500*49
X1        =   X';%X1=62500*49,����62500��ͼ��飬ÿ��Ϊ1����

for i = 1:par.nblk %k=1��16 par.nblk���趨����ͼ���ĸ��� 16
%blk_arr��ʾ62500��ͼ���ÿ��ͼ����ҵ��������16��ͼ���ı�ţ�ÿ�б�ʾһ��ͼ��飬�б�ʾ���������ͼ���ı�� 62500*16
%wei_arr��ʾ62500��ͼ���ÿ��ͼ����ҵ��������16��ͼ���Ĳ�ֵ��ÿ�б�ʾһ��ͼ��飬�б�ʾ���������ͼ���Ĳ�ֵ 62500*16
   v            =   wei_arr(:,i);% v=62500*1 
   %if i=1,v��ÿ��ͼ����������Ƶ�ͼ���Ĳ�ֵ��Ȩֵ
   m_X(:,:)     =   m_X(:,:) + X1(blk_arr(:,i),:) .*v(:, ones(1,b2));
   %��������п��������׿�����11������13ҳ�������bil*xil�ܶ�Ӧ
end
%m_X��ÿ��ͼ���������ӽ���ͼ��������Ȩֵ���Ը�ͼ����ֵ��
%��2011������Image Deblurring and Super-resolution by Adaptive Sparse Domain Selection and Adaptive Regularization ��13ҳ�������(bil*xil)�ĺ�.
m_X          =   m_X';%m_X is 49*62500

N            =   length(r);%N��250
M            =   length(c);%M��250
L            =   N*M;%L��62500
ind          =   zeros(N,M);%ind =250*250 zeros
ind(r,c)     =   1;%ind=250*250 all 1

X1           =   X(:, ind~=0);%49*62500 ��X��ͬ

alpha        =   zeros(b2, L, 'single' );%49*62500 zeros
beta         =   zeros(b2, L, 'single' );%49*62500 zeros
s0           =   zeros(b2, L, 'single' );%49*62500 zeros

idx            =   s_idx(seg(1)+1:seg(2)); %��ʱ��idx��ǿ�ȷ���vС��delta������Ӧ��ͼ��飬����27569��
L0             =   length(idx);%L0��27569
alpha(:,idx)   =   A*X1(:,idx);%this is����1623ҳ��ʽ10�����5��ai=DT*xi, 49*27569
beta(:,idx)    =   A*m_X(:,idx);%this is����1623ҳ��ʽ10�����6��ai,q=DT*xi,q, 49*27569
for  k  =  1 : L0
    i           =   idx(k);
    a           =   A*( X(:, blk_arr(i, 1:par.nblk)) - repmat( m_X(:, i), 1, par.nblk ));%|a-B|����1624ҳ��ʽ14
    s0(:,i)     =   mean(a.^2, 2);%����|a-B|����1624ҳ��ʽ14�µ�һ�У����|a-B|�ı�׼��
end
%���������alpha,beta,s0�ֱ���ǿ�ȷ���vС��delta������Ӧ��ͼ������ѧϰ�õ���ϡ��ϵ��
%alpha������ͼ���ϡ��ϵ�������й�ʽ11�����a��beta�ǷǾֲ�ͼ������ƽ�����ϡ��ϵ������ʽ9���߹�ʽ11�е�B
%s0��|a-B|�ı�׼���ʽ17�ķ�ĸ.

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
Tau1     =   (par.c1*sqrt(2)*par.nSig^2)./(sqrt(s0) + eps);%����1624ҳ��ʽ17
return;

