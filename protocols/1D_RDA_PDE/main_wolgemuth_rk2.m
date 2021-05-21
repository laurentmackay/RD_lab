N=1e3;
dt=0.01;
Q=1;
t_plot=1;





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
eye = speye(sz);
% u_x=(u_for-eye)/h;
% u_x_for(end,:)=u_x_for(end-1,:);
% 
% u_x=(eye-u_back)/h;
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
dudt = cell(1,N_species);
for i_ = 1:length(V)
        f0_star = (f0_for+f0)/2-(sign(V(i_)).*(f0_for-f0))/2;
        dudt0_adv{i_}=-(f0_star - f0_star(jump(:,2),:));
end
    
CFL_max=0.15;
dt0=dt;
h_local = repmat(h,N,1);
h_local_next = repmat(h,N,1);
h_local_half_next = repmat(h,N,1);
sigma=0.3;
mag=1;
while t<1e3 && a+P<Q
    
    eval_model
    eval_aux_model
    
    eval_model_implicit
    
    
    
%     v=v_cell;

    v_max=max(abs(V));


    dt=min(CFL_max*h/abs(v_max), dt0);
%     dt=dt0;
%     nu_for=v*dt/h
    for i_ = find(sign(V_prev)~=sign(V))
        f0_star = (f0_for+f0)/2-(sign(V(i_)).*(f0_for-f0))/2;
        f0_star_back = f0_star(jump(:,2),:);
%         f0_star_back(1,:)=f0_star_back(2,:);
%         dudt0_adv{i_}=-(f0_star - f0_star(jump(:,2),:));
    end
    
    f1_star=f0_star;
    ib=find(in_cell,1)-1;
    ifr=find(in_cell,1,'last');
    f1_star(ib,:)=0;
    f1_star(ifr,:)=0;
%     
%     f1_star(ib,ib)=1;
%     f1_star(ifr,ifr)=1;
%     
%     dudt0_adv=-(f1_star - f1_star(jump(:,2),:))/(h);
%     
    eval_Rx
    Rx(:,2)=Rx(:,2)+mag*exp(-((x-Q/2).^2)/(sigma)^2);

%     Rx_tilde = (Rx(jump(:,1),:)+Rx)/2;
%     Rx_star = (1+sign(V)).*Rx_tilde(jump(:,2),:)/2 ...
%              + (1-sign(V)).*Rx_tilde/2;
         
        if t==0
     Rx_prev=Rx;
%      u_prev=u;
     
     end
%          dt=max(min(0.05/max(abs(Rx_star(:)+Rx_prev(:))./(u(:)+1e-12)),dt),1e-6)
%             if any(V<0) && t>15
%             disp('reversing')
%             dt=dt0/100;
%             t_plot=dt;
%          end

% dt=0.05/max(max(u(:,:)./(dudt0_adv{1}*u(:,1)*(V(1))+Rx_star(:,1)+1e-12)))
%         dt=min(0.01*h/abs(v_cell),dt0)
%          for i_=1:N_species
% %          dudt{i_}=dudt0_adv{i_}*u(:,i_)*(V(i_))+Rx_star(:,i_);
% %         	u(:,i_)=(eye-dudt0_adv{i_}*(V(i_)*dt))\(u(:,i_)+Rx_star(:,i_)*dt);
% %             u(:,i_)=u(:,i_) + dudt0_adv{i_}*u(:,i_)*(V(i_)*dt)+Rx_star(:,i_)*dt;
% %         dt=min(dt,0.05/max(1/(abs(dudt{i_})+1e-4)))
%          end
%          h_local = repmat(h,N,1);
         f1_star=f0_star;
         f1_star_next=f0_star;
          f1_star_half_next=f0_star;
         

         
         bndry=[a a+P];
         bndry_next=[a+v_cell*dt a+v_cell*dt+P ];
         bndry_half_next=[a+v_cell*dt/2 a+v_cell*dt/2+P ];
         
         i_bndry = ceil(bndry/h)+[0; 1];
         i_bndry_next = ceil(bndry_next/h)+[0; 1];
         i_bndry_half_next = ceil(bndry_half_next/h)+[0; 1];
       if any(rem(bndry,h)==0)
            
              disp('degeneracy')
            
          end
         
        if v_cell>0
         f1_star( i_bndry(1,:)+[-1 0],:)=0;
         f1_star_half_next( i_bndry_half_next(1,:)+[-1 0],:)=0;
         f1_star_next( i_bndry_next(1,:)+[-1 0],:)=0;


         end

         h_local(i_bndry)=abs(bndry-(x(i_bndry)+[-1;  1]*h/2));
         h_local_next(i_bndry_next)=abs(bndry_next-(x(i_bndry_next)+[-1; 1]*h/2));
         h_local_half_next(i_bndry_half_next)=abs(bndry_half_next-(x(i_bndry_half_next)+[-1; 1]*h/2));
         u_prev=u;
         for i_=1:N_species
             
             A_ = -(f1_star - f1_star(jump(:,2),:))*V(i_);
%              A_next_ = -(f1_star_next - f1_star_next(jump(:,2),:))*V(i_);
             A_next_ = -(f1_star_half_next - f1_star_half_next(jump(:,2),:))*V(i_);
             u(:,i_)=(eye.*h_local_half_next-A_next_*dt/4)\((eye.*h_local+A_*dt/4)*u(:,i_)+Rx(:,i_)*(dt/2).*h_local);
%             u(:,i_) = u(:,i_) + dudt{i_}*dt;
         end
         
         
          
%           [i_bad, ind_bad] = setdiff(i_bndry(1,:), i_bndry_half_next(1,:));
          
%           if ~isempty(i_bad)
%             disp('islamabad')
%             u(i_bndry_half_next(1,1),:) = u(i_bndry_half_next(1,1),:) + u(i_bndry(1,1),:);
%             u(i_bndry(1,1),:) =0;
%           end
%           
            eval_Rx
            Rx(:,2)=Rx(:,2)+mag*exp(-((x-Q/2).^2)/(sigma)^2);
          for i_=1:N_species
             
             A_ = -(f1_star - f1_star(jump(:,2),:))*V(i_);
             A_next_ = -(f1_star_next - f1_star_next(jump(:,2),:))*V(i_);
%              A_next_ = -(f1_star_half_next - f1_star_half_next(jump(:,2),:))*V(i_);
             u(:,i_)=(eye.*h_local_next-A_next_*dt/2)\((eye.*h_local+A_*dt/2)*u_prev(:,i_)+Rx(:,i_)*dt.*h_local);
%             u(:,i_) = u(:,i_) + dudt{i_}*dt;
          end
         v_cell
%           [i_bad, ind_bad] = setdiff(i_bndry(1,:), i_bndry_next(1,:));
%           if ~isempty(i_bad)
%             disp('islamabad')
% %             u(i_bndry_next(1,1),:) = u(i_bndry_next(1,1),:) + u(i_bndry(1,1),:);
% %             u(i_bndry(1,1),:) = u(i_bndry(1,1)-1,:)/2;
% %             u(i_bndry(1,1)-1,:) = u(i_bndry(1,1)-1,:)/2;
%           end
          
          [i_bad, ind_bad] = setdiff(i_bndry(1,:), i_bndry_next(1,:));
          if ~isempty(i_bad)
              u_xx = ((u_for-eye)./h_local_next - (eye-u_back)./h_local_next(jump(:,2)))./h_local_next;
              u2=u_xx(i_bndry(1,:)-2,:)*u;
              u3=u_xx(i_bndry(1,:)-3,:)*u;
              u20=u_xx(i_bndry(1,:)-2,:)*u_prev;
              
              inds_back = (i_bndry(1,1)-4):(i_bndry(1,1)-1);
              inds_for = (i_bndry(1,1)):(i_bndry(1,1)+2);
              u_xx_back = full(u_xx(i_bndry(1,1)-1,inds_back));
              u_xx_for = full(u_xx(i_bndry(1,1)+1,inds_for));
              for i_=1:N_species
               tmp=[[1 0 0 0]; [0 1 0 0]; [0 0 1 0]; [-1 4 -5 2]/h^2; [h_local_next(inds_back)']]\[u(inds_back(end-3: end-1)-1,i_); u2(i_); sum((u_prev(inds_back-1,i_)+Rx(inds_back-1,i_)*dt/2).*h_local(inds_back-1))]
               u(i_bad(1),i_)=tmp(3);
               
%                   tmp=[[1 0 0 0]; [0 1 0 0]; [0 u_xx_back]; [h_local_next(inds_for)' 0]]\[u(inds_for(end-2:end),i_); u2(i_); sum(u(inds_for+1,i_).*h_local(inds-1))]
%                    u(i_bad(1)+1,i_)=tmp(3);   
              end
             
          
          end
         h_local(i_bndry)=h;
         h_local_next(i_bndry_next)=h;
         h_local_half_next(i_bndry_half_next)=h;

    if t-last_plot>=dt
        inds=[1 3];
        inds=[1, 3, 4, 5];
        subplot(2,1,1);
        hplot=plot(x,u(:,inds));
        xline(a);
        xline(a+P);
        legend(hplot,chems{inds})
        
        subplot(2,1,2);
        plot(x,Rx(:,2));
        drawnow

        last_plot=t;
    end
    t=t+dt;
%     Rx_prev=Rx_star;
    in_cell_prev=in_cell;
    u_aux=u_aux+f_aux*dt;
%     a=a+(v)*dt;
    
    V_prev=V;
end
