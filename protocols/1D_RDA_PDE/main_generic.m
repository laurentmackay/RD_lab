N=5e2;
dt=0.01;
Q=1;
t_plot=2;
order=2;




N=N+1;
sz=N;
i=(1:N)';
x=linspace(0,Q,N)';
h=(x(end)-x(1))/(N-1);

jump=[circshift(i,-1) circshift(i,1)];


initialize_chem
u=u0;
u_aux=u_aux0;





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


heye=h*eye;


f0_for_adv = u_for;
f0_adv=eye;

%adding up all the fluxes
f0_for = f0_for_adv;
f0=f0_adv;

model_params

eval_model
eval_model_implicit
eval_aux_model



V_prev=V;
v_cell_prev=v_cell;
% dudt0_adv = cell(1,N_species);
% dudt = cell(1,N_species);
% for i_ = 1:length(V)
%     f0_star = (f0_for+f0)/2-(sign(V(i_)).*(f0_for-f0))/2;
%     dudt0_adv{i_}=-(f0_star - f0_star(jump(:,2),:));
% end

CFL_max=0.15;
dt0=dt;
h_local = repmat(h,N,1);
h_local_next = repmat(h,N,1);
h_local_half_next = repmat(h,N,1);
sigma=0.15;
mag=1;

bndry=[a a+P];
i_bndry = ceil((bndry-x(1))/h)+[0; 1];
hmax=h;
eval_model
eval_aux_model
eval_model_implicit    

while t<1e3 && a+P<Q

    
    

    
    %     dt=dt0;
    %     nu_for=v*dt/h
    
    
    eval_Rx
    Rx(:,2)=Rx(:,2)+mag*exp(-((x-Q/2).^2)/(sigma)^2);
    
    %     Rx_tilde = (Rx(jump(:,1),:)+Rx)/2;
    %     Rx_star = (1+sign(V)).*Rx_tilde(jump(:,2),:)/2 ...
    %              + (1-sign(V)).*Rx_tilde/2;
    
    if t==0
        Rx_prev=Rx;
        v_cell_prev=v_cell;
        %      u_prev=u;
        
    end


    

    
    


       
    eval_model
    eval_model_implicit
    eval_aux_model
    eval_bndrys
    
    u_prev=u;
    Rx_prev=Rx;
    
    V_prev=V;
    v_cell_prev=v_cell;
    
    bndrys_prev=bndrys;
    bndry_vel_prev=bndry_vel;
    bndry_flux_prev=bndry_flux;
    
    dt=min(CFL_max*h/max(abs(V)), dt0);
        
    u_aux=u_aux+f_aux*dt/2;
    
    eval_model
    eval_model_implicit
    eval_aux_model
    eval_bndrys
    
    bndrys_half=bndrys;
    bndry_vel_half=bndry_vel;
    bndry_flux_half=bndry_flux;
    

    V_half=V;


    stencil=1;
    implicit_BC=1;
    nu_for_prev=abs(V_prev)*dt/h;
    nu_for_half=abs(V_half)*dt/h;
    for i_=1:N_species
        
        if order==1
            f0_star = (f0_for+f0)/2-(sign(V_prev(i_)).*(f0_for-f0))/2;
        elseif order==2
            f0_star = (f0_for+f0)/2-(sign(V_prev(i_))*(1-(1-abs(nu_for_prev(i_))))*(f0_for-f0))/2;
        end
        f1_star=f0_star;
        
        
        if order==1
            f0_star = (f0_for+f0)/2-(sign(V_half(i_)).*(f0_for-f0))/2;
        elseif order==2
            f0_star = (f0_for+f0)/2-(sign(V_half(i_))*(1-(1-abs(nu_for_half(i_))))*(f0_for-f0))/2;
        end
        f1_star_half_next=f0_star;


        A_ = -(f1_star - f1_star(jump(:,2),:))*V_prev(i_);
        A_next_ = -(f1_star_half_next - f1_star_half_next(jump(:,2),:))*V(i_);
        M_=(heye-A_next_*dt/2);
        b_ = (heye*u(:,i_)+Rx_prev(:,i_)*(dt/2).*h);
        
        if implicit_BC && ~isempty(bndrys{i_})
            i_bndry = ceil((bndrys_prev{i_}-x(1))/h)+[0; 1];
            i_bndry_half_next = ceil((bndrys_half{i_}-x(1))/h)+[0; 1];
            
            inds = cat(3,i_bndry(1,:)'+[0 -1],i_bndry(1,:)'+[1 2]);
            inds_next = cat(3,i_bndry_half_next(1,:)'+[0 -1],i_bndry_half_next(1,:)'+[1 2]);
            
            h_bndry = min(abs(x(i_bndry)'+[-h h]/2-bndrys_prev{i_}'),hmax);
            h_nbr = [h_bndry(:) hmax-h_bndry(:)];
            h_bndry_next = min(abs(x(i_bndry_half_next)'+[-h h]/2-bndrys_half{i_}'),hmax);
            h_nbr_next = [h_bndry_next(:) hmax-h_bndry_next(:)];
            %
            M_(inds_next(:,1,:),:)=0;
            i_next = squeeze(inds_next(:,1,:));
            j_prev = cat(1,inds(:,:,1),inds(:,:,2));
            j_next = cat(1,inds_next(:,:,1),inds_next(:,:,2));
            ij_next = sub2ind([N,N],repelem(i_next(:),1,2),j_next);
            M_(ij_next)=h_nbr_next;
            J_prev = [f1_star(inds(:,2,1),:);-f1_star(inds(:,2,2),:)]*u_prev(:,i_).*(V_prev(i_)-repmat(bndry_vel_prev{i_}',2,1));
            J_next = [f1_star_half_next(inds_next(:,2,1),:);-f1_star_half_next(inds_next(:,2,2),:)].*(V(i_)-repmat(bndry_vel_half{i_}',2,1));
            M_(i_next,:)=M_(i_next,:)-J_next*dt/4;

            
            b_(i_next)= sum(reshape(u_prev(j_prev,i_),size(j_prev)).*h_nbr+reshape(Rx(j_prev,i_),size(j_prev)).*(h_nbr+h_nbr_next)*dt/4,2) ...
                +J_prev*dt/4 ...
               + ([-bndry_flux_prev{i_}';bndry_flux_prev{i_}']+[-bndry_flux_half{i_}';bndry_flux_half{i_}'])*dt/4;

        end
                
        u(:,i_)=M_\b_;
        
    end
    
    
    

    
    eval_model
    eval_model_implicit
    eval_aux_model
    V_half=V;
    v_cell_half=v_cell;
    
    eval_Rx
    Rx(:,2)=Rx(:,2)+mag*exp(-((x-Q/2).^2)/(sigma)^2);
    
    u_aux=u_aux+f_aux*dt/2;
    eval_aux_model
    
    eval_model
    eval_model_implicit
    eval_aux_model
    eval_bndrys
    
%     V=V_half;
%     v_cell=v_cell_half;

    


    nu_for=abs(V)*dt/h;
    for i_=1:N_species
        
        if order==1
            f0_star = (f0_for+f0)/2-(sign(V_prev(i_)).*(f0_for-f0))/2;
        elseif order==2
            f0_star = (f0_for+f0)/2-(sign(V_prev(i_))*(1-(1-abs(nu_for_prev(i_))))*(f0_for-f0))/2;
        end
        f1_star=f0_star;
        
        if order==1
        f0_star = (f0_for+f0)/2-(sign(V(i_)).*(f0_for-f0))/2;
        elseif order==2
        f0_star = (f0_for+f0)/2-(sign(v_cell)*(1-(1-abs(nu_for(i_))))*(f0_for-f0))/2;
        end
    
    f1_star_next=f0_star;
  
        
        
        A_ = -(f1_star - f1_star(jump(:,2),:))*V_prev(i_);
        A_next_ = -(f1_star_next - f1_star_next(jump(:,2),:))*V(i_);
        M_=(heye-A_next_*dt);
        b_= ((heye)*u_prev(:,i_)+Rx(:,i_)*dt*h);
        
        
        if implicit_BC && ~isempty(bndrys{i_})
            
            i_bndry = ceil((bndrys_prev{i_}-x(1))/h)+[0; 1];
            i_bndry_half_next = ceil((bndrys_half{i_}-x(1))/h)+[0; 1];
            i_bndry_next = ceil((bndrys{i_}-x(1))/h)+[0; 1];

            inds = cat(3,i_bndry(1,:)'+[0 -1],i_bndry(1,:)'+[1 2]);
            inds_half_next = cat(3,i_bndry_half_next(1,:)'+[0 -1],i_bndry_half_next(1,:)'+[1 2]);
            inds_next = cat(3,i_bndry_next(1,:)'+[0 -1],i_bndry_next(1,:)'+[1 2]);
            
            h_bndry = min(abs(x(i_bndry)'+[-h h]/2-bndrys_prev{i_}'),hmax);
            h_nbr = [h_bndry(:) hmax-h_bndry(:)];
            h_bndry_next = min(abs(x(i_bndry_next)'+[-h h]/2-bndrys{i_}'),hmax);
            h_nbr_next = [h_bndry_next(:) hmax-h_bndry_next(:)];
            %
            M_(inds_next(:,1,:),:)=0;
            i_next = squeeze(inds_next(:,1,:));
            j_prev = cat(1,inds(:,:,1),inds(:,:,2));
            j_half_next = cat(1,inds_half_next(:,:,1),inds_half_next(:,:,2));
            j_next = cat(1,inds_next(:,:,1),inds_next(:,:,2));
            ij_next = sub2ind([N,N],repelem(i_next(:),1,2),j_next);
            M_(ij_next)=h_nbr_next;

            J_prev = [f1_star(inds(:,2,1),:);-f1_star(inds(:,2,2),:)]*u_prev(:,i_).*(V_prev(i_)-repmat(bndry_vel_prev{i_}',2,1));%we need interpolation here
            J_next = [f1_star_next(inds_next(:,2,1),:);-f1_star_next(inds_next(:,2,2),:)].*(V(i_)-repmat(bndry_vel{i_}',2,1));%we need interpolation here
            M_(i_next,:)=M_(i_next,:)-J_next*dt/2;
   
            
            b_(i_next)= sum(reshape(u_prev(j_prev,i_),size(j_prev)).*h_nbr+reshape(Rx(j_half_next,i_),size(j_prev)).*(h_nbr+h_nbr_next)*dt/2,2)...
                + J_prev*dt/2 ...
                + ([-bndry_flux_prev{i_}';bndry_flux_prev{i_}']+[-bndry_flux{i_}';bndry_flux{i_}'])*dt/2;
            
        end
        
        u(:,i_)=M_\b_;
        
%         
%         if u(i_bndry_next(1))~=0 || any(isnan(u(:)))
%             j_=1;
%             disp('this is not going to go well')
%         end
%         
%         if u(i_bndry_next(1,2)+1)~=0
%             j_=2;
%             disp('this is not going to go well')
%         end
        
        %             u(:,i_) = u(:,i_) + dudt{i_}*dt;
    end
   
    

    
    t=t+dt;

    
    
    
    if t-last_plot>=t_plot
        inds=[1 2 3];
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
    

end
