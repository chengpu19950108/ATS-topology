i=input('������Ҫ����ͼƬ�ĵ���������\n');


subfolder=sprintf('%s%d','ilteration_',i);
path=sprintf('%s\\%s',cd,subfolder);
kfile=sprintf('%s\\%s',path,file); %file='original.k'
[node,elem]=read_k(kfile);                   %����read_k������ȡk�ļ��ĵ�Ԫ��Ϣ�ͽڵ���Ϣ�����ض�ȡ�Ľڵ�͵�Ԫ��Ϣ

[row1,~]=find(elem(:,2)==1);                   %Ѱ��part���Ϊ1�ĵ�Ԫλ�ã���left�����ĵ�Ԫ
elem_1=elem(row1,:);                 %elem_2Ϊleft��Ԫ
[row2,~]=find(elem(:,2)==2);                   %Ѱ��part���Ϊ2�ĵ�Ԫλ�ã���right�����ĵ�Ԫ
elem_2=elem(row2,:);                 %elem_2Ϊright��Ԫ

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
