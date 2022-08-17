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
function [im_out PSNR SSIM ]   =  NCSR_Denoising( par )
nim           =   par.nim;%256*256 噪声图像
[h  w ch]     =   size(nim);%h=256 w=256 ch=1
par.step      =   1;%步长
par.h         =   h;%256
par.w         =   w;%256
dim           =   uint8(zeros(h, w, ch));%初始化输出 256*256*ch zeros
ori_im        =   zeros(h,w);%256*256 zeros

if  ch == 3
    n_im           =   rgb2ycbcr( uint8(nim) );
    dim(:,:,2)     =   n_im(:,:,2);
    dim(:,:,3)     =   n_im(:,:,3);
    n_im           =   double( n_im(:,:,1));
    
    if isfield(par, 'I')
        ori_im         =   rgb2ycbcr( uint8(par.I) );
        ori_im         =   double( ori_im(:,:,1));
    end
else
    n_im           =   nim;%此时的噪声图像 256*256
    
    if isfield(par, 'I')
        ori_im             =   par.I;%Orign_image 256*256
    end
end
%disp(sprintf('PSNR of the noisy image = %f \n', csnr(n_im(1:h,1:w), ori_im, 0, 0) ));
%PSNR=22.083050

[d_im]     =   Denoising(n_im, par, ori_im);


if isfield(par,'I')
   [h w ch]  =  size(par.I);
   PSNR      =  csnr( d_im(1:h,1:w), ori_im, 0, 0 );
   SSIM      =  cal_ssim( d_im(1:h,1:w), ori_im, 0, 0 );
end

if ch==3
    dim(:,:,1)   =  uint8(d_im);
    im_out       =  double(ycbcr2rgb( dim ));
else
    im_out  =  d_im;
end
return;

