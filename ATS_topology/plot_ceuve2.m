i=9;    
plot(0:i-1,ydisp(1:i),'b','LineWidth',2)
axis([-inf inf 3.2 3.7])
title('Displacement of key point','FontSize',13,'Fontname','Times newman')
xlabel('Iterations','FontSize',13,'Fontname','Times newman')
ylabel('Displacement / mm','FontSize',13,'Fontname','Times newman')
set(gca,'FontSize',12)
grid on
set(gca,'ytick',3.2:0.05:3.7)
