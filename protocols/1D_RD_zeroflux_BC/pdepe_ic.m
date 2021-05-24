function h=pdepe_ic()

    N_species = 0;
    N_rx = 0;
    D = 0;
    N_slow = 0;
    chems={};


    initialize_chem_params

    fp=0;
    model_fp
%     fp=fp';
    fp=fp(1:N_slow)';
    
    
    function u0=ic(x)
        
        
        u0=fp*(1+0.005*randn());
        i_Rac= find(strcmp(chems, 'Rac'));
        i_Raci= find(strcmp(chems, 'Raci'));
        
        if x<0.3 && ~isempty(i_Rac)
%             u0(i_Rac)=u0(i_Rac)*2;
        end
%         
    end

    h=@ic;

end