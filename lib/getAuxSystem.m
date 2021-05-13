function [u,udot] = getAuxSystem(f)


str=fileread(f);

str=regexprep(str,"%[ \%\f\w\=\(\)\+\;\:\.\*\,\]\[\-\/\'\^\?]+",""); %remove comments
str=regexprep(str,"\'[^\'\n\r]+\'",""); %remove hardcoded strings with single quotes
str=regexprep(str,'\"[^\"\n\r]+\"',""); %remove hardcoded strings with double quotes
str=regexprep(str,'function[^\=]+\=[^\=]+\)',""); %remove function definition

name='[a-zA-Z_\^][a-zA-Z_$0-9]*';

xpp_style=regexp(str,['d(' name ')/dt[ \t\f]*=[ \t\f]*([^\r\n]+)[\r\n]' ],'tokens');
u=cellfun(@(x) x{1},xpp_style,'UniformOutput',false);
udot=cellfun(@(x) x{2},xpp_style,'UniformOutput',false);

end

