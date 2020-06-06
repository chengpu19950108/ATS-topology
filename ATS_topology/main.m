%����˵��/Chinese
%������������ƽ��Ӧ�������Ż������Ż����������ҪΪ1��2.�����������������ṩ����������Ҫ����������������Ҫ���Ĳ��ֳ�������
%�ڵ��Ų�����20000��������Ҫ��correct_node�ļ���refresh�ļ��е�20000����Ϊ��С������ŵ���
%ע�⣺����������������ȫ�غϵ�����ֱ��첿��1��2������Ϊ�˷��㵥Ԫ��Ʊ����ĸ��£�����֤���º��������к���������Ժͱ߽��������������ÿ��ܶԶ��ߵ�������һ������


%Ӣ��˵��/English
%the ATS-topology is used for the optimization of connection joints, the two parts of the joints are numbered as 1 and 2. The codes illustrated 
% here can only be used for this example here. When applicated in other examples, the FE model and some parameters here should be corrected.

%The nodes number should not more than 20000(for the proper connection conditions during the iterations),see below.

%Attention: in this example, two completely overlapping grids are used to construct parts 1 and 2, which is to facilitate the updating of design variables,
% and ensure the reasonable grid consecutiveness and edge condition
%This setting can be difficult for the reader to understand.

clear;
clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%���Ʋ����ĳ�ʼ��/set parameters
nit=50;                 %������������/max iteration times
mvpm1=1.05;             %�ƶ�����1��move parameter 1,����������Ϣ�ж��Ƿ��ƶ��Ĳ���/a parameter in local control rules(local convergence)
mvpm2=0.95;             %�ƶ�����2��move parameter 2,���ݵ�ǰ��ԪӦ������ƽ��Ӧ�����ж��Ƿ��ƶ��Ĳ���/a parameter in local control rules(local convergence)
scale=1;                %����ϵ������ǿ���ƶ��ĵ�Ԫ����������ʹ֮�ڽ������ĵ����в�����Ϊ���γɵ�͹����С��������/strengthening factor
ratio=1.1;              %Ӧ���ܱ�������ϵ��,��֤���������ڹ��ܺʹ�С�ϲ�𲻻����/ratio control factor, ensure the differences in the sizes and carrying capacities in Part 1 and Part 2 were not too large
r=0.5;                  %���˰뾶/neighborhood radiu
base_ratio=5;           %�Ի�����Ԫ������ϵ��/strengthening factor for base elements


input('\n��ѡ��Ҫ�����k�ļ����� Enter ������ѡ��Ի���(input K file for ls-dyna)\n')     %open K file(FE model)
[file,dir]=uigetfile('../*.k');
[dir_tem,~,ext]=fileparts(file);
while ~(strcmp(ext,'.k'))
    input('\nֻ�ܴ�����Ls-dyna����".k"��չ����ʽ���ļ���������ѡ��\n')
    [file,dir]=uigetfile('../*.k');
    [dir_tem,~,ext]=fileparts(file);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%�����ļ��󣬽��нڵ�͵�Ԫ��Ϣ��������������һ��ls-dyna���㣬�õ�ԭģ�͵ļ�����
%input the K file and read the node/elements informations
path=sprintf('%s%s',dir,file);
copyfile(path,cd);                          
sprintf('\nѡȡk�ļ��ɹ���\n');
clear dir name ext;
[node,elem]=read_k(file);                   %the function "read_k" is used to read the FE model of the original structure
[elem,elem_1,elem_2]=correct_node(file,elem,node);
sprintf('\nk�ļ���ʼ����ɣ�\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%��õ�Ԫ������Ϣ
%get the neighborhood informations

node_reorg=zeros(max(node(:,1)),6);         %��node�����������սڵ����������У���x�Žڵ���node_reorg�ĵ�x�����ݾ�Ϊ��/reshape the node matrix for further calculation
for nid=1:size(node,1)
    node_reorg(node(nid,1),:)=node(nid,:);
end

elem_reorg=zeros(max(elem(:,1)),10);
for eid=1:size(elem,1)                      %��elem�����������սڵ����������У���x�Žڵ���node_reorg�ĵ�x�����ݾ�Ϊ��/reshape the element matrix for further calculation
    elem_reorg(elem(eid,1),:)=elem(eid,:);
end
clear eid nid;

elem_2(:,3:6)=elem_2(:,3:6)-20000;          %Ϊ����2�����µĽڵ��ţ�������������е�Ԫ����״̬�ĸ���/renumber the node numbers of part 2(this is necessary in the process of updating design varaibles)
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

for eid=1:size(elem12,1)                               %Ѱ��ÿ����Ԫ������Ԫ/find the neighbors of every elements
    dist_x=elem_pos(:,3)-elem_pos(eid,3);
    dist_y=elem_pos(:,4)-elem_pos(eid,4);
    dist=sqrt(dist_x.*dist_x+dist_y.*dist_y);
    row=find(dist<r);
    neighbor{eid}=row;
end

base_elem=base_struct(elem_pos);              %���ú�������ȡ���ṹ�ĵ�Ԫ/get base elements

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
   if i==1                              %��ʼ�������󣬳�ֵȫ����ֵΪ0/initialize the matrix in this program
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
   copyfile(file,sub_path);                    %��ָ��k�ļ����Ƶ�����������·����/copy the K file to the current path
    
   sprintf('\n���ڽ��е�%d�ε���\n',i)
   kfile_dir=sprintf('%s\\%s',sub_path,file);
   S = lsdyna.simulation(kfile_dir);           %���ÿ�Դ�������ls-dyna����/'lsdyna.simulation()' is an program to call ls-dyna solver in matlab
   S.run;                                      %����Ԫ����/FE analysis
   outfile=sprintf('%s\\%s',sub_path,'elout'); %��¼elout�ļ���·�����ļ�����������ȡ����ļ��ĺ����������/the file of FEA result based on elements
   nodfile=sprintf('%s\\%s',sub_path,'nodout');%�ڵ���Ϣ���ļ�/the file of FEA result based on nodes
   
   [s_s]=read_stress_strain(outfile);          %���ú�����ȡelout�ļ��������ԪӦ��Ӧ����Ϣ/read the file "elout"(FEA result)
   
   fid=fopen(nodfile,'r');                     %����ѭ������element��node��Ϣ���ֵ�λ�ã��ļ�ָ��λ�ã�/read the file "nodout"(FEA result)
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
   
   %�������vonmiseӦ��/calculate vonmise stress,below
   von_mises=sqrt(((s_s(:,3)-s_s(:,4)).^2+(s_s(:,4)-s_s(:,5)).^2+(s_s(:,3)-s_s(:,5)).^2+s_s(:,6).^2*6)/2);
   [row1,col1]=find(s_s(:,2)==1);
   [row2,col2]=find(s_s(:,2)==2);
   von_mises(elem_edge,:)=0;
   von_mises1=von_mises(row1,:);
   von_mises1=sort(von_mises1);
   von_mises2=von_mises(row2,:);
   von_mises2=sort(von_mises2);
   
   %�������vonmiseӦ��/calculate vonmise strain,below
   v_strain=sqrt(2/9*(2*s_s(:,7).^2+2*s_s(:,8).^2-2*s_s(:,7).*s_s(:,8)+6*s_s(:,9).^2));
   v_strain(elem_edge)=0;
   v_strain1=v_strain(row1,:);
   v_strain1=sort(v_strain1);
   v_strain2=v_strain(row2,:);
   v_strain2=sort(v_strain2);
   
   %��������ЧӦ���͵�ЧӦ��/calculate max stess and strain,below
   max_stress1(i)=mean(von_mises1(end-2:end));
   max_stress2(i)=mean(von_mises2(end-2:end));
   max_stress(i)=max(max_stress1(i),max_stress1(i));
   max_strain1(i)=mean(v_strain1(end-2:end));
   max_strain2(i)=max(v_strain2(end-2:end));
   max_strain(i)=max(max_strain1(i),max_strain1(i));
   
   energy_density=(s_s(:,3).*s_s(:,7)+s_s(:,4).*s_s(:,8)+s_s(:,6).*s_s(:,9))/2;          %���㵥ԪӦ�����ܶ�/energy density in iteration i
   density_center=energy_density;
   energy_density1=energy_density(row1,:);
   energy_density2=energy_density(row2,:);
   
   internal_energy(i)=sum(density_center)*0.01;                                          %�����i�ε�������Ӧ����/total strain energy in iteration i
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
   title(['ǰ',num2str(i),'�ε����е���Ӧ���ܱ仯����'])%curve of total strain energy
   
   figure(2)
   plot(1:i,max_stress(1:i),'k',1:i,max_stress1(1:i),'r',1:i,max_stress2(1:i),'b')
   title(['ǰ',num2str(i),'�ε����е����Ӧ���仯����'])%curve of max stress
   
   figure(3)
   plot(1:i,max_strain(1:i),'k',1:i,max_strain1(1:i),'r',1:i,max_strain2(1:i),'b')
   title(['ǰ',num2str(i),'�ε����е����Ӧ��仯����'])%curve of max strain
   
   figure(4)
   plot(1:i,ydisp(1:i),'k')
   title(['ǰ',num2str(i),'�ε����еĹؼ���λ������'])%curve of displacement of key point
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
   
   energy_density(base_elem)=base_ratio*energy_ave1(i);
   for eid=1:size(elem12,1)
    partid_cont{eid}=elem(neighbor{eid},2);                                              %����elem_cont�и�����Ԫ�����Ĳ������/attribution of every elements(belong to which part)
    density_cont{eid}=energy_density(neighbor{eid});                                     %Ӧ�����ܶȵ�������Ϣ/strain energy in neighborhood
   end
   
    [times_1,times_2]=cellfun(@times12,partid_cont,'UniformOutput',false);                %ͳ�������ڲ���1�Ͳ���2��Ԫ�ĸ���/element numbers of part 1 and 2 in neighborhood
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
    density_cont{eid}=energy_ave(neighbor{eid});                            %���˺�Ӧ�����ܶȵ�������Ϣ/strain energy density after filtering
    std_cont{eid}=std12(neighbor{eid});                                           
    end
    
   neib_eneg2=cellfun(@times,parameter2,density_cont,'UniformOutput',false);
   neib_std2=cellfun(@times,parameter2,std_cont,'UniformOutput',false);
   pm2=cellfun(@sum,neib_eneg2);                                            %pm2Ϊĳ����Ԫ��Χ����2���������ܺ�/pm2 is the total strain energy of part 2 in a neighborhood
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
      
   crct1=zeros(size(elem12,1),1);             %���ڵ�Ԫ�����ľ���/a matrix used for element strengthening
   
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%�жϵ������õ�ģʽ�������и���.���ֲ����ƹ���
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
   title(['��',num2str(i),'�ε�����Ľṹ��״'])
   hold off
   set(gca,'YDir','reverse')
   saveas(gcf,[imgpath,'/','image',num2str(i),'.jpg']);
   close gcf
   
   write_k(file,elem,elem_fid);         %update the FE model
   
end







