function V = getTransportVelocity(f,chems)


str=fileread(f);

str=regexprep(str,"%[ \%\f\w\=\(\)\+\;\:\.\*\,\]\[\-\/\'\^\?]+",""); %remove comments
str=regexprep(str,"\'[^\'\n\r]+\'",""); %remove hardcoded strings with single quotes
str=regexprep(str,'\"[^\"\n\r]+\"',""); %remove hardcoded strings with double quotes
str=regexprep(str,'function[^\=]+\=[^\=]+\)',""); %remove function definition

name='[a-zA-Z_$][a-zA-Z_$0-9\-]*';

code=' \t\f\*\+\-\/\,\=\(\)\[\]\>\<\&\~\;\:\|\{\}\^\.';

str=strjoin(regexp(str,['[^\n]*V\(' name '\)[^\n\;]*(\n|\;)'],"match"),newline);


N=length(chems);
V=repmat("0",1,N);
V=cellstr(V);
wtv=['0-9A-Za-z_$' code];
for i=1:N
    chem=chems{i};
    Vstr=regexp(str,['V\(' chem '\)[ \t\f]*=(?:[^\r\n\;]*=)?([' wtv '])+[ \t\f]*[\r\n\;]'],'tokens');
    if ~isempty(Vstr)
        V{i}=Vstr{1}{1};
    end
end
end

