function [bndrys, bndry_flux] = getTransportVelocity(f,chems)


str=fileread(f);

str=regexprep(str,"%[ \%\f\w\=\(\)\+\;\:\.\*\,\]\[\-\/\'\^\?]+",""); %remove comments
str=regexprep(str,"\'[^\'\n\r]+\'",""); %remove hardcoded strings with single quotes
str=regexprep(str,'\"[^\"\n\r]+\"',""); %remove hardcoded strings with double quotes
str=regexprep(str,'function[^\=]+\=[^\=]+\)',""); %remove function definition

name='[a-zA-Z_$][a-zA-Z_$0-9\-]*';

code=' \t\f\*\+\-\/\,\=\(\)\[\]\>\<\&\~\;\:\|\{\}\^\.';

str=strjoin(regexp(str,['[^\n]*Flux\(' name '\([ \t\f]*x[ \t\f]*\=[^\n\;]+\)\)[^\n\;]*(\n|\;|$)'],"match"),newline);


N=length(chems);
V=repmat("0",1,N);
V=cellstr(V);
wtv=['0-9A-Za-z_$' code];
bndrys=cell(size(chems));
bndry_flux=cell(size(chems));
for i=1:N
    chem=chems{i};
    %there must be a better way to handle this, but for not this is the
    %most robust appraoch.
    Jstr=[regexp(str,['Flux\(' chem '\([ \t\f]*x[ \t\f]*\=([^\n\;\=]+?)\)\)[ \t\f]*=(?:[ \t\f]*Flux\([^\r\n\;]*=)+([' wtv ']+)[ \t\f]*(?:[\r\n\;]|$)'],'tokens')... %all the flux specifications leading that are on the same line, expect the last one
          regexp(str,['Flux\(' chem '\([ \t\f]*x[ \t\f]*\=([^\n\;\=]+?)\)\)[ \t\f]*=[ \t\f]*(?!Flux\([^\r\n\;]*=)([' wtv ']+)[ \t\f]*(?:[\r\n\;]|$)'],'tokens')]; % the last one
    
    
    bndrys{i}=cellfun(@(x)x{1},Jstr,'UniformOutput',false);
    bndry_flux{i}=cellfun(@(x)x{2},Jstr,'UniformOutput',false);
%     if ~isempty(Jstr)
%         J{i}=Jstr{1}{1};
%     end
end
end

