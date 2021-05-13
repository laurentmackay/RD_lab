function scripts = getCalledScripts(f)
    source = fileread(f);

    scripts_match = strcat('(?<=(?:[\n\;]|^))','[ \t\f]*[a-zA-Z][a-zA-Z_0-9]*[ \t\f]*','(?=(?:$|\;|\r|\n))');%dont match script names inside of strings

    scripts = regexp(source,scripts_match,'match');
    scripts=strtrim(scripts);
    inds = cellfun(@(x) exist(x,'builtin'),scripts)==0;
    scripts = scripts(inds);
end

