function  par  =  Parameters_setting( nSig,mm)
par.method    =   1;%方法1
par.nSig      =   nSig;%噪声方差
par.iters     =   1;%迭代次数
par.eps       =   1e-8;%迭代阀值
par.cls_num   =   70; %70个聚类 

if nSig<=30
    %par.c1        =   0.64;         % 0.57 this is regularization parameter
    par.c1        =   2; 
else    
    par.c1        =   0.64;     
end
par.lamada        =   0.23;  % 0.36
par.hh            =   12;

if nSig <= 10
    par.c1        =   0.56;   
    par.lamada    =   0.022;
    
    par.sigma     =   1.7;  
    par.win       =   6;
    par.nblk      =   13;           
    par.hp        =   75;
    par.K         =   1;
    par.m_num     =   240;
elseif nSig<=15
    par.c1        =   0.59;   
    par.lamada    =   0.22;
    
    par.sigma     =   1.8;
    par.win       =   6;
    par.nblk      =   13;           
    par.hp        =   75;
    par.K         =   5;
    par.m_num     =   240;    
elseif nSig <=30
    par.sigma     =   2.0;
    par.win       =   6;%窗口大小
    %par.win       =   50;%窗口大小
    par.nblk      =   16;
    par.hp        =   80;       %  80
    par.K         =   3;
    par.m_num     =   250;
elseif nSig<=50
    par.c1        =   0.64;    
    
    par.sigma     =   2.4;
    par.win       =   6;
    par.nblk      =   18;
    par.hp        =   90;
    par.K         =   4;
    par.m_num     =   300;
    par.lamada    =   0.26;    
else
    par.sigma     =   2.4;
    par.win       =   6;
    par.nblk      =   20;
    par.hp        =   95;
    par.K         =   4;
    par.m_num     =   300;
    par.lamada    =   0.26;
end

