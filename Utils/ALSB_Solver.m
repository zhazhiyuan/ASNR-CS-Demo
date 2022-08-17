function  im  = ALSB_Solver(R,ALSB_Thr,OrgImg)


nSig             =    ALSB_Thr;%·½²îÎª20

par              =    Parameters_setting( nSig );

par.I            =    double( OrgImg);

par.nim           =      R;
    
[im PSNR SSIM]   =    NCSR_Denoising( par);    
%figure;imshow(uint8(im));
%imwrite(im./255, 'NCSR_Denoising\Results\NCSR_den_house.tif');



end