%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%读取elout文件的信息，输出：elem_stress_strain,包含1-9列分别为单元编号，部件编号，平面应变问题的7个应力应变分量
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [element_stress_strain]=read_stress_strain(outfile)
fid=fopen(outfile,'r');
element_stress_original=textscan(fid,'%s','delimiter','\n');  %读取为1X1的cell
element_stress_original=[element_stress_original{:}];
fclose(fid);
stress_start=find(strcmp(element_stress_original,'element  materl(global)'));    %找到单元信息开始的位置
empty_lines=find(strcmp(element_stress_original,''));%提取空行位置，用于下句找到stress和strain开始/结束位置
stress_start_position_in_emptyline=find(abs(empty_lines-stress_start(1))<2);%为了定位在empty_lines中stress_start的位置，以用于确定stress结束位置和strain开始位置。
stress_end=empty_lines(stress_start_position_in_emptyline+1)-1;%stress的结束位置（最后一行）
read_times=(stress_end-stress_start(1)-2)/2;
for i=1:length(stress_start)
    [el_id,part_id,~,~,~,sig_xx,sig_yy,sig_zz,sig_xy,~,~,~]=...
        textread(outfile,'%8d - %7d %4d - %3d %8c %12f %12f %12f %12f %12f %12f %12f',read_times,'delimiter','\n','headerlines',stress_start(i)+2);
    [~,~,eps_xx1,eps_yy1,~,eps_xy1,~,~,~,~,~,~,~,~]=...
        textread(outfile,'%8d - %7d lower ipt %12f %12f %12f %12f %12f %12f upper ipt %12f %12f %12f %12f %12f %12f',read_times,'delimiter','\n','headerlines',stress_start(i)+read_times*2+5);
end

element_stress_strain=[el_id,part_id,sig_xx,sig_yy,sig_zz,sig_xy,eps_xx1,eps_yy1,eps_xy1];%1-9列分别为：el_id,part_id,sig_xx,sig_yy,sig_zz,sig_xy,eps_xx1,eps_yy1,eps_xy1；

% [row1,col1]=find(element_stress_strain(:,2)==1);                   %寻找part编号为1的单元位置，即left部件的单元
% elem_stress1=element_stress_strain(row1,:);                        %
% 
% [row2,col2]=find(element_stress_strain(:,2)==2);                   %寻找part编号为2的单元位置，即right部件的单元
% elem_stress2=element_stress_strain(row2,:);                        %elem_2为right单元


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fprintf('\n element_stress_strain的1-9列分别为：\n\n\t单元编号,部件编号, sig_xx ,sig_yy ,sig_zz ,sig_xy ,eps_xx ,eps_yy ,eps_xy\n\n（即4个应力分量和3个应变分量-平面应变问题）\n\n');

