%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%打开k文件并读取内容以备用，保留单元连续性信息：elem（单元编号，所属部件，包含节点）；节点坐标信息：node
%注：导入的k文件需由ls-prepost软件直接导出，
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [node,elem]=read_k(file)

fid=fopen(file,'r');
kfile=textscan(fid,'%s','delimiter','\n');  %读取为1X1的cell
kfile=[kfile{:}];                           %转换成30000X1的cell
fclose(fid);

fid=fopen(file,'r');
flag=textscan(fid,'%c%*[^\n]');           %读取每行第一个字符，为1X1的cell
flag=[flag{:}];                           %转换成30000X1的cell
fclose(fid);
[line_position,colum_position]=find(flag=='*'|flag=='$');    %查找*和$所在行数位置,colum_position为列数
clear colum_position ;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%读取节点信息，存储在node中
[exist_node,node_start]=ismember('*NODE',kfile); %查找*NODE所处的位置，exist表示存在与否，node_start表示位置坐标
[x_node,y_node]=find(line_position==node_start);      %x表示*NODE所处的行数
node_end=line_position(x_node+2);                %查找*NODE信息结束位置
read_times=node_end-node_start-2;           %根据k文件格式，计算节点数量，从*NODE 到*END共有3个注释行

[nid,xcor,ycor,zcor,tc,rc]=textread(file,'%n%f%f%f%f%f',read_times,'headerlines',node_start+1);%以'%n%f%f%f'格式读取20次，从119行以后开始

node=[nid,xcor,ycor,zcor,tc,rc];
clear nid xcor ycor zcor tc rc read_times x_node y_node exist_node node_start node_end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%读取单元（本例子中只有实体单元）信息，存储在elem中
[exist_element,element_start]=ismember('*ELEMENT_SHELL',kfile); %查找*ELEMENT_SHELL所处的位置，exist表示存在与否，node_start表示位置坐标
[x_element,y_element]=find(line_position==element_start);      %x表示*NODE所处的行数
element_end=line_position(x_element+2);                %查找*NODE信息结束位置
read_times=element_end-element_start-2;           %根据k文件格式，计算节点数量，从*NODE 到*END共有3个注释行
[eid,pid,n1,n2,n3,n4,n5,n6,n7,n8]=textread(file,'%n%n%n%n%n%n%n%n%n%n',read_times,'headerlines',element_start+1);%以'%n%f%f%f'格式读取指定次，从指定位置以后开始

elem=[eid,pid,n1,n2,n3,n4,n5,n6,n7,n8];
clear eid pid n1 n2 n3 n4 n5 n6 n7 n8 read_times exist_element x_element y_element flag line_position element_start element_end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%