initialize_chem_params

rhs = pdepe_fun();
ic_fun = pdepe_ic();

Ttot=1e3;
Xmax=3;
t_samples=linspace(0,Ttot,5e2);
xmesh=linspace(0,Xmax,15e2);

% options=odeset('RelTol',1e-5, 'AbsTol', 1e-5, 'InitialStep',1e-6);
sol = pdepe(0, rhs, ic_fun, @zeroflux, xmesh, t_samples);

%%

discard=find(t_samples>=10,1);

figure(1);clf();
i_rac=find(strcmp('Rac',chems));

hplot=imagesc(xmesh,fliplr(t_samples(discard+1:end)), flipud(sol(discard+1:end,:,i_rac)));
% set(hplot,'EdgeColor','None')
xlabel('Space (\mum)')
ylabel('Time');
colorbar





