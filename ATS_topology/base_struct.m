function base_elem=base_struct(elem_pos)

%��һ������������ѡȡ������Ԫ��������Ԫ����Ϊѡ���Ĳ��ֵ�Ԫ���ܹ���ӳ�ṹ�Ļ�����ʽ.����ѡ��ĵ�Ԫ����Ϊ�������Ļ�����Ԫ�������з�����
%This function is to choose the base elements. The base elements are
%manually selected, and cannot be used in other examples
l=[3560;893;3374];
r=[8991;9946];
base1=[];
base2=[];
for i=1:3
    a1=abs(elem_pos(:,4)-elem_pos(l(i),4));
    b1=find(a1<0.3);
    a2=elem_pos(:,3)-elem_pos(l(i),3);
    b2=find(a2<0);
    base1=[base1;intersect(b1,b2)];
end

for i=1:2
    a1=abs(elem_pos(:,4)-elem_pos(r(i),4));
    b1=find(a1<0.3);
    a2=elem_pos(:,3)-elem_pos(r(i),3);
    b2=find(a2>0);
    base2=[base2;intersect(b1,b2)];
end

base_elem=[base1;base2];            %���ص�Ԫ��λ��:return the position of base elements

end