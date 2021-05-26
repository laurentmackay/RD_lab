function [P,v_cell,in_cell] = main_func(P,v_cell,in_cell)
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


N_species = 2;
N_rx = 2;
D = [0.25        0.02];
N_slow = 2;
chems={'Raci','Rac'};





ic = [1 0];
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
    
B=0.500000000;
Irho=0.016000000;
Lrho=0.340000000;
delta_rho=0.016000000;
LR=0.340000000;
IR=0.003000000;
delta_R=0.025000000;
alphaR=15.000000000;
delta_P=0.000400000;
Ik=0.009000000;
LK=5.770000000;
a=0.628100000;
d=2.877300000;
c=11.500000000;
gamma=0.300000000;
alphaP=2.200000000;
Rac_Square=1.000000000;
n=4.000000000;
Ractot=1.000000000;
Rtot=7.5;
Ptot=1;
Ractot=1;
R = x(:,:,2) ./ Rac_Square;
K=alphaR.*R./(1+alphaR.*R+a.*d./(1+d+3./(1+R)));
Rho=Irho.*(LR.^n)./(Irho.*LR.^n+delta_rho.*(LR.^n+(R+gamma.*K).^n));
c_p=K.^n./(LK.^n+K.^n);
Pax=B.*c_p./(alphaP.*B.*c_p+delta_P);
Iks=Ik.*(1-(1./(1+d+a.*d.*c.*Pax+0.5)));
Q_R = (IR+Iks).*(Lrho.^n./(Lrho.^n+Rho.^n));

V=[0 0];

;

f_aux=[];
f0_star = (f0_for+f0)/2-(sign(v_prev).*(f0_for-f0))/2;
    
CFL_max=0.8;
dt0=dt;

while t<T_tot && a+P<Q
    
    
;

f_aux=[];
v=v_cell;



    dt=min(CFL_max*h/abs(v), dt0);
    nu_for=v*dt/h;
    if sign(v) ~=sign(v_prev) || t==0
        f0_star = (f0_for+f0)/2-(sign(v).*(f0_for-f0))/2;
    end
    
    f1_star=f0_star;
    dudt0_adv=-(f1_star - f1_star(jump(:,2),:))/(h);
    R = u(:,2) ./ Rac_Square;
K=alphaR.*R./(1+alphaR.*R+a.*d./(1+d+3./(1+R)));
Rho=Irho.*(LR.^n)./(Irho.*LR.^n+delta_rho.*(LR.^n+(R+gamma.*K).^n));
c_p=K.^n./(LK.^n+K.^n);
Pax=B.*c_p./(alphaP.*B.*c_p+delta_P);
Iks=Ik.*(1-(1./(1+d+a.*d.*c.*Pax+0.5)));
Q_R = (IR+Iks).*(Lrho.^n./(Lrho.^n+Rho.^n));
f_Raci = -(Q_R.*u(:,1))+ (delta_R.*u(:,2));

Rx = [f_Raci,...
-f_Raci];
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

end
