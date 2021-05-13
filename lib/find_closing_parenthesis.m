function i_close = find_closing_parenthesis(str,i)
i_close=inf(size(i));
for j=1:length(i)
    k=i(j);
    if str(k)=='('
        counter=1;
    else
        error('A starting position, i, is not an opening parenthesis.')
    end
    k=k+1;
    while k<=length(str)
        if str(k)=='('
            counter=counter+1;
        elseif str(k)==')'
            counter=counter-1;
        end
        
        if counter==0
            i_close(j)=k;
            break;
        end
        
        k=k+1;
    end
    
end
end

