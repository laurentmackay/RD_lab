function main_func()
N_species = 5;
N_rx = 6;
D = [1         0.1           1         0.1           0];
N_slow = 5;
chems={'Raci','Rac','Rhoi','Rho','E'};





rhs = pdepe_fun();
ic_fun = pdepe_ic();

Ttot=1e3;
Xmax=3;
t_samples=linspace(0,Ttot,1e2);
xmesh=linspace(0,Xmax,15e2);

sol = pdepe(0, rhs, ic_fun, @zeroflux, xmesh, t_samples);

figure(1);clf();
i_rac=find(strcmp('Rac',chems));

hplot=pcolor(xmesh,fliplr(t_samples), flipud(sol(:,:,i_rac)));
set(hplot,'EdgeColor','None')
xlabel('Space (\mum)')
ylabel('Time');
colorbar






end
