%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%��k�ļ�����ȡ�����Ա��ã�������Ԫ��������Ϣ��elem����Ԫ��ţ����������������ڵ㣩���ڵ�������Ϣ��node
%ע�������k�ļ�����ls-prepost���ֱ�ӵ�����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [node,elem]=read_k(file)

fid=fopen(file,'r');
kfile=textscan(fid,'%s','delimiter','\n');  %��ȡΪ1X1��cell
kfile=[kfile{:}];                           %ת����30000X1��cell
fclose(fid);

fid=fopen(file,'r');
flag=textscan(fid,'%c%*[^\n]');           %��ȡÿ�е�һ���ַ���Ϊ1X1��cell
flag=[flag{:}];                           %ת����30000X1��cell
fclose(fid);
[line_position,colum_position]=find(flag=='*'|flag=='$');    %����*��$��������λ��,colum_positionΪ����
clear colum_position ;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%��ȡ�ڵ���Ϣ���洢��node��
[exist_node,node_start]=ismember('*NODE',kfile); %����*NODE������λ�ã�exist��ʾ�������node_start��ʾλ������
[x_node,y_node]=find(line_position==node_start);      %x��ʾ*NODE����������
node_end=line_position(x_node+2);                %����*NODE��Ϣ����λ��
read_times=node_end-node_start-2;           %����k�ļ���ʽ������ڵ���������*NODE ��*END����3��ע����

[nid,xcor,ycor,zcor,tc,rc]=textread(file,'%n%f%f%f%f%f',read_times,'headerlines',node_start+1);%��'%n%f%f%f'��ʽ��ȡ20�Σ���119���Ժ�ʼ

node=[nid,xcor,ycor,zcor,tc,rc];
clear nid xcor ycor zcor tc rc read_times x_node y_node exist_node node_start node_end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%��ȡ��Ԫ����������ֻ��ʵ�嵥Ԫ����Ϣ���洢��elem��
[exist_element,element_start]=ismember('*ELEMENT_SHELL',kfile); %����*ELEMENT_SHELL������λ�ã�exist��ʾ�������node_start��ʾλ������
[x_element,y_element]=find(line_position==element_start);      %x��ʾ*NODE����������
element_end=line_position(x_element+2);                %����*NODE��Ϣ����λ��
read_times=element_end-element_start-2;           %����k�ļ���ʽ������ڵ���������*NODE ��*END����3��ע����
[eid,pid,n1,n2,n3,n4,n5,n6,n7,n8]=textread(file,'%n%n%n%n%n%n%n%n%n%n',read_times,'headerlines',element_start+1);%��'%n%f%f%f'��ʽ��ȡָ���Σ���ָ��λ���Ժ�ʼ

elem=[eid,pid,n1,n2,n3,n4,n5,n6,n7,n8];
clear eid pid n1 n2 n3 n4 n5 n6 n7 n8 read_times exist_element x_element y_element flag line_position element_start element_end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%