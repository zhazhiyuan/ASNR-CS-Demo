
function   [cls_idx,vec,cls_num]  = Clustering(Y, cls_num, itn, m_num)
%Y是抹去高通图像块里面的强度方差v<delta的图像块，共43172块
%cls_num＝70共有70个质心
%迭代次数为itn=14
%m_num=250
Y         =   Y';%Y is 43172*49 每行是一个图像块
[L b2]    =   size(Y);%L=43172,b2=49
P         =   randperm(L);%P is 43172个随机数
P2        =   P(1:cls_num);%P is P中前70个随机数
vec       =   Y(P2(1:end), :);%70*49初始化质心，每一行代表一个质心

for i = 1 : itn%迭代次数14次
    
    mse       =  0;
    cnt       =  zeros(1, cls_num);  %1*70 记录着每个聚类中有多少个图像块
    
    v_dis    =   zeros(L, cls_num);%43172*70
    for  k = 1 : cls_num
        v_dis(:, k) = (Y(:,1) - vec(k,1)).^2;
        for c = 2:b2
            v_dis(:,k) =  v_dis(:,k) + (Y(:,c) - vec(k,c)).^2;
        end
    end
    %if k=1,则此时就是求得的v_dis(43172,1)是每个图像块减去第一个质心的值
    %其中 v_dis(:, k) = (Y(:,1) - vec(k,1)).^2 为每个图像块的第一个像素减去第一个质心的第一个像素的值
   % v_dis(:,k) =  v_dis(:,k) + (Y(:,c) - vec(k,c)).^2为每个图像块的第2：49个像素减去第一个质心的2：49像素的值
   %则最终的输出v_dis(:,1)是每个图像块减去第一个质心的值，共有43172*1个值
   %同理，如果k=2，则最终的输出v_dis(:,2)是每个图像块减去第二个质心的值，共有43172*1个值
   %……
   %如果k=70，则最终的输出v_dis(:,70)是每个图像块减去第二个质心的值，共有43172*1个值
   %则最终的v_dis
   %就是43172个图像与70个质心的距离，以列的形式输出，
   %即第一列是43172个图像块与第1个质心的距离，第2列就是43172个图像块与第2个质心的距离等等

    [val cls_idx]     =   min(v_dis, [], 2);%cls_idx =43172*1
    %val是每个图像块减去质心的最小值，cls_idx是每个图像块所对应的质心
    %比如第一个图像块减去质心的最小值所对应该的最小值val(1)=7.44e+04
    %最小值val(1)=7.44e+04所对应的质心cls_idx(1)=70,即第70个质心
    
    [s_idx, seg]   =  Proc_cls_idx( cls_idx );
    %s_idx是每个质心按1号到70号质心排列，每个质心所对应的图像块的编号按照顺序排列
    %seg是找到每个质心里面共有多少块图像块，按照质心顺序对应,即
    %0，280，1738，2276，2471....
    %即1号质心有280个图像块，2号质心有1738－280个图像块
    for  k  =  1 : length(seg)-1%k=1:70
        idx    =   s_idx(seg(k)+1:seg(k+1)); %if k=1, seg(k)+1:seg(k+1)=1:280第一个质心所对应的图像块个数 
        %idx是第1个质心所对应的图像块的编号共280个
        cls    =   cls_idx(idx(1));%if k=1，此时的cls=1，即第1个质心 
       % vec       =   Y(P2(1:end), :) 70*49
       %Y         =   Y';%Y is 43172*49 每行是一个图像块
        vec(cls,:)    =   mean(Y(idx, :));%对第一个质心所对应的280个图像块求均值1*49
        %%%%%%%%求得每个质心所对应图像的均值，用于下次迭代的质心，很重要%%%%%%%%%%%%%
       % cnt       =  zeros(1, cls_num);  %1*70 记录着每个聚类中有多少个图像块
        cnt(cls)      =   length(idx);%cnt(1)=280
    end        
    
    if (i==itn-2)
        [val ind]  =  min( cnt ); 
        while (val<m_num) && (cls_num>=40)
            vec(ind, :)    =  [];
            cls_num       =  cls_num - 1;
            cnt(ind)      =  [];

            [val  ind]    =  min(cnt);
        end        
    end
end
