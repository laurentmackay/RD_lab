function main_func()
N=1e4;
T_tot=1e2;
dt=0.1;
Q=1;
t_plot=2;





N=N+1;
sz=N;
i=(1:N)';
x=linspace(0,Q,N)';
h=(x(end)-x(1))/(N-1);

jump=[circshift(i,-1) circshift(i,1)];


N_species = 5;
N_rx = 8;
D = [0  0  0  0  0];
N_slow = 5;
chems={'Ru','L','Rb','Du','Db'};





ic = [0 1 0 0 0];
u0=repmat(ic,[sz,1]);

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
    
    
    f0_for = f0_for_adv;
    f0=f0_adv;
    
P=0.150000000;
c=1.000000000;
k4r=1.000000000;
R0=1.000000000;
k1r=1.000000000;
k2r=1.000000000;
kdr=1.000000000;
D0=1.000000000;
k4d=1.000000000;
gamma_L=1;
Q=1;
cnsrv_1=1;


V=[0 0 0 0 0];
in_cell = x>=u_aux(1) & x<=(u_aux(1)+P);
front = x>=u_aux(1)+P./2 & x<=u_aux(1)+P;
rear = x>=u_aux(1) & x<u_aux(1)+P./2 ;
Rb_rear = trapz(x(rear),u(rear,3));
Rb_front = trapz(x(front),u(front,3));
v_cell = c.*(Rb_front-Rb_rear);
a=u_aux(1);

f_aux=[v_cell];
f0_star = (f0_for+f0)/2-(sign(v_prev).*(f0_for-f0))/2;
    
CFL_max=0.8;
dt0=dt;

while t<T_tot && a+P<Q
    
    in_cell = x>=u_aux(1) & x<=(u_aux(1)+P);
front = x>=u_aux(1)+P./2 & x<=u_aux(1)+P;
rear = x>=u_aux(1) & x<u_aux(1)+P./2 ;
Rb_rear = trapz(x(rear),u(rear,3));
Rb_front = trapz(x(front),u(front,3));
v_cell = c.*(Rb_front-Rb_rear);
a=u_aux(1);

f_aux=[v_cell];
v=v_cell;



    dt=min(CFL_max*h/abs(v), dt0);
    nu_for=v*dt/h;
    if sign(v) ~=sign(v_prev) || t==0
        f0_star = (f0_for+f0)/2-(sign(v).*(f0_for-f0))/2;
    end
    
    f1_star=f0_star;
    dudt0_adv=-(f1_star - f1_star(jump(:,2),:))/(h);
    f_Ru =  (k4r.*R0.*in_cell)-(k4r.*u(:,1))-(k1r.*u(:,1).*u(:,2))+ (k2r.*u(:,3));
f_L = -(k1r.*u(:,1).*u(:,2))+ (k2r.*u(:,3))-(kdr.*u(:,2).*u(:,4))+ (kdr.*u(:,5));
f_Rb =  (k1r.*u(:,1).*u(:,2))-(k2r.*u(:,3));
f_Du =  (kdr.*D0)-(k4d.*u(:,4))-(kdr.*u(:,2).*u(:,4))+ (kdr.*u(:,5));

Rx = [f_Ru,...
f_L,...
f_Rb,...
f_Du,...
- f_L - f_Rb];
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
    
    u_aux=u_aux+f_aux*dt;
    v_prev=v;
end
save('C:\Users\metap\git\RD_lab\_gen_model_Nov2015\results\1D_RDA_PDE.mat')
end
