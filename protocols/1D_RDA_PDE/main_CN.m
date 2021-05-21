N=1e3;
dt=1;

t_plot=0.5;





N=N+1;
sz=N;
i=(1:N)';
x=linspace(0,Q,N)';
h=(x(end)-x(1))/(N-1);

jump=[circshift(i,-1) circshift(i,1)];


initialize_chem
u=u0;
u_aux=0.1;





figure(1);clf();
t=0;
v_prev=0;
last_plot=-inf;
dudt_adv=sparse(sz,sz);

u_for = sparse(1:sz , jump(:,1)',1);
% u_for(end,:)=0;
% u_for(end,end)=1;
u_back = sparse(1:sz , jump(:,2)',1);
% u_back(1,:)=0;
u_x = (u_for-u_back)/h;

eye = speye(sz);
u_xx = (u_back-2*eye+u_for)/(h^2);
% u_x_for=(u_for-eye)/h;
% u_x_for(end,:)=u_x_for(end-1,:);
% 
% u_x_back=(eye-u_back)/h;
% u_x_back(1,:)=u_x_back(2,:);


    
   
    
    f0_for_adv = u_for;
    f0_adv=eye;
    
    %adding up all the fluxes
    f0_for = f0_for_adv;
    f0=f0_adv;
    
model_params

eval_model
eval_aux_model
eval_model_implicit


V_prev=V;
dudt0_adv = cell(1,N_species);
for i_ = 1:length(V)
        f0_star = (f0_for+f0)/2-(sign(V(i_)).*(f0_for-f0))/2;
        dudt0_adv{i_}=-(f0_star - f0_star(jump(:,2),:))/h;
end
rel_tol=0.1
CFL_max=rel_tol;
dt0=dt;

while t<1e3 && a+P<Q
    
    eval_model
    eval_aux_model
    
    eval_model_implicit
    
    
    
%     v=v_cell;

    v=max(abs(V));


    dt=min(CFL_max*h/v, dt0);
%     dt=dt0;
%     nu_for=v*dt/h
    for i_ = find(sign(V_prev)~=sign(V))
        f0_star = (f0_for+f0)/2-(sign(V(i_)).*(f0_for-f0))/2;
        f0_star_back = f0_star(jump(:,2),:);
%         f0_star_back(1,:)=f0_star_back(2,:);
        dudt0_adv{i_}=-(f0_star - f0_star_back)/h;
    end
    
%     f1_star=f0_star;
%     ib=find(in_cell,1)-1;
%     ifr=find(in_cell,1,'last');
%     f1_star(ib,:)=0;
%     f1_star(ifr,:)=0;
%     
%     f1_star(ib,ib)=1;
%     f1_star(ifr,ifr)=1;
%     
%     dudt0_adv=-(f1_star - f1_star(jump(:,2),:))/(h);
%     
    eval_Rx
    Rx(:,2)=Rx(:,2)+exp(-((x-Q/2).^2)/(0.1)^2);

    Rx_tilde = (Rx(jump(:,1),:)+Rx)/2;
    Rx_star = (1+sign(V)).*Rx_tilde(jump(:,2),:)/2 ...
             + (1-sign(V)).*Rx_tilde/2;
         
%     if any(V<0) && t>15
%     disp('reversing')
%     dt=dt0/100;
%     t_plot=dt;
%     end
     if t==0
     Rx_prev=Rx_star;
     
     end
     dt=max(min(2*rel_tol/max(abs(Rx_star(:)+Rx_prev(:))./(u(:)+1e-12)),dt0),1e-6)
         for i_=1:N_species
            if D(i_)==0
%                 A_ = dudt0_adv{i_}*(V(i_)*dt)/2;
                A_ = -u_x*(V(i_)*dt)/4;
            else
                A_ = D(i_)*u_xx*dt/2;
            end
        	u(:,i_)=(eye-A_)\((eye+A_)*u(:,i_)+(Rx_star(:,i_))*dt);

         end
        Rx_prev=Rx_star;

    if t-last_plot>=t_plot
        inds=[1 3];
        inds=1:N_species;
        hplot=plot(x,u(:,inds));
        xline(a);
        xline(a+P);
        legend(hplot,chems{inds})
        drawnow

        last_plot=t;
    end
    t=t+dt;
    in_cell_prev=in_cell;
    u_aux=u_aux+f_aux*dt;
%     a=a+(v)*dt;
    
    V_prev=V;
end
