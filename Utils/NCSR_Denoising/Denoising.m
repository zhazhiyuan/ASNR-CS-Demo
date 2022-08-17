
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
    %Dict.PCA_D�� wich is 2401*63,��63�������������49*49������ͼ���ֵ����
    
    %Dict.cls_idx ��62500����ͨͼ����е�ÿ��ͼ�������Ӧ�ľ������ģ�����ǿ�ȷ���vС��delta��ͼ��鹲��27569�飬��������Ϊ0
    
    %Dict.s_idx��s_idx��ÿ�����İ�0�ŵ�63���������У�ÿ����������Ӧ��ͼ���ı�Ű���˳�����У�0����������Ӧ��ͼ������ǿ�ȷ���vС��delta��ͼ���
    
    %Dict.seg: which is 65*1,[0;27569;28176;29169;29508;29764;29969;30977...]
    %0�����ļ�(ǿ�ȷ���vС��delta��ͼ��鹲��27569��)��1��������28176��27569��ͼ���
    %2��������29169��28176��ͼ��飬3��������29508��29169��ͼ���
    
    %Dict.D0: 49*49 ǿ�ȷ���vС��delta������ͼ������PCAѧϰ�õ�����ͼ���ֵ���� 49*49
    
    [blk_arr, wei_arr]     =   Block_matching( d_im, par);%����1623ҳ��ʽ10
%blk_arr��ʾ��62500��ͼ���ÿ��ͼ����ҵ��������16��ͼ���ı�ţ�ÿ�б�ʾһ��ͼ��飬�б�ʾ���������ͼ���ı��
%wei_arr��ʾ��62500��ͼ���ÿ��ͼ����ҵ��������16��ͼ���Ĳ�ֵ��ÿ�б�ʾһ��ͼ��飬�б�ʾ���������ͼ���Ĳ�ֵ
%��2011������Image Deblurring and Super-resolution by Adaptive Sparse Domain Selection and Adaptive Regularization ��13ҳ�������bil.
    for i  =  1 : 2%itera
        d_im    =   d_im + lamada*(n_im - d_im);%����lamada��0.02
        dif     =   d_im-n_im;
        vd      =   v^2-(mean(mean(dif.^2)));
        
        if (i ==1 && k==1)
            par.nSig  = sqrt(abs(vd));            
        else
            par.nSig  = sqrt(abs(vd))*par.lamada;
        end
        
        [alpha, beta, Tau1]   =   Cal_Parameters( d_im, par, Dict, blk_arr, wei_arr );   
        %���������Ҫ������ϡ��ϵ��a���ԭʼͼ����Ƶ�ϡ��ϵ��B���Լ����򻯲���Tau1
        d_im        =   NCSR_Shrinkage( d_im, par, alpha, beta, Tau1, Dict, 1 );

        PSNR        =   csnr( d_im(1:h1,1:w1), ori_im, 0, 0 );
       % fprintf( 'Preprocessing, Iter %d : PSNR = %f,   nsig = %3.2f\n', cnt, PSNR, par.nSig );
        cnt   =  cnt + 1;
       % imwrite(d_im./255, 'NCSR_Denoising\Results\tmp.tif');
    end
end
