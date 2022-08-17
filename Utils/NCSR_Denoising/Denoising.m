
function  [d_im ]    =   Denoising(n_im, par, ori_im)
[h1 w1]     =   size(ori_im);%h1=256,w1=256

par.tau1    =   0.1;
par.tau2    =   0.2;
par.tau3    =   0.3;
d_im        =   n_im;
lamada      =   0.002;
%lamada      =   0.0002;
v           =   par.nSig;%v=20
cnt         =   1;

for k    =  1:1%par.K%k=1:3

    Dict          =   KMeans_PCA( d_im, par, par.cls_num );
    %Dict.PCA_D： wich is 2401*63,即63个聚类质心求得49*49的噪声图像字典的逆
    
    %Dict.cls_idx ：62500个高通图像块中的每个图像块所对应的聚类质心，其中强度方差v小于delta的图像块共有27569块，聚类质心为0
    
    %Dict.s_idx：s_idx是每个质心按0号到63号质心排列，每个质心所对应的图像块的编号按照顺序排列，0号质心所对应的图像块就是强度方差v小于delta的图像块
    
    %Dict.seg: which is 65*1,[0;27569;28176;29169;29508;29764;29969;30977...]
    %0号质心即(强度方差v小于delta的图像块共有27569块)，1号质心有28176－27569个图像块
    %2号质心有29169－28176个图像块，3号质心有29508－29169个图像块
    
    %Dict.D0: 49*49 强度方差v小于delta的噪声图像块进行PCA学习得到噪声图像字典的逆 49*49
    
    [blk_arr, wei_arr]     =   Block_matching( d_im, par);%文献1623页公式10
%blk_arr表示这62500个图像块每个图像块找到与其最近16个图像块的编号，每行表示一个图像块，列表示与其最近的图像块的编号
%wei_arr表示这62500个图像块每个图像块找到与其最近16个图像块的差值，每行表示一个图像块，列表示与其最近的图像块的差值
%即2011年文章Image Deblurring and Super-resolution by Adaptive Sparse Domain Selection and Adaptive Regularization 第13页最下面的bil.
    for i  =  1 : 2%itera
        d_im    =   d_im + lamada*(n_im - d_im);%参数lamada＝0.02
        dif     =   d_im-n_im;
        vd      =   v^2-(mean(mean(dif.^2)));
        
        if (i ==1 && k==1)
            par.nSig  = sqrt(abs(vd));            
        else
            par.nSig  = sqrt(abs(vd))*par.lamada;
        end
        
        [alpha, beta, Tau1]   =   Cal_Parameters( d_im, par, Dict, blk_arr, wei_arr );   
        %求得了最重要的噪声稀疏系数a与对原始图像估计的稀疏系数B，以及正则化参数Tau1
        d_im        =   NCSR_Shrinkage( d_im, par, alpha, beta, Tau1, Dict, 1 );

        PSNR        =   csnr( d_im(1:h1,1:w1), ori_im, 0, 0 );
       % fprintf( 'Preprocessing, Iter %d : PSNR = %f,   nsig = %3.2f\n', cnt, PSNR, par.nSig );
        cnt   =  cnt + 1;
       % imwrite(d_im./255, 'NCSR_Denoising\Results\tmp.tif');
    end
end
