function main_func()
N_species = 5;
N_rx = 8;
D = [0  0  0  0  0];
N_slow = 5;
chems={'Ru','L','Rb','Du','Db'};





rhs = pdepe_fun();
ic_fun = pdepe_ic();

Ttot=1e3;
Xmax=5;
t_samples=linspace(0,Ttot,5e2);
xmesh=linspace(0,Xmax,5e2);

sol = pdepe(0, rhs, ic_fun, @zeroflux, xmesh, t_samples);


discard=find(t_samples>=10,1);

figure(1);clf();
i_rac=find(strcmp('Rac',chems));
subplot(1,2,1);
hplot=imagesc(xmesh,fliplr(t_samples(discard+1:end)), flipud(sol(discard+1:end,:,i_rac)));
xlabel('Space (\mum)');
ylabel('Time');
title('Rac');
colorbar

i_rho=find(strcmp('Rho',chems));
subplot(1,2,2);
hplot=imagesc(xmesh,fliplr(t_samples(discard+1:end)), flipud(sol(discard+1:end,:,i_rho)));
xlabel('Space (\mum)')
ylabel('Time');
title('Rho');
colorbar






end
