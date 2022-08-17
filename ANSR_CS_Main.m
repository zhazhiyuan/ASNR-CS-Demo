%   These MATLAB programs implement the Block-based CS Recovery Algorithm via 
%   Adaptively Learned Sparsifying Basis (ALSB) algorithm as described in paper:
%   
%     J. Zhang, C. Zhao, D. Zhao, W. Gao, "Image Compressive Sensing Recovery Using 
%     Adaptively Learned Sparsifying Basis via L0 Minimization" in Signal
%     Processing (Special Issue on Image Restoration and Enhancement: Recent Advances 
%     and Applications), 2013.
%   
%   Note that, since most of this code relies on random projections,
%   the results produced may differ slightly in appearance and
%   value from those of the paper.
% 
% -------------------------------------------------------------------------------------------------------
% The software implemented by MatLab 7.10.0(2010a) are included in this package.
%
% ------------------------------------------------------------------
% Requirements
% ------------------------------------------------------------------
% *) Matlab 7.10.0(2010a) or later with installed:
% ------------------------------------------------------------------
% Version 1.0
% Author: Jian Zhang
% Email:  jzhangcs@hit.edu.cn
% Last modified by J. Zhang, Oct. 2013

%   For updated versions of ALSB, as well as the article on which it is based, 
%   consult: http://idm.pku.edu.cn/staff/zhangjian/ALSB/

%% Path Set -- Begin %%
function  [OrgName, subrate, PSN_Result,FSIM_Result,SSIM_Final,Time_s]=ANSR_CS_Main(OrgName,IterNum,subrate)



       time0         =   clock;
        BlockSize = 32;
        OrgImgName = [OrgName '.png'];
        OrgImg = double(imread(OrgImgName));
        [NumRows NumCols, kkk] = size(OrgImg);
        
             
        
         
        NumRows      =  NumRows-1;
        
        NumCols      = NumCols -1;
        
        
        
       OrgImg             =          imresize (OrgImg, [NumRows, NumCols]);     
        
        
        if kkk==3
             OrgImg = double(rgb2gray(imread(OrgImgName)));
        end
        
        clear Opts
        Opts = [];
        
        if ~isfield(Opts,'OrgName')
            Opts.OrgName = OrgName;
        end
        
        if ~isfield(Opts,'OrgImg')
            Opts.OrgImg = OrgImg;
        end
        
        if ~isfield(Opts,'NumRows')
            Opts.NumRows = NumRows;
        end
        
        if ~isfield(Opts,'NumCols')
            Opts.NumCols = NumCols;
        end
        
        if ~isfield(Opts,'BlockSize')
            Opts.BlockSize = BlockSize;
        end
        
        if ~isfield(Opts,'Subrate')
            Opts.Subrate = subrate;
        end
        
        if ~isfield(Opts,'IterNum')
            Opts.IterNum = IterNum;
        end
        
        if ~isfield(Opts,'ALSB_Thr')
            Opts.ALSB_Thr = 4;
        end
        
        if ~isfield(Opts,'PlogFlag')
            Opts.mu = 0.0025;
        end
        
        if ~isfield(Opts,'Inloop')
            Opts.Inloop = 200;
        end
        
        if ~isfield(Opts,'PlogFlag')
            Opts.PlogFlag = 1;
        end
          
        %% Parameter Set -- End %%
        
        %% CS Sampling -- Begin %%
        N = BlockSize^2;
        M = round(subrate * N);
        
        % randn('seed',0);
        PhiTemp = orth(randn(N, N))';
        Phi = PhiTemp(1:M, :);
        
        X = im2col(OrgImg, [BlockSize BlockSize], 'distinct');
        
        Y = Phi * X;
        %% CS Sampling -- End %%
        
        %% Initialization -- Begin %%
        [X_MH X_DDWT] = MH_BCS_SPL_Recovery(Y, Phi, Opts);
        
        
        if ~isfield(Opts,'InitImg')
            Opts.InitImg = X_MH;
        end
        %% Initialization -- End %%
        
        fprintf('%s,rate=%0.2f\n Initial PSNR=%0.2f\n',OrgName,subrate,csnr(Opts.InitImg ,OrgImg,0,0));
        %% CS Recovery by ALSB -- Begin %%
  
        
      [reconstructed_image,PSN_Result,FSIM_Result,SSIM_Final] = BCS_ALSB_Recovery_SBI(Y, Phi, Opts);
       
       
       Time_s =(etime(clock,time0));  
       
       
        if subrate==0.1
        Final_Name= strcat(OrgName,'_ASNR_CS_BSD68',num2str(subrate),'_PSNR_',num2str(PSN_Result),'_FSIM_',num2str(FSIM_Result),'_SSIM_',num2str(SSIM_Final),'.png');
            
        imwrite(uint8(reconstructed_image),strcat('./ratio_0.1_Results/',Final_Name));
       
        
        elseif subrate==0.2
            
        Final_Name= strcat(OrgName,'_ASNR_CS_BSD68',num2str(subrate),'_PSNR_',num2str(PSN_Result),'_FSIM_',num2str(FSIM_Result),'_SSIM_',num2str(SSIM_Final),'.png');
            
        imwrite(uint8(reconstructed_image),strcat('./ratio_0.2_Results/',Final_Name));

        
        elseif subrate==0.3
            
        Final_Name= strcat(OrgName,'_ASNR_CS_BSD68',num2str(subrate),'_PSNR_',num2str(PSN_Result),'_FSIM_',num2str(FSIM_Result),'_SSIM_',num2str(SSIM_Final),'.png');
            
        imwrite(uint8(reconstructed_image),strcat('./ratio_0.3_Results/',Final_Name));
        
        elseif subrate==0.4
            
        Final_Name= strcat(OrgName,'_ASNR_CS_BSD68',num2str(subrate),'_PSNR_',num2str(PSN_Result),'_FSIM_',num2str(FSIM_Result),'_SSIM_',num2str(SSIM_Final),'.png');
            
        imwrite(uint8(reconstructed_image),strcat('./ratio_0.4_Results/',Final_Name));

        else
            
        Final_Name= strcat(OrgName,'_ASNR_CS_BSD68',num2str(subrate),'_PSNR_',num2str(PSN_Result),'_FSIM_',num2str(FSIM_Result),'_SSIM_',num2str(SSIM_Final),'.png');
            
        imwrite(uint8(reconstructed_image),strcat('./ratio_0.5_Results/',Final_Name));
                      
       end          
       
 
    end



