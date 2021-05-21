N=1e4;
dt=0.1;
Q=1;
t_plot=2;





N=N+1;
sz=N;
i=(1:N)';
x=linspace(0,Q,N)';
h=(x(end)-x(1))/(N-1);

jump=[circshift(i,-1) circshift(i,1)];


initialize_chem
u=u0;
u_aux=0.1





figure(1);clf();
t=0;
v_prev=0;
last_plot=-inf;
dudt_adv=sparse(sz,sz);

u_for = sparse(1:sz , jump(:,1)',1);
u_back = sparse(1:sz , jump(:,2)',1);
eye = speye(sz);
u_x_for=(u_for-eye)/h;
u_x_for(end,:)=u_x_for(end-1,:);

u_x_back=(eye-u_back)/h;
u_x_back(1,:)=u_x_back(2,:);


    
   
    
    f0_for_adv = u_for;
    f0_adv=eye;
    
    %adding up all the fluxes
    f0_for = f0_for_adv;
    f0=f0_adv;
    
model_params

eval_model
eval_model_implicit
eval_aux_model
    
    f0_star = (f0_for+f0)/2-(sign(v_prev).*(f0_for-f0))/2;
    
CFL_max=0.8;
dt0=dt;

while t<1e3 && a+P<Q
    
    eval_model_implicit
    eval_aux_model
    
    v=v_cell;



    dt=min(CFL_max*h/abs(v), dt0);
    nu_for=v*dt/h;
    if sign(v) ~=sign(v_prev) || t==0
        f0_star = (f0_for+f0)/2-(sign(v).*(f0_for-f0))/2;
    end
    
    f1_star=f0_star;
%     ib=find(in_cell,1)-1;
%     ifr=find(in_cell,1,'last');
%     f1_star(ib,:)=0;
%     f1_star(ifr,:)=0;
%     
%     f1_star(ib,ib)=1;
%     f1_star(ifr,ifr)=1;
%     
    dudt0_adv=-(f1_star - f1_star(jump(:,2),:))/(h);
%     
    eval_Rx
    Rx(:,2)=Rx(:,2)+exp(-((x-Q/2).^2)/(0.1)^2);

    Rx_tilde = (Rx(jump(:,1),:)+Rx)/2;
    Rx_star = (1+sign(v))*Rx_tilde(jump(:,2),:)/2 ...
             + (1-sign(v))*Rx_tilde/2;
    u=u+dudt0_adv*u*(v*dt)+Rx_star*dt;
    if t-last_plot>=t_plot
        inds=[1 2 3];
        hplot=plot(x,u(:,inds));
        legend(hplot,chems{inds})
        xline(a);
        xline(a+P);
        drawnow

        last_plot=t;
    end
    t=t+dt;
    in_cell_prev=in_cell;
    
%     a=a+(v)*dt;
    u_aux=u_aux+f_aux*dt;
    v_prev=v;
end
