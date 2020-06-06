%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%��ȡelout�ļ�����Ϣ�������elem_stress_strain,����1-9�зֱ�Ϊ��Ԫ��ţ�������ţ�ƽ��Ӧ�������7��Ӧ��Ӧ�����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [element_stress_strain]=read_stress_strain(outfile)
fid=fopen(outfile,'r');
element_stress_original=textscan(fid,'%s','delimiter','\n');  %��ȡΪ1X1��cell
element_stress_original=[element_stress_original{:}];
fclose(fid);
stress_start=find(strcmp(element_stress_original,'element  materl(global)'));    %�ҵ���Ԫ��Ϣ��ʼ��λ��
empty_lines=find(strcmp(element_stress_original,''));%��ȡ����λ�ã������¾��ҵ�stress��strain��ʼ/����λ��
stress_start_position_in_emptyline=find(abs(empty_lines-stress_start(1))<2);%Ϊ�˶�λ��empty_lines��stress_start��λ�ã�������ȷ��stress����λ�ú�strain��ʼλ�á�
stress_end=empty_lines(stress_start_position_in_emptyline+1)-1;%stress�Ľ���λ�ã����һ�У�
read_times=(stress_end-stress_start(1)-2)/2;
for i=1:length(stress_start)
    [el_id,part_id,~,~,~,sig_xx,sig_yy,sig_zz,sig_xy,~,~,~]=...
        textread(outfile,'%8d - %7d %4d - %3d %8c %12f %12f %12f %12f %12f %12f %12f',read_times,'delimiter','\n','headerlines',stress_start(i)+2);
    [~,~,eps_xx1,eps_yy1,~,eps_xy1,~,~,~,~,~,~,~,~]=...
        textread(outfile,'%8d - %7d lower ipt %12f %12f %12f %12f %12f %12f upper ipt %12f %12f %12f %12f %12f %12f',read_times,'delimiter','\n','headerlines',stress_start(i)+read_times*2+5);
end

element_stress_strain=[el_id,part_id,sig_xx,sig_yy,sig_zz,sig_xy,eps_xx1,eps_yy1,eps_xy1];%1-9�зֱ�Ϊ��el_id,part_id,sig_xx,sig_yy,sig_zz,sig_xy,eps_xx1,eps_yy1,eps_xy1��

% [row1,col1]=find(element_stress_strain(:,2)==1);                   %Ѱ��part���Ϊ1�ĵ�Ԫλ�ã���left�����ĵ�Ԫ
% elem_stress1=element_stress_strain(row1,:);                        %
% 
% [row2,col2]=find(element_stress_strain(:,2)==2);                   %Ѱ��part���Ϊ2�ĵ�Ԫλ�ã���right�����ĵ�Ԫ
% elem_stress2=element_stress_strain(row2,:);                        %elem_2Ϊright��Ԫ


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fprintf('\n element_stress_strain��1-9�зֱ�Ϊ��\n\n\t��Ԫ���,�������, sig_xx ,sig_yy ,sig_zz ,sig_xy ,eps_xx ,eps_yy ,eps_xy\n\n����4��Ӧ��������3��Ӧ�����-ƽ��Ӧ�����⣩\n\n');

