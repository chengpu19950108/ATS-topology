%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%该脚本的作用是创建第二层节点，当需要将part1的单元移动到part2时，对应单元的节点编号加减20000，可以实现部件1,2不共用节点，保证了边界条件的合理性
%创建第二层节点后，将part2即right的节点编号全部+20000，同时处理part2与part8连接部位的设定合理性

%This function is to generate the second layer of grids. Elements in part 1
%will be constructed through original grid. And part 2 will be constructed
%through the second grid.
%Through this way, reasonable grid consecutiveness and edge condition can
%be guaranteed during the updating process of design variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [elem,elem_1,elem_2]=correct_node(file,elem,node)

fid=fopen(file,'r');                                        %以下循环查找element和node信息出现的位置（文件指针位置），并跳过一行注释行
last_fid=0;                                                 %为fid赋予初始值
while ~feof(fid)
    tline=fgetl(fid);
    if strcmp(tline,'*END')
        end_fid=last_fid;                                   %node_fid为node信息开始的位置
    elseif strcmp(tline,'*ELEMENT_SHELL')
        tline=fgetl(fid);
        elem_fid=ftell(fid);                                %elem_fid为element信息开始的位置
    end
    last_fid=ftell(fid);
end
fclose(fid);

node2=node;
node2(:,1)=node2(:,1)+20000;                                               %创建第二层节点，以便更新单元连贯性和间断性

[row1,col1]=find(elem(:,2)==1);                   %寻找part编号为1的单元位置，即left部件的单元
elem_1=elem(row1,:);                 %elem_2为left单元

[row2,col2]=find(elem(:,2)==2);                   %寻找part编号为2的单元位置，即right部件的单元
elem_2=elem(row2,:);                 %elem_2为right单元

[row8,col8]=find(elem(:,2)==8);                   %寻找part编号为8的单元位置，即merge_right部件的单元
elem_8=elem(row8,:);                 %elem_8为merge_right部件的单元

[node_out,ia,ib]=setxor(elem_2(:,3:6),elem_8(:,3:6));                      %查找part 8 和part 2中不同的单元，node_out返回单元号，ia返回elem_2中的不同单元的位置，ib返回elem_8中不同单元的位置，注意ia，ib只返回第一次出现的元素，重复元素被忽略了
elem_8_node=elem_8(:,3:6);                                                 %提取elem_8中节点关联性的信息
node_to_change=elem_8_node(ib);
for i=1:size(node_to_change)
    [row,col]=find(elem_8_node==node_to_change(i));
        for j=1:size(row)
            elem_8_node(row(j),col(j))= elem_8_node(row(j),col(j))-20000;
        end
end

elem_2(:,3:6)=elem_2(:,3:6)+20000;                                         %将elem_2放入第二层节点
elem_8(:,3:6)=elem_8_node+20000;                                           %对part 8 的节点号进行操作，保证左侧节点大于20000，即位于第二层节点上。右侧节点为原编号

elem(row1(1):row1(end),:)=elem_1;
elem(row2(1):row2(end),:)=elem_2;
elem(row8(1):row8(end),:)=elem_8;


fid=fopen(file,'r+');
fseek(fid,end_fid,'bof');
formatSpec = '%8d%16f%16f%16f%8d%8d\n';
fprintf(fid,formatSpec,node2');                                    %将第一次代入的FE模型的节点信息写入K文件
fprintf(fid,'*END\n');
fclose(fid);

fid=fopen(file,'r+');
fseek(fid,elem_fid,'bof');
formatSpec = '%8d%8d%8d%8d%8d%8d%8d%8d%8d%8d\n';
fprintf(fid,formatSpec,elem');                           %将第一次代入的FE模型单元信息写入K文件
fclose(fid);
