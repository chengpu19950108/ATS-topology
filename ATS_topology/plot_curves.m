i=9;
    figure(1)
    plot(0:i-1,internal_energy(1:i),'k','LineWidth',2);hold on
    plot(0:i-1,energy1(1:i),'r','LineWidth',2);
    plot(0:i-1,energy2(1:i),'b','LineWidth',2);
    hold off
    title('Strain energy curves','FontSize',13,'Fontname','Times newman')
    legend('Total strain energy','Strain energy of Part¢ñ','Strain energy of Part¢ò')
    xlabel('Iterations','FontSize',13,'Fontname','Times newman')
    ylabel('Strain energy / N¡¤mm','FontSize',13,'Fontname','Times newman')
    set(gca,'FontSize',12)
