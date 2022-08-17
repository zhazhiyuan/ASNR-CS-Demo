function  [Py  Px]  =  Get_patches( im, b, psf, s, scale )
im        =  imresize( im, scale, 'bilinear' );%256*256
%˫���β�ֵ��ֻ��scaleΪ1 �������µõ���ͼ��im��ԭͼim����ͬ��

[h w ch]  =  size(im);%h=256,w=256,ch=1
ws        =  floor( size(psf,1)/2 );%4

if  ch==3
    lrim      =  rgb2ycbcr( uint8(im) );
    im        =  double( lrim(:,:,1));    
end

lp_im     =  conv2( psf, im );%264*264 ��ͨ��Ϣ
lp_im     =  lp_im(ws+1:h+ws, ws+1:w+ws);%256*256 ��ͨ��Ϣ
hp_im     =  im - lp_im;%256*256��ͨ��Ϣ

N         =  h-b+1;%N��256��7+1��250
M         =  w-b+1;%M��256��7+1��250
% s         =  1;
r         =  [1:s:N];%1*250,1:1:250
r         =  [r r(end)+1:N];%1*250,1:1:250
c         =  [1:s:M];%1*250,1:1:250
c         =  [c c(end)+1:M];%1*250,1:1:250
L         =  length(r)*length(c);%62500
Py        =  zeros(b*b, L, 'single');%49*62500 ��Ÿ�ͨͼ���
Px        =  zeros(b*b, L, 'single');%49*62500 �������ͼ���

k    =  0;
for i  = 1:b
    for j  = 1:b
        k       =  k+1;
        blk     =  hp_im(r-1+i,c-1+j);
        Py(k,:) =  blk(:)';
%��һ���Ǵӵ�һ�����ؿ�ʼ���ڶ��дӵ�2 ���ؿ�ʼ�������дӵ�7�����ؿ�ʼ��Ȼ���ÿ��blkȡ��͵õ���һ��ͼ���
        
        blk     =  im(r-1+i,c-1+j);
        Px(k,:) =  blk(:)';        
    end
end
%So the final Py�Ǹ�ͨ��ͼ��飬Px��ԭ����ͼ���