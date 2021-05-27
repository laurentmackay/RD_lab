function  mk_protocol_files()
global RD_base protocol active_model

if isempty(RD_base)
    get_RD_base()
end

if isempty(protocol) || isempty(active_model)
    return
end

save_dir = work_dir();
model_file=strcat(save_dir,'model.mat');
if exist(model_file,'file')~=2
    deploy_model(active_model,1);%force-deploy for older models
end

load(model_file,'M','str');



extra_folder = strcat(RD_base,'protocols',filesep,protocol,filesep,'rxn_files');
if exist(extra_folder,'file')~=7
    return
end





extra_files=dir(strcat(RD_base,'protocols',filesep,protocol,filesep,'rxn_files',filesep,'*.m'));
if isempty(extra_files)
    return 
end
hash = max(cellfun(@datenum,{extra_files.date}))+datenum(dir(strcat(RD_base,'models',filesep,active_model)).date);
extra_files = {extra_files.name};
hash_file = strcat(work_dir,[protocol '.hash']);

if exist(hash_file,'file')~=2 || str2double(fileread(hash_file))<hash

    fprintf(['Generating model-specific files for ' active_model ' and the protocol ' protocol '...'],'%s')
    rxn_files_path=strcat(RD_base,'protocols',filesep,protocol,filesep,'rxn_files',filesep);
    addpath(rxn_files_path);
    

    
    for file=extra_files
        file = regexprep(file{1},'\..*','');
        feval(file,str,M,save_dir);
    end
    
    rmpath(rxn_files_path);
    fprintf(['Done' newline],'%s')
    
dlmwrite( hash_file, num2str(hash,20), '');
end
end

