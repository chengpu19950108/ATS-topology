i=input('请输入要导出图片的迭代步数：\n');


subfolder=sprintf('%s%d','ilteration_',i);
path=sprintf('%s\\%s',cd,subfolder);
kfile=sprintf('%s\\%s',path,file); %file='original.k'
[node,elem]=read_k(kfile);                   %调用read_k函数读取k文件的单元信息和节点信息，返回读取的节点和单元信息

[row1,~]=find(elem(:,2)==1);                   %寻找part编号为1的单元位置，即left部件的单元
elem_1=elem(row1,:);                 %elem_2为left单元
[row2,~]=find(elem(:,2)==2);                   %寻找part编号为2的单元位置，即right部件的单元
elem_2=elem(row2,:);                 %elem_2为right单元

fl=elem_1(:,3:6);
fr=elem_2(:,3:6)-20000;
figure;
axis off
hold on
patch('Faces',fl,'Vertices',node(:,2:3),'FaceColor',[1,0.753,0.796],'edgecolor','w');
patch('Faces',fr,'Vertices',node(:,2:3),'FaceColor',[0,0.74902,1],'edgecolor','w');
%title(['Iteration  ',num2str(i)])
hold off
set(gca,'YDir','reverse')
%set(gca,'xcolor','w','ycolor','w')
set(gcf,'units','normalized','position',[0,0,0.6,0.9])
