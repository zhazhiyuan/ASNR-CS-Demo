
function [RecImg,PSN_Result, FSIM_Result, SSIM_Result] = BCS_ALSB_Recovery_SBI(Y, Phi, Opts)

NumRows = Opts.NumRows;
NumCols = Opts.NumCols;
BlockSize = Opts.BlockSize;
IterNum = Opts.IterNum;
OrgImg = Opts.OrgImg;
ALSB_Thr = Opts.ALSB_Thr;
InitImg = Opts.InitImg;
mu = Opts.mu;
Inloop = Opts.Inloop;


X = im2col(InitImg, [BlockSize BlockSize], 'distinct');

U = zeros(size(X));
B = zeros(size(X));
All_Error_Brain_01 = cell(1,IterNum);
PSNRI =   zeros(1,IterNum);

ATA = Phi'*Phi;
ATy = Phi'*Y;
IM = eye(size(ATA));

for i = 1:IterNum
    
    X_hat = X;
    
    R = col2im(X_hat-B, [BlockSize BlockSize], [NumRows NumCols], 'distinct');
    
    X_bar    = ALSB_Solver(R,ALSB_Thr,OrgImg);   
    
    X_bar = im2col(X_bar, [BlockSize BlockSize], 'distinct');
     
    U = X_bar;
    
    for ii = 1:Inloop
        D = ATA*X_hat - ATy + mu*(X_hat - U - B);
        DTD = D'*D;
        G = D'*(ATA + mu*IM)*D;
        Step_Matrix = abs(DTD./G); 
       Step_length = diag(diag(Step_Matrix));
        X = X_hat - D*Step_length;
        X_hat = X;  
   end
    
    % D = ATy   +    mu*(U  +  B);
 %    Q = ATA   +    mu*IM;
     
  %   X =   Q\D;
    M = X_hat - B;
    aa = im2col(OrgImg, [BlockSize BlockSize], 'distinct');
    cc  =   aa - M;
    cc = col2im(cc, [BlockSize BlockSize], [NumRows NumCols], 'distict');
    All_Error_Brain_01{i} = cc;
    
    B = B - (X - U);
    
    CurImg = col2im(X, [BlockSize BlockSize], [NumRows NumCols], 'distict');
    fprintf('IterNum = %d, PSNR = %0.2f,FSIM = %0.2f\n',i,csnr(CurImg,OrgImg,0,0),FeatureSIM(CurImg,OrgImg));
    PSNRI(i) =csnr(CurImg,OrgImg,0,0);
    %ALSB_Rec = strcat(OrgName,'_Subrate_',num2str(Subrate),'_Iterm_',num2str(i),'_NL_CSR_','_PSNR_',num2str(PSNRI(i)),'.png');
   % imwrite(uint8(CurImg),strcat('F:\SBI_NLSC_CS_MAX\Results\',ALSB_Rec));
     if(i>1)
         
          if(PSNRI(i)-PSNRI(i-1)<=0.005)
            break;
          end
    
     end
      
end

RecImg = col2im(X, [BlockSize BlockSize], [NumRows NumCols], 'distict');

PSN_Result  = csnr(RecImg,OrgImg,0,0);
FSIM_Result = FeatureSIM(RecImg,OrgImg);
SSIM_Result = cal_ssim(RecImg,OrgImg,0,0);

end

