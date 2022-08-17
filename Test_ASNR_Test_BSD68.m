clc
clear
m_20=0; 
m_30=0;    
m_40=0;  
m_10=0;  
m_50=0; 
All_data_Results_50 = cell(1,200);

All_data_Results_20 = cell(1,200);
All_data_Results_30 = cell(1,200);
All_data_Results_40 = cell(1,200);
All_data_Results_10 = cell(1,200);

for i = 56:68
    
ImgNo =i;

switch ImgNo
            case 1
                filename = 'test001';
            case 2
                filename = 'test002';
            case 3
                filename = 'test003';
            case 4
                filename = 'test004';    
            case 5
                filename = 'test005'; 
                
            case 6
                filename = 'test006';
            case 7
                filename = 'test007';
            case 8
                filename = 'test008';
            case 9
                filename = 'test009';    
            case 10
                filename = 'test010'; 
                
            case 11
                filename = 'test011';
            case 12
                filename = 'test012';
            case 13
                filename = 'test013';     
                
            case 14
                filename = 'test014';
            case 15
                filename = 'test015';
            case 16
                filename = 'test016';
            case 17
                filename = 'test017';    
            case 18
                filename = 'test018'; 
                
            case 19
                filename = 'test019';
            case 20
                filename = 'test020';
            case 21
                filename = 'test021';     
                
            case 22
                filename = 'test022';
            case 23
                filename = 'test023';
            case 24
                filename = 'test024';
            case 25
                filename = 'test025';    
            case 26
                filename = 'test026'; 
                
            case 27
                filename = 'test027';
            case 28
                filename = 'test028';
            case 29
                filename = 'test029';    
            case 30
                filename = 'test030';       
             case 31
                filename = 'test031';   
                
            case 32
                filename = 'test032';
            case 33
                filename = 'test033';
            case 34
                filename = 'test034';
            case 35
                filename = 'test035';    
            case 36
                filename = 'test036'; 
                
            case 37
                filename = 'test037';
            case 38
                filename = 'test038';
            case 39
                filename = 'test039';    
            case 40
                filename = 'test040';                 
                
             case 41
                filename = 'test041';   
                
            case 42
                filename = 'test042';
            case 43
                filename = 'test043';
            case 44
                filename = 'test044';
            case 45
                filename = 'test045';    
            case 46
                filename = 'test046'; 
                
            case 47
                filename = 'test047';
            case 48
                filename = 'test048';
            case 49
                filename = 'test049';    
            case 50
                filename = 'test050';                 
                
              case 51
                filename = 'test051';   
                
            case 52
                filename = 'test052';
            case 53
                filename = 'test053';
            case 54
                filename = 'test054';
            case 55
                filename = 'test055';    
            case 56
                filename = 'test056'; 
                
            case 57
                filename = 'test057';
            case 58
                filename = 'test058';
            case 59
                filename = 'test059';    
            case 60
                filename = 'test060';                
                
              case 61
                filename = 'test061';   
                
            case 62
                filename = 'test062';
            case 63
                filename = 'test063';
            case 64
                filename = 'test064';
            case 65
                filename = 'test065';    
            case 66
                filename = 'test066'; 
                
            case 67
                filename = 'test067';
            case 68
                filename = 'test068' ;                  
end


for m  =   1:4
    
    filename

rate     =    [0.1,0.2,0.3,0.4, 0.5];

Subrate =  rate(m)


IterNum   =   400;

if  Subrate==0.1
 [Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s] =ANSR_CS_Main(filename,IterNum,Subrate);
 m_10= m_10+1;
 s=strcat('A',num2str(m_10));
 All_data_Results_10{m_10}={Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s};
 xlswrite('ANSR_CS_0.1_BSD68_2.xls', All_data_Results_10{m_10},'sheet1',s);
elseif  Subrate==0.2
 [Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s] =ANSR_CS_Main(filename,IterNum,Subrate);
 m_20= m_20+1;
 s=strcat('A',num2str(m_20));
 All_data_Results_20{m_20}={Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s};
 xlswrite('ANSR_CS_0.2_BSD68_2.xls', All_data_Results_20{m_20},'sheet1',s);
 elseif  Subrate==0.3
 [Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s] =ANSR_CS_Main(filename,IterNum,Subrate);
 m_30= m_30+1;
 s=strcat('A',num2str(m_30));
 All_data_Results_30{m_30}={Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s};
 xlswrite('ANSR_CS_0.3_BSD68_2.xls', All_data_Results_30{m_30},'sheet1',s);
elseif  Subrate==0.4
 [Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s] =ANSR_CS_Main(filename,IterNum,Subrate);
 m_40= m_40+1;
 s=strcat('A',num2str(m_40));
 All_data_Results_40{m_40}={Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s};
 xlswrite('ANSR_CS_0.4_BSD68_2.xls', All_data_Results_40{m_40},'sheet1',s);
else
 [Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s] =ANSR_CS_Main(filename,IterNum,Subrate);
 m_50= m_50+1;
 s=strcat('A',num2str(m_50));
 All_data_Results_50{m_50}={Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s};
 xlswrite('ANSR_CS_0.5_BSD68_2.xls', All_data_Results_50{m_50},'sheet1',s);    
    
end


clearvars -except filename i m_20 All_data_Results_20 m_30 All_data_Results_30 m_40 All_data_Results_40 m_10 All_data_Results_10 All_data_Results_50 m_50
end
clearvars -except filename  m_20 All_data_Results_20 m_30 All_data_Results_30 m_40 All_data_Results_40 m_10 All_data_Results_10 All_data_Results_50 m_50
end





         