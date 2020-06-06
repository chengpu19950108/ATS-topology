%中文说明/Chinese
%本程序适用于平面应变问题优化，待优化部件编号需要为1和2.本代码适用于这里提供的算例，若要计算其他算例，需要更改部分常数参数
%节点编号不大于20000，否则需要将correct_node文件及refresh文件中的20000更改为不小于最大编号的数
%注意：本算例采用两层完全重合的网格分别构造部件1和2，这是为了方便单元设计变量的更新，并保证更新后的网格具有合理的连贯性和边界条件。这种设置可能对读者的理解带来一定困难


%英文说明/English
%the ATS-topology is used for the optimization of connection joints, the two parts of the joints are numbered as 1 and 2. The codes illustrated 
% here can only be used for this example here. When applicated in other examples, the FE model and some parameters here should be corrected.

%The nodes number should not more than 20000(for the proper connection conditions during the iterations),see below.

%Attention: in this example, two completely overlapping grids are used to construct parts 1 and 2, which is to facilitate the updating of design variables,
% and ensure the reasonable grid consecutiveness and edge condition
%This setting can be difficult for the reader to understand.

clear;
clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%控制参数的初始化/set parameters
nit=50;                 %迭代次数上限/max iteration times
mvpm1=1.05;             %移动参数1，move parameter 1,根据邻域信息判断是否移动的参数/a parameter in local control rules(local convergence)
mvpm2=0.95;             %移动参数2，move parameter 2,根据当前单元应变能与平均应变能判断是否移动的参数/a parameter in local control rules(local convergence)
scale=1;                %增幅系数，对强制移动的单元进行增幅，使之在接下来的迭代中不会因为新形成的凸包过小而被消除/strengthening factor
ratio=1.1;              %应变能比例控制系数,保证两个部件在功能和大小上差别不会过大/ratio control factor, ensure the differences in the sizes and carrying capacities in Part 1 and Part 2 were not too large
r=0.5;                  %过滤半径/neighborhood radiu
base_ratio=5;           %对基础单元的增幅系数/strengthening factor for base elements


input('\n请选择要导入的k文件，按 Enter 键开启选择对话框：(input K file for ls-dyna)\n')     %open K file(FE model)
[file,dir]=uigetfile('../*.k');
[dir_tem,~,ext]=fileparts(file);
while ~(strcmp(ext,'.k'))
    input('\n只能打开用于Ls-dyna求解的".k"扩展名格式的文件，请重新选择：\n')
    [file,dir]=uigetfile('../*.k');
    [dir_tem,~,ext]=fileparts(file);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%导入文件后，进行节点和单元信息的修正，并运行一次ls-dyna计算，得到原模型的计算结果
%input the K file and read the node/elements informations
path=sprintf('%s%s',dir,file);
copyfile(path,cd);                          
sprintf('\n选取k文件成功！\n');
clear dir name ext;
[node,elem]=read_k(file);                   %the function "read_k" is used to read the FE model of the original structure
[elem,elem_1,elem_2]=correct_node(file,elem,node);
sprintf('\nk文件初始化完成！\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%获得单元邻域信息
%get the neighborhood informations

node_reorg=zeros(max(node(:,1)),6);         %将node矩阵行数按照节点编号重新排列，无x号节点则node_reorg的第x行数据均为零/reshape the node matrix for further calculation
for nid=1:size(node,1)
    node_reorg(node(nid,1),:)=node(nid,:);
end

elem_reorg=zeros(max(elem(:,1)),10);
for eid=1:size(elem,1)                      %将elem矩阵行数按照节点编号重新排列，无x号节点则node_reorg的第x行数据均为零/reshape the element matrix for further calculation
    elem_reorg(elem(eid,1),:)=elem(eid,:);
end
clear eid nid;

elem_2(:,3:6)=elem_2(:,3:6)-20000;          %为部件2赋予新的节点编号，这样方便后续中单元归属状态的更新/renumber the node numbers of part 2(this is necessary in the process of updating design varaibles)
elem12=[elem_1;elem_2];
elem_x=reshape(node_reorg(elem12(:,3:6),2),[size(elem12,1),4]);
elem_x=sum(elem_x,2)/4;
elem_y=reshape(node_reorg(elem12(:,3:6),3),[size(elem12,1),4]);
elem_y=sum(elem_y,2)/4;
elem_pos=[elem12(:,1:2),elem_x,elem_y];
center=mean(elem_pos(:,3));
elem_edge=find(abs(elem_pos(:,3)-0.347)>9.5);            
elem_edge1=intersect(elem_1(:,1),elem_edge);             
elem_edge2=intersect(elem_2(:,1),elem_edge);


partid_cont=cell(size(elem12(:,1)));
neighbor=cell(size(elem12(:,1)));
density_cont=cell(size(elem12(:,1)));
std_cont=cell(size(elem12(:,1)));
crct1=zeros(size(elem12,1),1);
crct2=zeros(size(elem12,1),1);
crct3=zeros(size(elem12,1),1);

for eid=1:size(elem12,1)                               %寻找每个单元的邻域单元/find the neighbors of every elements
    dist_x=elem_pos(:,3)-elem_pos(eid,3);
    dist_y=elem_pos(:,4)-elem_pos(eid,4);
    dist=sqrt(dist_x.*dist_x+dist_y.*dist_y);
    row=find(dist<r);
    neighbor{eid}=row;
end

base_elem=base_struct(elem_pos);              %调用函数，获取基结构的单元/get base elements

clear row row_x row_y col_x col_y;

[node,elem]=read_k(file);
mkdir('ilteration_image');
imgpath=sprintf('%s\\%s',cd,'ilteration_image');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%FE analysis(the software: ls-dyna is used to complete this process)

fid=fopen(file,'r');
while ~feof(fid)
    tline=fgetl(fid);
    if strcmp(tline,'*ELEMENT_SHELL')
        tline=fgetl(fid);
        elem_fid=ftell(fid);
    end
end
fclose(fid);

for i=1:nit                 
   if i==1                              %初始化各矩阵，初值全部赋值为0/initialize the matrix in this program
       internal_energy=zeros(nit,1);
       energy1=zeros(nit,1);
       energy2=zeros(nit,1);
       energy_ave1=zeros(nit,1);
       energy_ave2=zeros(nit,1);
       energy_std=zeros(nit,1);
       energy_std1=zeros(nit,1);
       energy_std2=zeros(nit,1);
       mean_std=zeros(nit,1);
       mean_std1=zeros(nit,1);
       mean_std2=zeros(nit,1);
       j=zeros(nit,1);
       j(1:2:end)=1;
       max_stress1=zeros(nit,1);
       max_stress2=zeros(nit,1);
       max_stress=zeros(nit,1);
       
       max_strain=zeros(nit,1);
       max_strain1=zeros(nit,1);
       max_strain2=zeros(nit,1);
       
       xdisp=zeros(nit,1);
       ydisp=zeros(nit,1);
       normal_move=zeros(nit,1);
       force_move=zeros(nit,1);
   end
   
   subfolder=sprintf('%s%d','ilteration_',i);
   mkdir(subfolder);
   sub_path=sprintf('%s\\%s',cd,subfolder);
   copyfile(file,sub_path);                    %将指定k文件复制到上述创建的路径里/copy the K file to the current path
    
   sprintf('\n正在进行第%d次迭代\n',i)
   kfile_dir=sprintf('%s\\%s',sub_path,file);
   S = lsdyna.simulation(kfile_dir);           %调用开源程序进行ls-dyna计算/'lsdyna.simulation()' is an program to call ls-dyna solver in matlab
   S.run;                                      %有限元分析/FE analysis
   outfile=sprintf('%s\\%s',sub_path,'elout'); %记录elout文件的路径和文件名，用作读取结果文件的函数输入参数/the file of FEA result based on elements
   nodfile=sprintf('%s\\%s',sub_path,'nodout');%节点信息的文件/the file of FEA result based on nodes
   
   [s_s]=read_stress_strain(outfile);          %调用函数读取elout文件，输出单元应力应变信息/read the file "elout"(FEA result)
   
   fid=fopen(nodfile,'r');                     %以下循环查找element和node信息出现的位置（文件指针位置）/read the file "nodout"(FEA result)
   while ~feof(fid)
       tline=fgetl(fid);
       if size(tline,2)>20&&strcmp(tline(15:20),'x-disp')
           tline=fgetl(fid);
           node_disp=str2num(tline);
       end
   end
   fclose(fid);
   
   xdisp(i)=node_disp(2);
   ydisp(i)=node_disp(3);
   
   %下面计算vonmise应力/calculate vonmise stress,below
   von_mises=sqrt(((s_s(:,3)-s_s(:,4)).^2+(s_s(:,4)-s_s(:,5)).^2+(s_s(:,3)-s_s(:,5)).^2+s_s(:,6).^2*6)/2);
   [row1,col1]=find(s_s(:,2)==1);
   [row2,col2]=find(s_s(:,2)==2);
   von_mises(elem_edge,:)=0;
   von_mises1=von_mises(row1,:);
   von_mises1=sort(von_mises1);
   von_mises2=von_mises(row2,:);
   von_mises2=sort(von_mises2);
   
   %下面计算vonmise应变/calculate vonmise strain,below
   v_strain=sqrt(2/9*(2*s_s(:,7).^2+2*s_s(:,8).^2-2*s_s(:,7).*s_s(:,8)+6*s_s(:,9).^2));
   v_strain(elem_edge)=0;
   v_strain1=v_strain(row1,:);
   v_strain1=sort(v_strain1);
   v_strain2=v_strain(row2,:);
   v_strain2=sort(v_strain2);
   
   %计算最大等效应力和等效应变/calculate max stess and strain,below
   max_stress1(i)=mean(von_mises1(end-2:end));
   max_stress2(i)=mean(von_mises2(end-2:end));
   max_stress(i)=max(max_stress1(i),max_stress1(i));
   max_strain1(i)=mean(v_strain1(end-2:end));
   max_strain2(i)=max(v_strain2(end-2:end));
   max_strain(i)=max(max_strain1(i),max_strain1(i));
   
   energy_density=(s_s(:,3).*s_s(:,7)+s_s(:,4).*s_s(:,8)+s_s(:,6).*s_s(:,9))/2;          %计算单元应变能密度/energy density in iteration i
   density_center=energy_density;
   energy_density1=energy_density(row1,:);
   energy_density2=energy_density(row2,:);
   
   internal_energy(i)=sum(density_center)*0.01;                                          %计算第i次迭代的总应变能/total strain energy in iteration i
   energy1(i)=sum(energy_density1)*0.01;
   energy2(i)=sum(energy_density2)*0.01;
   energy_std(i)=std(density_center,1);
   energy_std1(i)=std(energy_density1,1);
   energy_std2(i)=std(energy_density2,1);

   energy_ave1(i)=energy1(i)/size(elem_1,1)*100;
   energy_ave2(i)=energy2(i)/size(elem_2,1)*100;
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   figure(1)
   plot(1:i,internal_energy(1:i),'k',1:i,energy1(1:i),'r',1:i,energy2(1:i),'b')
   title(['前',num2str(i),'次迭代中的总应变能变化曲线'])%curve of total strain energy
   
   figure(2)
   plot(1:i,max_stress(1:i),'k',1:i,max_stress1(1:i),'r',1:i,max_stress2(1:i),'b')
   title(['前',num2str(i),'次迭代中的最大应力变化曲线'])%curve of max stress
   
   figure(3)
   plot(1:i,max_strain(1:i),'k',1:i,max_strain1(1:i),'r',1:i,max_strain2(1:i),'b')
   title(['前',num2str(i),'次迭代中的最大应变变化曲线'])%curve of max strain
   
   figure(4)
   plot(1:i,ydisp(1:i),'k')
   title(['前',num2str(i),'次迭代中的关键点位移曲线'])%curve of displacement of key point
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
   
   energy_density(base_elem)=base_ratio*energy_ave1(i);
   for eid=1:size(elem12,1)
    partid_cont{eid}=elem(neighbor{eid},2);                                              %返回elem_cont中各个单元所属的部件编号/attribution of every elements(belong to which part)
    density_cont{eid}=energy_density(neighbor{eid});                                     %应变能密度的邻域信息/strain energy in neighborhood
   end
   
    [times_1,times_2]=cellfun(@times12,partid_cont,'UniformOutput',false);                %统计邻域内部件1和部件2单元的个数/element numbers of part 1 and 2 in neighborhood
    times_1=cell2mat(times_1);
    times_2=cell2mat(times_2);
   
   parameter2=cellfun(@minus1,partid_cont,'UniformOutput',false);                        %get the strain energy of part 2 after filtering
   neib_eneg2=cellfun(@times,parameter2,density_cont,'UniformOutput',false);             
   neib_eneg2=cellfun(@move0,neib_eneg2,'UniformOutput',false);
   pm2=cellfun(@mean,neib_eneg2,'UniformOutput',false);
   stdd2=cellfun(@std1,neib_eneg2,'UniformOutput',false);
   
   parameter1=cellfun(@minus_2,partid_cont,'UniformOutput',false);                       %get the strain energy of part 1 after filtering
   neib_eneg1=cellfun(@times,parameter1,density_cont,'UniformOutput',false);              
   neib_eneg1=cellfun(@move0,neib_eneg1,'UniformOutput',false);
   pm1=cellfun(@mean,neib_eneg1,'UniformOutput',false);
   stdd1=cellfun(@std1,neib_eneg1,'UniformOutput',false);
   
   pm1=cell2mat(pm1);
   pm2=cell2mat(pm2);
   stdd1=cell2mat(stdd1);
   stdd2=cell2mat(stdd2);
   stdd1(isnan(stdd1)==1)=0;
   stdd2(isnan(stdd2)==1)=0;
  
   
   energy_ave=[pm1(1:size(elem_1,1));pm2(size(elem_1,1)+1:end)];
   local_std1=stdd1(1:size(elem_1,1));
   local_std2=stdd1(1:size(elem_2,1));
   std12=[local_std1;local_std2];
   energy_ave(isnan(energy_ave)==1)=0;
   
   
   energy_ave=energy_ave+crct1+crct2+crct3;
   crct3=crct2*0.4;
   crct2=crct1*0.4;
   
    for eid=1:size(elem12,1)
    density_cont{eid}=energy_ave(neighbor{eid});                            %过滤后应变能密度的邻域信息/strain energy density after filtering
    std_cont{eid}=std12(neighbor{eid});                                           
    end
    
   neib_eneg2=cellfun(@times,parameter2,density_cont,'UniformOutput',false);
   neib_std2=cellfun(@times,parameter2,std_cont,'UniformOutput',false);
   pm2=cellfun(@sum,neib_eneg2);                                            %pm2为某个单元周围属于2部件的内能和/pm2 is the total strain energy of part 2 in a neighborhood
   neib_eneg2=cellfun(@move0,neib_eneg2,'UniformOutput',false);
   neib_std2=cellfun(@move0,neib_std2,'UniformOutput',false);
   pm2_ave=cellfun(@mean,neib_eneg2,'UniformOutput',false);
   pm_std2=cellfun(@mean,neib_std2,'UniformOutput',false);
   
   neib_eneg1=cellfun(@times,parameter1,density_cont,'UniformOutput',false);%similar as before codes
   neib_std1=cellfun(@times,parameter1,std_cont,'UniformOutput',false);
   pm1=cellfun(@sum,neib_eneg1);
   neib_eneg1=cellfun(@move0,neib_eneg1,'UniformOutput',false);
   neib_std1=cellfun(@move0,neib_std1,'UniformOutput',false);
   pm1_ave=cellfun(@mean,neib_eneg1,'UniformOutput',false);
   pm_std1=cellfun(@mean,neib_std1,'UniformOutput',false);
   
   pm1_ave=cell2mat(pm1_ave);
   pm2_ave=cell2mat(pm2_ave);
   pm_std1=cell2mat(pm_std1);
   pm_std2=cell2mat(pm_std2);
   
   pm_std1=pm_std1./pm1_ave;
   pm_std2=pm_std2./pm2_ave;
      
   crct1=zeros(size(elem12,1),1);             %用于单元增幅的矩阵/a matrix used for element strengthening
   
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%判断迭代所用的模式，并进行更新.即局部控制规则
%local control rule
       for eid=1:size(elem12,1)
           switch elem(eid,2)
               case 1
                   if times_2(eid)==0||energy_ave(eid)>energy_ave1(i)||energy_ave1(i)>ratio*energy_ave2(i)
                       %do nothing, design variable will not be updated
                   elseif pm2(eid)>pm1(eid)
                       if pm2_ave(eid)>mvpm1*energy_ave2(i)
                           elem(eid,2)=2;                      %the design variable is updated
                           elem(eid,3:6)=elem(eid,3:6)+20000;
                           normal_move(i)=normal_move(i)+1;
                       elseif pm2_ave(eid)<mvpm2*energy_ave2(i)
                           elem(eid,2)=2;
                           elem(eid,3:6)=elem(eid,3:6)+20000;
                           crct1(eid)=energy_ave1(i)*scale;
                           force_move(i)=force_move(i)+1;
                       end
                   end
                   
               case 2
                   if times_1(eid)==0||energy_ave(eid)>energy_ave2(i)||energy_ave2(i)>ratio*energy_ave1(i)
                       %do nothing, design variable will not be updated
                   elseif pm1(eid)>pm2(eid)
                       if pm1_ave(eid)>mvpm1*energy_ave1(i)
                           elem(eid,2)=1;
                           elem(eid,3:6)=elem(eid,3:6)-20000;
                           normal_move(i)=normal_move(i)+1;
                       elseif pm1_ave(eid)<mvpm2*energy_ave1(i)
                           elem(eid,2)=1;
                           elem(eid,3:6)=elem(eid,3:6)-20000;
                           crct1(eid)=energy_ave2(i)*scale;
                           force_move(i)=force_move(i)+1;
                       end
                   end
           end
       end
   
   [row1,col1]=find(elem(:,2)==1);      %get the new structure after iteration
   elem_1=elem(row1,:);                 
   [row2,col2]=find(elem(:,2)==2);      
   elem_2=elem(row2,:);                 
   fl=elem_1(:,3:6);
   fr=elem_2(:,3:6)-20000;
   
   
   figure;                              %draw new structure figures
   hold on
   patch('Faces',fl,'Vertices',node(:,2:3),'FaceColor','red');
   patch('Faces',fr,'Vertices',node(:,2:3),'FaceColor','blue');
   title(['第',num2str(i),'次迭代后的结构形状'])
   hold off
   set(gca,'YDir','reverse')
   saveas(gcf,[imgpath,'/','image',num2str(i),'.jpg']);
   close gcf
   
   write_k(file,elem,elem_fid);         %update the FE model
   
end







