N=1e3;
dt=0.0001;
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
u_for(end,:)=0;
u_for_2 =u_for(jump(:,1),:);
u_for_2(end,:)=0;

u_back = sparse(1:sz , jump(:,2)',1);
u_back(1,:)=0;
u_back_2 =u_back(jump(:,2),:);
u_back_2(1,:)=0;

eye = speye(sz);
u_x_for=(-3*eye+4*u_for-u_for_2)/(2*h);
u_x_for(end-1,:)=(u_for(end-1,:)-eye(end-1,:))/h;
u_x_for(end,:)=u_x_for(end-1,:);

u_x_back=(3*eye-4*u_back+u_back_2)/(2*h);
u_x_back(2,:)=(eye(2,:)-u_back(2,:))/h;
u_x_back(1,:)=u_x_back(2,:);

while t<100 && a+P<Q
    
    eval_model_implicit
    
    
    v=c*(Rb_front-Rb_rear);
    
    lambda_tilde_adv = v;
    
    
    
    if sign(v) ~=sign(v_prev)
        %upwind
        if v>0
            dudt_adv = -v*u_x_back;
        else
            dudt_adv = -v*u_x_for;
        end
    end
    
    eval_Rx
    Rx(:,2)=Rx(:,2)+exp(-((x-Q/2).^2)/(0.1)^2);
    
    
    u=u+(dudt_adv*u+Rx)*dt;
    if t-last_plot>=t_plot
        plot(x,u,x,in_cell);
        xline(a);
        xline(a+P);
        drawnow
        last_plot=t;
    end
    t=t+dt;
    a=a+v*dt;
end
