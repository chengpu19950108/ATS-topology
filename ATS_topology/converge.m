E=internal_energy;
ER=[0;0;E];
ebc=(E(1:12)-ER(1:12))/E(1);
plot(ebc)