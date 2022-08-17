function [P, mx]=getpca(X, nsig)
%X is 49*57937
%nsig is 20
%X: MxN matrix (M dimensions, N trials)
%Y: Y=P*X
%P: the transform matrix
%V: the variance vector
%PCA ���ۣ�
%���ȶ�����X����N=57937����ÿ��ΪM=49*1��������X���ֵmx=49*1
%Ȼ��������������Ļ�����X=X-mx2 49*57937
%���������Э�������CovX=X*X'/(N-1)ΪM*M��49*49��С,
%CovX��һ���Գƾ��󣬶Գƾ���covX�Խǻ��ҵ�һ����������P������PT(covX)P=V
%����������ȶ�covX��������ֵ�ֽ⣬�õ�����ֵ����(�Խǻ�)��ΪV���õ�����������������������ΪP��
%��ȻP��V��M*Mά�ġ�
%���磬����ȡ����ǰp��p<M��������ֵ��Ӧ��ά�ȣ���ô��p������ֵ��ɵ��µĶԽǾ���V1��p*pά�ģ�
%��Ӧ��p������������ɵ��µ�������������P1��M*pά

[M,N]=size(X);%M��49��N��57937

mx   =  mean(X,2);%49*1% ���57937��ͼ��������ľ�ֵ
mx2  =  repmat(mx,1,N);%49*57937

X=X-mx2;%49*57937 ��һ������

CovX=X*X'/(N-1);%57937��ͼ���������Э����%49*49
%�趨��������
CovX  =  CovX - diag(nsig^2*ones(size(CovX,1),1));%49*49
ind = find(CovX<0); 
CovX(ind) =0.0001; 

[P,V]=eig(CovX);
%[V,D]=eig(A)�������A��ȫ������ֵ�����ɶԽ���D������A��������������V��������
%V��49*49 ����ֵ����(�Խ���)�Գƾ���
%P��49*49 ����������������
%����V�е�����ֵ��ͦ��ģ���ˣ�����ʡ��С�ľ���
V=diag(V);%49*1��ʱ���е�����ֵ
[t,ind]=sort(-V);%t������ֵ��С��������ind������ֵ����Ӧ��˳��
% V=V(ind);
P=P(:,ind);%P������������ֵ�
P=P';%��ʱ��P�����������ֵ����
% Y=P*X;

return;
