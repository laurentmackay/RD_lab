N=1e3;
dt=0.001;
Q=1;
t_plot=1;





N=N+1;
sz=N;
i=(1:N)';
x=linspace(0,Q,N)';
h=(x(end)-x(1))/(N-1);

jump=[circshift(i,-1) circshift(i,1)];


model_params
initialize_chem
eval_model

u=u0;




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
    
    eval_model_implicit
     v=c*(Rb_front-Rb_rear);
    v_prev=v;
    in_cell_prev=in_cell;
    
    f0_star = (f0_for+f0)/2-(sign(v_prev).*(f0_for-f0))/2;
    


while t<1e3 && a+P<Q
    
    eval_model_implicit
    
    
    v=c*(Rb_front-Rb_rear);
    
%     ibad=find(in_cell_prev & ~in_cell );
    
    
%     v=0.01;
%     if ~isempty(ibad)
%         
%         if length(ibad)>1
%             error('unexpeted complication')
%         end
%         if v_prev>0
%             u(in_cell,:)=u(in_cell,:)+u(ibad,:)/nnz(in_cell);
%             
%         else
%             u(in_cell,:)=u(in_cell,:)+u(ibad,:)/nnz(in_cell);
%         end
%         u(ibad,:)=0;
%     end
    nu_for=v*h/dt;
    CFL=v*dt/h
    if sign(v) ~=sign(v_prev) || t==0
        f0_star_UW = (f0_for+f0)/2-(sign(v).*(f0_for-f0))/2;
%         f0_star_LW = (f0_for+f0)/2-(sign(v)*(1-(1-abs(nu_for)))*(f0_for-f0))/2;
        f0_star_LW = (f0_for+f0)/2-nu_for*(f0_for-f0)/2;

        if v>0
            du_UW=u_back;
        else
            du_UW=u_for;
        end        
%         dudt0_adv=-(f0_star - f0_star(jump(:,2),:))/h;
    end
    
    r_=(du_UW*u)./(u_for*u);
    r_(isnan(r_))=1;
    L_=max(min(r_,1),0);
%     L_(~isfinite(L_))=2;
    
    
    
%     dudt0_adv=-(f0_star - f0_star(jump(:,2),:))/h;
    
%     f1_star=f0_star;
%     f1_star(find(in_cell,1)-1,:)=0;
%     f1_star(find(in_cell,1,'last'),:)=0;
    
%     f1_star(find(in_cell,1)-1,find(in_cell,1))=1;
%     f1_star(find(in_cell,1,'last'),find(in_cell,1,'last'))=1;
    
%     dudt0_adv=-(f1_star - f1_star(jump(:,2),:))/(h);
%     
    eval_Rx
    Rx(:,2)=Rx(:,2)+exp(-((x-Q/2).^2)/(0.1)^2);
%     u(:,2)=x;
    
    for i=1:N_species
        f0_star = f0_star_UW + L_(:,i).*(f0_star_LW-f0_star_UW);
%          f0_star= (f0_for+f0)/2-sign(v)*((1-L_(:,i))*(1-abs(nu_for))).*(f0_for-f0)/2;
        dudt0_adv=-(f0_star - f0_star(jump(:,2),:))/h;
        u(:,i)=u(:,i)+dudt0_adv*u(:,i)*(v*dt)+Rx(:,i)*dt;
    end

%     u=u+dudt0_adv*u*(v*dt)+Rx*dt;
    if t-last_plot>=t_plot
        inds=[1 3];
        plot(x,u(:,inds));
        legend(chems{inds})
        xline(a);
        xline(a+P);
        drawnow
        [find(in_cell,1)-1 u(find(in_cell,1)-1,1)]
        last_plot=t;
    end
    t=t+dt;
    in_cell_prev=in_cell;
    
    a=a+(v)*dt;
    v_prev=v;
end
