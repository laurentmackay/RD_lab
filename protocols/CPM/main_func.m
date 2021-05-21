function [B,D,N_rx,N_slow,N_species,Rx,chems,eval_Rx,eval_Rx_slow,eval_model,ic,...
induced_ic,initialize_chem_params,model_params,pic,project_fast,initialize_pic,...
panel1,results_dir] = main_func(B,D,N_rx,N_slow,N_species,Rx,chems,eval_Rx,...
eval_Rx_slow,eval_model,ic,induced_ic,initialize_chem_params,model_params,pic,...
project_fast,initialize_pic,panel1,results_dir)
model_name = 'chem_Rx_Pax_Asheesh';

plotting=usejava('desktop') && isempty(getCurrentTask());
try
    inputname(1);
catch
    deploy_model(model_name);
end


if plotting 
    
    initialize_pic
    
end

Ttot=5e4; 
noise=0.005; 
Gsize=80; 
N=150; 




shape=[N,N];
sz=prod(shape);
h=Gsize/(N-1); 
cpm_wait=5; 

vmax=3/60; 
picstep=5;
cpmsteps=5;

cpmstep0=h/vmax;
cpmstep=cpmstep0/cpmsteps;



[j, i] = meshgrid(1:shape(2),1:shape(1)); 

div=0.1;



restart=false;
tic

if ~restart
    


up = sub2ind([N,N],circshift(i,1,1),j);
down = sub2ind([N,N],circshift(i,-1,1),j);
left = sub2ind([N,N],i,circshift(j,1,2));
right = sub2ind([N,N],i,circshift(j,-1,2));

jump = zeros(sz,4);
jump(:,1) = up(:);
jump(:,2) = down(:);
jump(:,3) = left(:);
jump(:,4) = right(:);


perim = @(x) nnz(x&~x(up)) + nnz(x&~x(down)) + nnz(x&~x(left)) + nnz(x&~x(right));
com = @(x) [sum(sum(i.*x)),sum(sum(j.*x))]/nnz(x);

R=0.2*N/2;
cell_mask=(i-N/2).^2 +(j-N/2).^2 < R^2;
induced_mask=cell_mask & (i-min(i(cell_mask)))<=2*div*(max(i(cell_mask))-min(i(cell_mask)));

i0=i;
j0=j;

Per=perim(cell_mask); 
A=nnz(cell_mask); 


cell_maskp=cell_mask; 
cell_inds=zeros(N*N,1);
cell_inds(1:A)=find(cell_mask);


adj_empty = ~cell_mask(up) | ~cell_mask(down) | ~cell_mask(left) | ~cell_mask(right); 
adj_full = cell_mask(up) | cell_mask(down) | cell_mask(left) | cell_mask(right); 

bndry_cell = cell_mask & adj_empty;
bndry_empty = ~cell_mask & adj_full;
bndry_mask = bndry_cell | bndry_empty;
bndry = find( bndry_mask );

bndry_up=cell_mask  & ~cell_mask(up);
bndry_down=cell_mask  & ~cell_mask(down);
bndry_l=cell_mask  & ~cell_mask(left);
bndry_r=cell_mask  & ~cell_mask(right);

bndry_ud= bndry_up | bndry_down;
bndry_lr= bndry_l | bndry_r;

bndrys=[bndry_up(:) bndry_down(:) bndry_l(:) bndry_r(:)];

initialize_chem_params
    initialize_chem_params

i_chem_0 = ((1:N_species)-1)*sz;








Rho_Square = 1;    
Rac_Square = 1;    
Pax_Square = 1;    

N_instantaneous=50;

model_params

VolCell=(0.5*10^-6)*(h*10^-6)^2; 
muM = 6.02214*10^23*VolCell*10^3*10^-6; 



if length(D)==9
    Rho_Square=muM*3.1;
    Rac_Square=muM*7.5;
    C_Square=muM*2.4;
end


if length(D)==9
    Rho_Square=muM*3.1;
    Rac_Square=muM*7.5;
    C_Square=muM*2.4;
end




RhoRatio_u = 0.8;
RacRatio_u = 0.045;

PaxRatio_u = 0.082;

RhoRatio_i = 0.02;
RacRatio_i = 0.35; 

if length(D)==9
    RacRatio_u = 0.35; 
    RacRatio_i = 0.85; 
    CRatio=[0.6; 0.5];
    
    RhoRatio_i = 0.05;
    RhoRatio_u = 0.4;
end

if length(D)==9
    RacRatio_u = 0.35; 
    RacRatio_i = 0.85; 
    CRatio=[0.6; 0.5];
    
    RhoRatio_i = 0.05;
    RhoRatio_u = 0.4;
end





PaxRatio_i = 0.2;

RhoRatio=[RhoRatio_u; RhoRatio_i];
RacRatio=[RacRatio_u; RacRatio_i];
PaxRatio=[PaxRatio_u; PaxRatio_i];




    fp=0; 
    eval('model_fp');
    rhs_anon=0; 
    eval('model_anon')
    tol=1e-14;
    
    relax=any(abs(rhs_anon(fp))>tol);
    
    fp0=fp;
    while any(abs(rhs_anon(fp))>tol)
        
        [T_vec,Y_vec] = ode15s(@(t,u) rhs_anon(u)',[0 1e4],fp,odeset('NonNegative',1:N_species));
        fp=Y_vec(end,:);
        
        
    end
    
    if relax
        disp('Relaxed to a new fixed point:')
        disp(strjoin(strcat(chems,'=',string(fp))),', ')
        fid=fopen(which('model_fp'),'w');
        fwrite(fid,['fp = [' num2str(fp,12) '];'],'char');
        fclose(fid);
    end

    
    
    
    






induced_ic

mask=induced_mask&cell_mask;
[tmp,tmp2]=meshgrid((0:N_species-1)*sz,find(mask));
i_induced=tmp+tmp2;

x=zeros([shape ,N_species]); 

if ~isempty(ic)
    x(i_induced)=repmat(ic,nnz(mask),1);
    mask=~induced_mask&cell_mask;
else
    mask=cell_mask;
end

[tmp,tmp2]=meshgrid((0:N_species-1)*sz,find(mask));
x(tmp+tmp2)=repmat(fp,nnz(mask),1);

x=(1+noise*rand(size(x))).*x;
x(x<0)=0;


alpha_chem=zeros([shape N_rx]);
alpha_rx=zeros(1,N_rx);
alpha_diff=zeros(6,1); 
ir0=((1:N_rx)-1)*sz;

vox=cell_inds(1:A);

eval_model






lam_a=0.3*h^4; 
lam_p_0=0.3;
lam_p=lam_p_0*h^2; 
J=0.1*h; 

B_0=0.7;
B_rho=(B_0/0.3)*h^2;
B_R=(B_0/0.3)*(.18/.13)*h^2; 


a=A; 
per=Per*(1 + (sqrt(2)-1)/2); 
Hb=0; 
T=0.5; 






H0=lam_a*(a-A)^2+lam_p*(per-Per)^2+J*Per; 
dH_chem=0; 

grow_count=0;
shrink_count=0;
end

r_frac= sqrt(2)/2;

dt=max(h^2*r_frac/(2*max(D)),0.01);


lastplot=0;
lastcpm=0;


iter=0;

time=0;
reactions=0;

Nsteps=floor(Ttot/min(cpmstep0*cpm_wait))+1;


center=zeros(2,Nsteps);
Results=zeros([shape,N_species+1,Nsteps]);
Times=zeros(1,Nsteps);

areas=zeros(1,Nsteps);
perims=zeros(1,Nsteps);

Ham0=zeros(1,Nsteps);
Hchem=zeros(1,Nsteps);


iter=iter+1;

center(:,iter)=com(cell_mask);
Results(:,:,1,iter)=cell_mask;
Results(:,:,2:end,iter)=x; 
Times(iter)=time;

areas(iter)=A;
perims(iter)=Per;

Ham0(iter)=H0;
Hchem(iter)=dH_chem;


u = reshape(x,[sz ,size(x,3)]);
eval_model
pic 
if plotting && usejava('desktop') && isempty(getCurrentTask())
    delete test.gif
    gif('test.gif','frame',panel1)
end

time=0;






N_dim=size(jump,2);
ij0=(1:(sz))';
diffuse_mask=false(N_dim,sz);
num_diffuse=zeros(1,size(jump,2));
ij_diffuse=zeros(4,(N)*(N));
diffusing_species_sum=zeros(N_dim,length(D));
num_vox_diff=zeros(1,sz);
pT0 = zeros(sz,length(D));
pi = zeros(N_dim,sz);

diffusing_species=1:N_species; 


for drx=1:size(jump,2) 
    diffuse_mask(drx,:)=cell_mask(jump(:,drx))&cell_mask(:); 
    
end

for vox=1:size(diffuse_mask,2)
    num_vox_diff(vox)=nnz(diffuse_mask(:,vox)); 
end

for i=1:A
    vox=cell_inds(i);
    pT0(vox,:) = num_vox_diff(vox)*D/(h^2);
    pi(:,vox)=diffuse_mask(:,vox)'./sum(diffuse_mask(:,vox));
end
id0=(diffusing_species-1)*sz;


alpha_diff=sum(diffusing_species_sum).*D/(h*h);
alpha_rx=sum(alpha_chem(ir0 + cell_inds(1:A)));
alpha_rx2=alpha_rx;
a_total=sum(alpha_diff)+sum(alpha_rx(:));


numDiff=0;
numReac=0;
cpmcounter=0;
Timeseries=[];
TRac=[];
TRho=[];
TPax=[];

last_time=time; 
rx_speedup=2;
rx_count=zeros(shape);
dt_diff=zeros(size(D));
P_diff=0.5;


d0=sum(x(:));



if isempty(getCurrentTask()); copyNum=[]; end



T_integration = cpmstep;
keep_running=true;

i_rac = find(strcmp(chems,'Rac')); 
inds=cell_inds(1:A)+sz*(i_rac-1);
d_Rac_0=max(max(x(inds)))-min(min(x(inds)));

while time<Ttot && keep_running
    A=nnz(cell_mask); 
    cell_inds(1:A)=find(cell_mask); 
    
    while (time-last_time)<Ttot

       
        


u = x(cell_inds(1:A) + i_chem_0);

interior=~bndrys&cell_mask(:);

vox=repmat((1:sz)',1,N_dim);
vox=vox(interior)';




row = find(interior);
N_ind = length(row);
i = [row'; row'];
j=[ vox(:)';  jump(row)';];

Delta=repmat([-1/h; +1/h],N_ind,1);
u_x = sparse(i,j,Delta,numel(interior),sz);

[i2,j2,v ] = find(u_x);
i2=mod(i2-1,sz)+1;
u_xx = sparse(i2,j2,v/h,sz,sz);

u_xx=u_xx(cell_inds(1:A),cell_inds(1:A));




eval_Rx_slow
u_prev = u(:,1:N_slow);

t0=time;

eye = speye(A);
MAT_list = arrayfun(@(Di)( eye*3/(2*dt)-Di*u_xx),D(1:N_slow),'UniformOutput',0); 
if any(u(:)<0)
    disp('negatory pig pen')
end

while time-t0<T_integration
    

    
    Rx_prev=Rx;
    eval_Rx_slow
    u_curr = u(:,1:N_slow);
    b_=(2*u_curr-u_prev/2)/dt + (2*Rx-Rx_prev); 
    u_prev=u_curr;

    for i = 1:N_slow
        u(:,i) = MAT_list{i}\b_(:,i);
    end
    
    project_fast
    

    time=time+dt;


end

    if any(u(:)<0)
        error('Negative solutions detected, please use a smaller timestep dt')
    end
x(cell_inds(1:A) + i_chem_0) = u(:);
u = reshape(x,[sz ,size(x,3)]);
eval_Rx 

if time>=lastcpm+cpmstep
            
            for kk=1:(2*Per)/cpmsteps 
                try
                    if all(isfinite([lam_a,lam_p]))
    
    adj_empty = ~cell_mask(up) | ~cell_mask(down) | ~cell_mask(left) | ~cell_mask(right); 
adj_full = cell_mask(up) | cell_mask(down) | cell_mask(left) | cell_mask(right); 

bndry_cell = cell_mask & adj_empty;
bndry_empty = ~cell_mask & adj_full;
bndry_mask = bndry_cell | bndry_empty;
bndry = find( bndry_mask );

bndry_up=cell_mask  & ~cell_mask(up);
bndry_down=cell_mask  & ~cell_mask(down);
bndry_l=cell_mask  & ~cell_mask(left);
bndry_r=cell_mask  & ~cell_mask(right);

bndry_ud= bndry_up | bndry_down;
bndry_lr= bndry_l | bndry_r;

bndrys=[bndry_up(:) bndry_down(:) bndry_l(:) bndry_r(:)];
is_discrete = all(mod(x(cell_inds(1:A)),1)==0);
    
    
    if any(cell_maskp~=cell_mask)
        error('not reseting')
    end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    rho_eq=mean(RhoRatio(find(cell_mask)));
    R_eq=mean(RacRatio(find(cell_mask)));
    Ncell_mask=squeeze(sum(sum(x))); 
    A0=A;
    
    no_holes=false;
    
    while ~no_holes
        vox_trial = bndry(randi(length(bndry)));
        
        r=randi(size(jump,2));
        vox_ref=jump(sub2ind([sz,4],vox_trial,r));
        cell_maskp(vox_trial) = cell_mask(vox_ref);
        
        Per=perim(cell_maskp); 
        A=nnz(cell_maskp); 
        HA=lam_a*(a-A)^2+lam_p*(per-Per)^2+J*Per; 
        dH=HA-H0;
        no_holes = getfield(bwconncomp(cell_maskp,4),'NumObjects')==1 && getfield(bwconncomp(~cell_maskp,4),'NumObjects')==1 ;
        if ~no_holes
            cell_maskp(vox_trial)=cell_mask(vox_trial);
        end
    end
    
    
    reacted = 0;
    if  no_holes
        
        grow= cell_maskp(vox_trial) & ~cell_mask(vox_trial);
        shrink= ~cell_maskp(vox_trial) & cell_mask(vox_trial);
        
        
        if grow
            f=1;
            dH_chem=B_rho*(RhoRatio(vox_ref)-rho_eq)-B_R*(RacRatio(vox_ref)-R_eq);
            
        elseif shrink
            f=-1;
            dH_chem=-B_rho*(RhoRatio(vox_trial)-rho_eq)+B_R*(RacRatio(vox_trial)-R_eq);
            
        end
        
        
        if (grow || shrink) && rand<exp(-(dH+dH_chem+Hb)/T)
            reacted=1;
            
            cm0=cell_mask;
            
            
            
            cell_mask=cell_maskp; 
            
            if shrink
                bndry_up=cell_mask  & ~cell_mask(up);
                bndry_down=cell_mask  & ~cell_mask(down);
                bndry_l=cell_mask  & ~cell_mask(left);
                bndry_r=cell_mask  & ~cell_mask(right);
                
                bndry_ud= bndry_up | bndry_down;
                bndry_lr= bndry_l | bndry_r;
                
            end
            
            
            Per=perim(cell_mask);
            A=nnz(cell_mask);
            
            
            
            if grow
                inds=cell_inds(1:A-1);
                cell_inds(1:A)=find(cell_mask);
            else
                cell_inds(1:A)=find(cell_mask);
                inds=cell_inds(1:A);
            end
            
            
            
            if grow
                dist=max(abs(i0(vox_ref)-i0(inds)),abs(j0(vox_ref)-j0(inds)));
                
            else
                dist=max(abs(i0(vox_trial)-i0(inds)),abs(j0(vox_trial)-j0(inds)));
                
            end
            
            min_dist=5600;
            
            
            
            
            
            
            x0=x;
            inds2=inds+i_chem_0;
            i_trial=vox_trial+i_chem_0;
            
            Ts=sum(x(inds2));
            if grow
                us=x(vox_ref+i_chem_0);
                f=Ts./(Ts+us);
                x(i_trial)=us;
                inds2=[inds2; i_trial];
            else
                ut=x(i_trial);
                f=1+(ut./Ts);
                x(i_trial)=0;
            end
            
            if is_discrete
                x(inds2)=floor(x(inds2).*f)+[zeros(1,N_species); diff(floor(cumsum(rem(x(inds2).*f,1.0))+1e-5))]; 
            else
                i3=Ts>0;
                x(inds2(:,i3))=x(inds2(:,i3)).*f(i3);
                if ~grow && any(i3)
                    x(inds2(:,~i3))=repmat(ut(~i3),size(inds2,1),1)/size(inds2,1);
                end
            end
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            I=[vox_trial vox_ref]; 
            H0=HA; 
            
            
            Per=perim(cell_mask);
            A=nnz(cell_mask);
            cell_inds(1:A)=find(cell_mask);
            
            
            if grow
                vox=cell_inds(1:A);
            else
                vox=[cell_inds(1:A); vox_trial];
            end
            
            
            
            alpha_rx=sum(alpha_chem(ir0 + cell_inds(1:A)));
            if grow
                
                grow_count=grow_count+1;
            else
                
                shrink_count=shrink_count+1;
            end
            
        end
    end
    
    if ~reacted
        
        cell_maskp=cell_mask;
        Per=perim(cell_mask); 
        A=nnz(cell_mask); 
        cell_inds(1:A)=find(cell_mask);
    else
        eval_model
    end
    
    
    
    Ncell_maskp=squeeze(sum(sum(x)));
    
    if (is_discrete & any(Ncell_mask~=Ncell_maskp)) | (~is_discrete & any(abs(Ncell_mask-Ncell_maskp)>1e-5))
        error('molecule loss')
    end
    
    if min(cell_mask(:))<0
        error('Oh no! D: (negtive numbers)')
    end
end
catch err
                    rethrow(err)
                    break;
                end
                
                adj_empty = ~cell_mask(up) | ~cell_mask(down) | ~cell_mask(left) | ~cell_mask(right); 
adj_full = cell_mask(up) | cell_mask(down) | cell_mask(left) | cell_mask(right); 

bndry_cell = cell_mask & adj_empty;
bndry_empty = ~cell_mask & adj_full;
bndry_mask = bndry_cell | bndry_empty;
bndry = find( bndry_mask );

bndry_up=cell_mask  & ~cell_mask(up);
bndry_down=cell_mask  & ~cell_mask(down);
bndry_l=cell_mask  & ~cell_mask(left);
bndry_r=cell_mask  & ~cell_mask(right);

bndry_ud= bndry_up | bndry_down;
bndry_lr= bndry_l | bndry_r;

bndrys=[bndry_up(:) bndry_down(:) bndry_l(:) bndry_r(:)];
end
            
            diffusing_species=1:N_species; 


for drx=1:size(jump,2) 
    diffuse_mask(drx,:)=cell_mask(jump(:,drx))&cell_mask(:); 
    
end

for vox=1:size(diffuse_mask,2)
    num_vox_diff(vox)=nnz(diffuse_mask(:,vox)); 
end

for i=1:A
    vox=cell_inds(i);
    pT0(vox,:) = num_vox_diff(vox)*D/(h^2);
    pi(:,vox)=diffuse_mask(:,vox)'./sum(diffuse_mask(:,vox));
end
lastcpm=time;
            cpmcounter=cpmcounter+1;
        end
                
        if time>=lastplot+picstep || time==lastcpm 
 
            if cpmcounter==cpmsteps*cpm_wait
              u = reshape(x,[sz ,size(x,3)]);
              pic
              lastplot=time; 
            
                i_rac = find(strcmp(chems,'Rac')); 
                inds=cell_inds(1:A)+sz*(i_rac-1);
                d_Rac=max(max(x(inds)))-min(min(x(inds)));
                if plotting
                    gif
                end
                    disp([num2str(copyNum) ': B=' num2str(B) ', t=' num2str(time) ', delta_Rac=' num2str(d_Rac)])
                
                iter=iter+1;

center(:,iter)=com(cell_mask);
Results(:,:,1,iter)=cell_mask;
Results(:,:,2:end,iter)=x; 
Times(iter)=time;

areas(iter)=A;
perims(iter)=Per;

Ham0(iter)=H0;
Hchem(iter)=dH_chem;

cpmcounter=0;
                
                i_rac = find(strcmp(chems,'Rac')); 
                inds=cell_inds(1:A)+sz*(i_rac-1);
                
            end
            
            
        end
        
    end
    
    last_time=time;
    
    
    
    diffusing_species=1:N_species; 


for drx=1:size(jump,2) 
    diffuse_mask(drx,:)=cell_mask(jump(:,drx))&cell_mask(:); 
    
end

for vox=1:size(diffuse_mask,2)
    num_vox_diff(vox)=nnz(diffuse_mask(:,vox)); 
end

for i=1:A
    vox=cell_inds(i);
    pT0(vox,:) = num_vox_diff(vox)*D/(h^2);
    pi(:,vox)=diffuse_mask(:,vox)'./sum(diffuse_mask(:,vox));
end
end

toc


try
    inputname(1);
catch
    save_dir=results_dir();
end

fn=strcat(save_dir,'final_B_', num2str(B), '_copy', int2str(copyNum), '.mat');
disp(['saving to: ' fn]);
close all


save(fn,'-v7.3');


end