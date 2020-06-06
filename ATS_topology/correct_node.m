%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%�ýű��������Ǵ����ڶ���ڵ㣬����Ҫ��part1�ĵ�Ԫ�ƶ���part2ʱ����Ӧ��Ԫ�Ľڵ��żӼ�20000������ʵ�ֲ���1,2�����ýڵ㣬��֤�˱߽������ĺ�����
%�����ڶ���ڵ�󣬽�part2��right�Ľڵ���ȫ��+20000��ͬʱ����part2��part8���Ӳ�λ���趨������

%This function is to generate the second layer of grids. Elements in part 1
%will be constructed through original grid. And part 2 will be constructed
%through the second grid.
%Through this way, reasonable grid consecutiveness and edge condition can
%be guaranteed during the updating process of design variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [elem,elem_1,elem_2]=correct_node(file,elem,node)

fid=fopen(file,'r');                                        %����ѭ������element��node��Ϣ���ֵ�λ�ã��ļ�ָ��λ�ã���������һ��ע����
last_fid=0;                                                 %Ϊfid�����ʼֵ
while ~feof(fid)
    tline=fgetl(fid);
    if strcmp(tline,'*END')
        end_fid=last_fid;                                   %node_fidΪnode��Ϣ��ʼ��λ��
    elseif strcmp(tline,'*ELEMENT_SHELL')
        tline=fgetl(fid);
        elem_fid=ftell(fid);                                %elem_fidΪelement��Ϣ��ʼ��λ��
    end
    last_fid=ftell(fid);
end
fclose(fid);

node2=node;
node2(:,1)=node2(:,1)+20000;                                               %�����ڶ���ڵ㣬�Ա���µ�Ԫ�����Ժͼ����

[row1,col1]=find(elem(:,2)==1);                   %Ѱ��part���Ϊ1�ĵ�Ԫλ�ã���left�����ĵ�Ԫ
elem_1=elem(row1,:);                 %elem_2Ϊleft��Ԫ

[row2,col2]=find(elem(:,2)==2);                   %Ѱ��part���Ϊ2�ĵ�Ԫλ�ã���right�����ĵ�Ԫ
elem_2=elem(row2,:);                 %elem_2Ϊright��Ԫ

[row8,col8]=find(elem(:,2)==8);                   %Ѱ��part���Ϊ8�ĵ�Ԫλ�ã���merge_right�����ĵ�Ԫ
elem_8=elem(row8,:);                 %elem_8Ϊmerge_right�����ĵ�Ԫ

[node_out,ia,ib]=setxor(elem_2(:,3:6),elem_8(:,3:6));                      %����part 8 ��part 2�в�ͬ�ĵ�Ԫ��node_out���ص�Ԫ�ţ�ia����elem_2�еĲ�ͬ��Ԫ��λ�ã�ib����elem_8�в�ͬ��Ԫ��λ�ã�ע��ia��ibֻ���ص�һ�γ��ֵ�Ԫ�أ��ظ�Ԫ�ر�������
elem_8_node=elem_8(:,3:6);                                                 %��ȡelem_8�нڵ�����Ե���Ϣ
node_to_change=elem_8_node(ib);
for i=1:size(node_to_change)
    [row,col]=find(elem_8_node==node_to_change(i));
        for j=1:size(row)
            elem_8_node(row(j),col(j))= elem_8_node(row(j),col(j))-20000;
        end
end

elem_2(:,3:6)=elem_2(:,3:6)+20000;                                         %��elem_2����ڶ���ڵ�
elem_8(:,3:6)=elem_8_node+20000;                                           %��part 8 �Ľڵ�Ž��в�������֤���ڵ����20000����λ�ڵڶ���ڵ��ϡ��Ҳ�ڵ�Ϊԭ���

elem(row1(1):row1(end),:)=elem_1;
elem(row2(1):row2(end),:)=elem_2;
elem(row8(1):row8(end),:)=elem_8;


fid=fopen(file,'r+');
fseek(fid,end_fid,'bof');
formatSpec = '%8d%16f%16f%16f%8d%8d\n';
fprintf(fid,formatSpec,node2');                                    %����һ�δ����FEģ�͵Ľڵ���Ϣд��K�ļ�
fprintf(fid,'*END\n');
fclose(fid);

fid=fopen(file,'r+');
fseek(fid,elem_fid,'bof');
formatSpec = '%8d%8d%8d%8d%8d%8d%8d%8d%8d%8d\n';
fprintf(fid,formatSpec,elem');                           %����һ�δ����FEģ�͵�Ԫ��Ϣд��K�ļ�
fclose(fid);
