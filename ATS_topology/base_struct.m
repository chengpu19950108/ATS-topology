function base_elem=base_struct(elem_pos)

%这一函数的作用是选取基础单元，基础单元是认为选定的部分单元，能够反映结构的基本形式.这里选择的单元仅仅为本算例的基础单元，不具有泛用性
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

base_elem=[base1;base2];            %返回单元的位置:return the position of base elements

end