                for j_=1:size(inds_back,1)
                    inds=inds_back(j_,:);
                    inds_next=inds_back_next(j_,:);
                    
                    M_(inds_next(end),:)=0;
                    M_(inds_next(end),inds_next)=h_local_next(inds_next);
%                     b_(inds_next(end))=sum((u_prev(inds,i_)+Rx_prev(inds,i_)*dt/2).*h_local(inds) + Rx(inds_next,i_)*(dt/2).*h_local_next(inds_next)+J_back(j_)*dt*h);
                    b_(inds_next(end))=sum((u_prev(inds,i_)).*h_local(inds) + Rx(inds_next,i_)*(dt).*h_local_next(inds_next)+J_back(j_)*dt);
%                     b_(inds_next(end))=sum((u_prev(inds,i_)).*h_local(inds) );
                    

                    inds=inds_for(j_,:);
                    inds_next=inds_for_next(j_,:);
                    M_(inds_next(1),:)=0;
                    M_(inds_next(1),inds_next)=h_local_next(inds_next);
%                     b_(inds_next(1))=sum((u_prev(inds,i_)+Rx_prev(inds,i_)*dt/2).*h_local(inds) + Rx(inds_next,i_)*(dt/2).*h_local_next(inds_next)-J_for(j_)*dt*h);
                    b_(inds_next(1))=sum((u_prev(inds,i_)).*h_local(inds) + Rx(inds_next,i_)*(dt).*h_local_next(inds_next)-J_for(j_)*dt);

                    
                    
                    
                    
                end