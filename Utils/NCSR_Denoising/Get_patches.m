function  [Py  Px]  =  Get_patches( im, b, psf, s, scale )
im        =  imresize( im, scale, 'bilinear' );%256*256
%双三次插值，只是scale为1 所以重新得到的图像im与原图im是相同的

[h w ch]  =  size(im);%h=256,w=256,ch=1
ws        =  floor( size(psf,1)/2 );%4

if  ch==3
    lrim      =  rgb2ycbcr( uint8(im) );
    im        =  double( lrim(:,:,1));    
end

lp_im     =  conv2( psf, im );%264*264 低通信息
lp_im     =  lp_im(ws+1:h+ws, ws+1:w+ws);%256*256 低通信息
hp_im     =  im - lp_im;%256*256高通信息

N         =  h-b+1;%N＝256－7+1＝250
M         =  w-b+1;%M＝256－7+1＝250
% s         =  1;
r         =  [1:s:N];%1*250,1:1:250
r         =  [r r(end)+1:N];%1*250,1:1:250
c         =  [1:s:M];%1*250,1:1:250
c         =  [c c(end)+1:M];%1*250,1:1:250
L         =  length(r)*length(c);%62500
Py        =  zeros(b*b, L, 'single');%49*62500 存放高通图像块
Px        =  zeros(b*b, L, 'single');%49*62500 存放噪声图像块

k    =  0;
for i  = 1:b
    for j  = 1:b
        k       =  k+1;
        blk     =  hp_im(r-1+i,c-1+j);
        Py(k,:) =  blk(:)';
%第一行是从第一个像素开始，第二行从第2 像素开始，第七行从第7个像素开始，然后对每个blk取逆就得到了一个图像块
        
        blk     =  im(r-1+i,c-1+j);
        Px(k,:) =  blk(:)';        
    end
end
%So the final Py是高通的图像块，Px是原噪声图像块