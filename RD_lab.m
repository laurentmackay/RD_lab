classdef RD_lab < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        RD_labUIFigure                 matlab.ui.Figure
        TabGroup                       matlab.ui.container.TabGroup
        ModelTab                       matlab.ui.container.Tab
        DeployModelButton              matlab.ui.control.Button
        SelectModelDropDownLabel       matlab.ui.control.Label
        SelectModelDropDown            matlab.ui.control.DropDown
        ModelSpecificationTextAreaLabel  matlab.ui.control.Label
        ModelSpecificationTextArea     matlab.ui.control.TextArea
        SaveChangesButton              matlab.ui.control.Button
        OpenDirectoryButton            matlab.ui.control.Button
        SaveonDeployCheckBox           matlab.ui.control.CheckBox
        ProtocolTab                    matlab.ui.container.Tab
        SelectProtocolDropDownLabel    matlab.ui.control.Label
        SelectProtocolDropDown         matlab.ui.control.DropDown
        ScriptTree                     matlab.ui.container.Tree
        ProtocolVariableTable          matlab.ui.control.Table
        RunProtocolButton              matlab.ui.control.Button
        SaveResultsCheckBox            matlab.ui.control.CheckBox
        FilenameEditFieldLabel         matlab.ui.control.Label
        FilenameEditField              matlab.ui.control.EditField
        ExperimentTab                  matlab.ui.container.Tab
        NameEditFieldLabel             matlab.ui.control.Label
        NameEditField                  matlab.ui.control.EditField
        ResultsExplorerTab             matlab.ui.container.Tab
        TabGroup2                      matlab.ui.container.TabGroup
        RawVariablesTab                matlab.ui.container.Tab
        ResultsVariableTable           matlab.ui.control.Table
        LaunchVisualizerButton         matlab.ui.control.Button
        SharedVariablesOnlyCheckBox    matlab.ui.control.CheckBox
        PostProcessingTab              matlab.ui.container.Tab
        Yaxis2DDropDownLabel           matlab.ui.control.Label
        Yaxis2DDropDown                matlab.ui.control.DropDown
        Yaxis3DDropDownLabel           matlab.ui.control.Label
        Yaxis3DDropDown                matlab.ui.control.DropDown
        XaxisDropDownLabel             matlab.ui.control.Label
        XaxisDropDown                  matlab.ui.control.DropDown
        SelectResultsCtrlorShiftClicktoSelectMultiplePanel  matlab.ui.container.Panel
        ModelsLabel                    matlab.ui.control.Label
        ExperimentsLabel               matlab.ui.control.Label
        ExperimentsTree                matlab.ui.container.Tree
        NoneNode_2                     matlab.ui.container.TreeNode
        ModelsTree                     matlab.ui.container.Tree
        NoneNode                       matlab.ui.container.TreeNode
        AvailableFilesLabel            matlab.ui.control.Label
        FilesTree                      matlab.ui.container.Tree
        NoneNode_3                     matlab.ui.container.TreeNode
        ResultsExplorerTab_2           matlab.ui.container.Tab
        TabGroup2_2                    matlab.ui.container.TabGroup
        IllustrativeTab_2              matlab.ui.container.Tab
        ResultsVariableTable_2         matlab.ui.control.Table
        DCheckBox_5                    matlab.ui.control.CheckBox
        DCheckBox_6                    matlab.ui.control.CheckBox
        PseudocolorCheckBox_3          matlab.ui.control.CheckBox
        SurfaceCheckBox_3              matlab.ui.control.CheckBox
        QuantitativeTab_2              matlab.ui.container.Tab
        Yaxis2DDropDown_2Label         matlab.ui.control.Label
        Yaxis2DDropDown_2              matlab.ui.control.DropDown
        Yaxis3DDropDown_2Label         matlab.ui.control.Label
        Yaxis3DDropDown_2              matlab.ui.control.DropDown
        XaxisDropDown_2Label           matlab.ui.control.Label
        XaxisDropDown_2                matlab.ui.control.DropDown
        VisualizeButton_3              matlab.ui.control.Button
        SelectResultsCtrlorShiftClicktoSelectMultiplePanel_2  matlab.ui.container.Panel
        ModelsLabel_2                  matlab.ui.control.Label
        ExperimentsLabel_2             matlab.ui.control.Label
        ExperimentsTree_2              matlab.ui.container.Tree
        NoneNode_4                     matlab.ui.container.TreeNode
        ModelsTree_2                   matlab.ui.container.Tree
        NoneNode_5                     matlab.ui.container.TreeNode
        AvailableFilesLabel_2          matlab.ui.control.Label
        FilesTree_2                    matlab.ui.container.Tree
        NoneNode_6                     matlab.ui.container.TreeNode
        SharedVariablesOnlyCheckBox_2  matlab.ui.control.CheckBox
        ActiveModelLabel               matlab.ui.control.Label
        ActiveProtocolLabel            matlab.ui.control.Label
        ActiveExperimentLabel          matlab.ui.control.Label
        ModelLabel                     matlab.ui.control.Label
        ProtocolLabel                  matlab.ui.control.Label
        ExperimentLabel                matlab.ui.control.Label
    end

    
    properties (Access = private)
        model = 'None' % Description
        active_model = []
        protocol = 'None'
        active_protocol = []
        background_saved = false;
        
    end
    
    methods (Access = private)
        
        function models = getModels(app)
            global RD_base
            models = dir(strcat(RD_base,"models/*"));
            models = {models(arrayfun(@(x) x.name(1)~='.',models)).name};
        end
        
        function prots = getProtocols(app)
            global RD_base
            prots = dir(strcat(RD_base,"protocols/"));
            prots ={prots(arrayfun(@(x) x.name(1)~='.',prots)).name};
        end
        
        function setModel(app, model)
            global RD_base
            app.model=model;
            app.ModelSpecificationTextArea.Value = fileread(strcat(RD_base,"models/",model));
            app.SaveChangesButton.Enable=false;
            app.checkModelDirectory()
        end
        
        function checkModelDirectory(app)
            global RD_base
            if ~isempty(ls(strcat(RD_base,'_',app.model)))
                app.OpenDirectoryButton.Enable=true;
            else
                app.OpenDirectoryButton.Enable=false;
            end
        end
        
        
        function setProtocol(app,prot)
            global protocol RD_base
            set_protocol(prot)
            
            main_path = strcat(RD_base,"protocols/",prot,'/main.m');
            main = dir(main_path);
            app.protocol=prot;
            if ~isempty(main)
                %                 pos=app.ScriptTree.Position;
                %                 app.ScriptTree=uitree(app.ProtocolTab);
                app.ScriptTree.Children.delete()
                app.getScriptTree(main_path, app.ScriptTree);
                %                 app.ScriptTree.Position=pos;
                
                
                app.ProtocolVariableTable.Data=app.ScriptTree.Children(1).NodeData;
            end
            app.ProtocolLabel.Text=protocol;
            
            app.SaveResultsCheckBox.Enable=1;
        end
        
        function node = getScriptTree(app, f, parent)
            
            [path, name, ~] = fileparts(f);
            
            [local_vars,local_vals]=getInitialized(f);
            data=[local_vars' local_vals'];
            node = uitreenode(parent,'Text',name,'NodeData',data);
            
            subs = getCalledScripts(f);
            
            if ~isempty(subs)
                for s=subs
                    try
                        app.getScriptTree(strcat(path,'/', s{1}, '.m'), node);
                    catch %this is sloppy, you should use which() and just check that the path is in protocols/... but even that is not gonna catch everything...there is an OOP appraoch that would get around that though
                    end
                end
            end
            
        end
        
        function handleNewFileNodes(app, selectedNodes, root_dir_func)
            
            
            orig_children = app.FilesTree.Children;
            has_match = false(size(orig_children));
            
            for node = selectedNodes
                if ~isempty(node.NodeData)
                    root_data = root_dir_func(node.Text);
                    match = strcmp({orig_children.Text}, node.Text) & strcmp({orig_children.NodeData}, root_data);
                    if ~any(match)
                        root=uitreenode(app.FilesTree, 'Text', node.Text,'NodeData',root_data);
                        cellfun(@(x) uitreenode(root, 'Text',x), node.NodeData);
                        expand(root)
                    else
                        has_match(match)=true;
                    end
                end
            end
            
            deletable = arrayfun(@(x) strcmp(x.Text,'<None>') || strcmp(root_dir_func(x.Text),x.NodeData) ,orig_children);
            orig_children(~has_match & deletable).delete()
            
            if isempty(app.FilesTree.Children)
                uitreenode(app.FilesTree,'Text','<None>');
            end
            
        end
        
        function saveModelText(app)
            global RD_base
            fid = fopen(strcat(RD_base,"models/",app.model),'w');
            fprintf(fid, '%s', strjoin(app.ModelSpecificationTextArea.Value,newline));
            fclose(fid);
        end
    end
    
    
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            p=mfilename('fullpath');
            addpath(strcat(regexprep(p,[  '\' filesep '[^\' filesep ']+$'],''),filesep,'lib'));
            app.FilenameEditField.Enable=0;
            app.SaveResultsCheckBox.Enable=0;
            
            models = app.getModels();
            app.SelectModelDropDown.Items=models;
            if ~isempty(models)
                app.setModel(models{1})
            end
            
            
            prots=app.getProtocols();
            app.SelectProtocolDropDown.Items=prots;
            if ~isempty(prots)
                app.setProtocol(prots{1})
            end
            
            app.ProtocolVariableTable.ColumnName={'Variable','Value'};
            
            
            
            
            
            
            
        end

        % Value changed function: SelectProtocolDropDown
        function SelectProtocolDropDownValueChanged(app, event)
            value = app.SelectProtocolDropDown.Value;
            
            app.setProtocol(value)
            
        end

        % Selection changed function: ScriptTree
        function ScriptTreeSelectionChanged(app, event)
            selectedNodes = app.ScriptTree.SelectedNodes;
            app.ProtocolVariableTable.Data = selectedNodes(1).NodeData;
        end

        % Button pushed function: RunProtocolButton
        function RunProtocolButtonPushed(app, event)
            global protocol
            if isempty(app.active_model) || strcmp(app.model,'None')
                msgbox('Invalid Command: Please deploy a model first.')
            else
                mk_protocol_files();
                if app.SaveResultsCheckBox.Value
                    if isempty(app.FilenameEditField.Value)
                        [fn,path]=uiputfile('*.mat','Save Filename',strcat(results_dir(),protocol,'.mat'));
                    else
                        [fn,path]=strcat(results_dir(),app.FilenameEditField.Value);
                    end
                    mk_fun('main',{},{},strcat("save('", strcat(path,fn), "')"));
                else
                    mk_fun('main');
                end
                clear main_func
                disp(['Running ' protocol '...'])
                main_func()
            end
            
        end

        % Button pushed function: DeployModelButton
        function DeployModelButtonPushed(app, event)
            global active_model
            if ~isempty(app.model) && ~strcmp(app.model,'None')
                if app.SaveonDeployCheckBox.Value
                    app.saveModelText()
                    app.SaveChangesButton.Enable=false;
                end
                
                %                 try
                deploy_model(app.model,1);
                
                app.active_model=app.model;
                app.ModelLabel.Text=active_model;
                app.checkModelDirectory()                
            end
        end

        % Value changed function: SelectModelDropDown
        function SelectModelDropDownValueChanged(app, event)
            model = app.SelectModelDropDown.Value;
            app.setModel(model)
        end

        % Value changed function: SaveResultsCheckBox
        function SaveResultsCheckBoxValueChanged(app, event)
            value = app.SaveResultsCheckBox.Value;
            app.FilenameEditField.Enable=value;
        end

        % Selection change function: TabGroup2
        function TabGroup2SelectionChanged(app, event)
            selectedTab = app.TabGroup2.SelectedTab;
        end

        % Selection change function: TabGroup
        function TabGroupSelectionChanged(app, event)
            selectedTab = app.TabGroup.SelectedTab;
            global RD_base
            if strcmp(selectedTab.Title,'Results Explorer')
                models=cellstr(ls(strcat(RD_base,'_*')));
                model_results = cellfun(@(x) cellstr(ls(strcat(x,filesep,'results'))),models,'UniformOutput',0);
                has_results = cellfun(@(x) ~isempty(x{1}), model_results);
                
                models = cellfun(@(x) x(2:end),models(has_results),'UniformOutput',0);
                model_results=model_results(has_results);
                
                is_file = cellfun(@(x) cellfun(@(y) ~all(y=='.'),x),model_results,'UniformOutput',0);
                model_results = cellfun(@(x,i) x(i), model_results,is_file,'UniformOutput',0);
                
                app.ModelsTree.Children.delete();
                cellfun(@(x,y) uitreenode(app.ModelsTree,'Text',x, 'NodeData', y),['<None>'; models],[{''}; model_results]);
                
                
                experiments = cellstr(ls(strcat(RD_base,'experiments/*')));
                is_dir  = cellfun(@(x) ~all(x=='.'),experiments);
                experiments = experiments(is_dir);
                
                experiment_results = cellfun(@(x) cellstr(ls(strcat(RD_base,'experiments',filesep,x))),experiments,'UniformOutput',0);
                
                is_file = cellfun(@(x) cellfun(@(y) ~all(y=='.'),x),experiment_results,'UniformOutput',0);
                experiment_results = cellfun(@(x,i) x(i), experiment_results,is_file,'UniformOutput',0);
                
                
                
                app.ExperimentsTree.Children.delete();
                cellfun(@(x, y) uitreenode(app.ExperimentsTree,'Text',x,'NodeData',y),['<None>'; experiments],[{''}; experiment_results]);
                %                 app.ExperimentsListBox.Items=['<None>' experiments];
                
                
                
                
            end
        end

        % Selection changed function: ModelsTree
        function ModelsTreeSelectionChanged(app, event)
            global RD_base
            selectedNodes = app.ModelsTree.SelectedNodes';
            app.handleNewFileNodes(selectedNodes ,@(x) strcat(RD_base,'_',x,'/results'))
        end

        % Selection changed function: ExperimentsTree
        function ExperimentsTreeSelectionChanged(app, event)
            global RD_base
            selectedNodes = app.ExperimentsTree.SelectedNodes';
            app.handleNewFileNodes(selectedNodes, @(x) strcat(RD_base, 'experiments/',x))
        end

        % Selection changed function: FilesTree
        function FilesTreeSelectionChanged(app, event)
            selectedNodes = app.FilesTree.SelectedNodes;
            is_file = arrayfun(@(x) isempty(x.Children)  ,selectedNodes);
            
            selectedNodes=selectedNodes(is_file);
            if ~isempty(selectedNodes)
                for node = selectedNodes'
                    if isempty(node.NodeData) && ischar(node.Parent.NodeData)
                        node.NodeData=whos('-file',strcat(node.Parent.NodeData,'/',node.Text));
                    end
                end
                
                data={selectedNodes.NodeData};
                names=cellfun(@(x) {x.name},data,'UniformOutput',false);
                
                [names_tot, ia, ic] = unique([names{:}],'stable');
                if app.SharedVariablesOnlyCheckBox.Value
                    disp('this is going to be implemented later bro')
                end
                sizes = cellfun(@(nm,d) {d(index_B(names_tot,nm)).size}, names, data,'UniformOutput',0);
                sizes_tot = cell(length(names_tot),1);
                [sizes_tot{:}]=deal({});
                jj = cellfun(@(nm) index_A(names_tot,nm), names, 'UniformOutput',0);
                for i = 1:size(selectedNodes,1)
                    for k=1:length(jj{i})
                        sizes_tot{jj{i}(k)}{end+1}=mat2str(sizes{i}{k});
                    end
                end
                sizes_tot = cellfun(@(sz) strjoin(unique(sz,'stable'), newline),sizes_tot,'UniformOutput',false);
                
                
                plot_flag = false(size(sizes_tot));
                old_data  = app.ResultsVariableTable.Data;
                if ~isempty(old_data)
                    
                    [~,i_intersect,i_old]=intersect(names_tot',old_data.Var1);
                    plot_flag(i_old)=old_data.plot_flag(i_intersect);
                end
                app.ResultsVariableTable.Data=table(names_tot', sizes_tot, plot_flag);
            else
                app.ResultsVariableTable.Data=[];
                
            end
        end

        % Button pushed function: OpenDirectoryButton
        function OpenDirectoryButtonPushed(app, event)
            global RD_base
            winopen(strcat(RD_base,'_',app.model))
        end

        % Value changed function: ModelSpecificationTextArea
        function ModelSpecificationTextAreaValueChanged(app, event)
            if ~app.SaveChangesButton.Enable
                app.SaveChangesButton.Enable=true;
            end
        end

        % Button pushed function: SaveChangesButton
        function SaveChangesButtonPushed(app, event)
            app.SaveChangesButton.Enable=false;
            app.saveModelText()
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create RD_labUIFigure and hide until all components are created
            app.RD_labUIFigure = uifigure('Visible', 'off');
            app.RD_labUIFigure.Position = [100 100 779 557];
            app.RD_labUIFigure.Name = 'RD_lab';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.RD_labUIFigure);
            app.TabGroup.SelectionChangedFcn = createCallbackFcn(app, @TabGroupSelectionChanged, true);
            app.TabGroup.Position = [11 88 760 460];

            % Create ModelTab
            app.ModelTab = uitab(app.TabGroup);
            app.ModelTab.Title = 'Model';

            % Create DeployModelButton
            app.DeployModelButton = uibutton(app.ModelTab, 'push');
            app.DeployModelButton.ButtonPushedFcn = createCallbackFcn(app, @DeployModelButtonPushed, true);
            app.DeployModelButton.Position = [464 398 100 22];
            app.DeployModelButton.Text = 'Deploy Model';

            % Create SelectModelDropDownLabel
            app.SelectModelDropDownLabel = uilabel(app.ModelTab);
            app.SelectModelDropDownLabel.HorizontalAlignment = 'right';
            app.SelectModelDropDownLabel.Position = [44 398 75 22];
            app.SelectModelDropDownLabel.Text = 'Select Model';

            % Create SelectModelDropDown
            app.SelectModelDropDown = uidropdown(app.ModelTab);
            app.SelectModelDropDown.Items = {};
            app.SelectModelDropDown.ValueChangedFcn = createCallbackFcn(app, @SelectModelDropDownValueChanged, true);
            app.SelectModelDropDown.Position = [134 398 100 22];
            app.SelectModelDropDown.Value = {};

            % Create ModelSpecificationTextAreaLabel
            app.ModelSpecificationTextAreaLabel = uilabel(app.ModelTab);
            app.ModelSpecificationTextAreaLabel.HorizontalAlignment = 'right';
            app.ModelSpecificationTextAreaLabel.Position = [27 367 110 22];
            app.ModelSpecificationTextAreaLabel.Text = 'Model Specification';

            % Create ModelSpecificationTextArea
            app.ModelSpecificationTextArea = uitextarea(app.ModelTab);
            app.ModelSpecificationTextArea.ValueChangedFcn = createCallbackFcn(app, @ModelSpecificationTextAreaValueChanged, true);
            app.ModelSpecificationTextArea.Position = [27 15 703 343];

            % Create SaveChangesButton
            app.SaveChangesButton = uibutton(app.ModelTab, 'push');
            app.SaveChangesButton.ButtonPushedFcn = createCallbackFcn(app, @SaveChangesButtonPushed, true);
            app.SaveChangesButton.Position = [303 398 100 22];
            app.SaveChangesButton.Text = 'Save Changes';

            % Create OpenDirectoryButton
            app.OpenDirectoryButton = uibutton(app.ModelTab, 'push');
            app.OpenDirectoryButton.ButtonPushedFcn = createCallbackFcn(app, @OpenDirectoryButtonPushed, true);
            app.OpenDirectoryButton.Enable = 'off';
            app.OpenDirectoryButton.Position = [616 398 100 22];
            app.OpenDirectoryButton.Text = 'Open Directory';

            % Create SaveonDeployCheckBox
            app.SaveonDeployCheckBox = uicheckbox(app.ModelTab);
            app.SaveonDeployCheckBox.Text = 'Save on Deploy';
            app.SaveonDeployCheckBox.Position = [465 367 107 22];

            % Create ProtocolTab
            app.ProtocolTab = uitab(app.TabGroup);
            app.ProtocolTab.Title = 'Protocol';

            % Create SelectProtocolDropDownLabel
            app.SelectProtocolDropDownLabel = uilabel(app.ProtocolTab);
            app.SelectProtocolDropDownLabel.HorizontalAlignment = 'right';
            app.SelectProtocolDropDownLabel.Position = [33 398 86 22];
            app.SelectProtocolDropDownLabel.Text = 'Select Protocol';

            % Create SelectProtocolDropDown
            app.SelectProtocolDropDown = uidropdown(app.ProtocolTab);
            app.SelectProtocolDropDown.Items = {};
            app.SelectProtocolDropDown.ValueChangedFcn = createCallbackFcn(app, @SelectProtocolDropDownValueChanged, true);
            app.SelectProtocolDropDown.Position = [134 398 100 22];
            app.SelectProtocolDropDown.Value = {};

            % Create ScriptTree
            app.ScriptTree = uitree(app.ProtocolTab);
            app.ScriptTree.SelectionChangedFcn = createCallbackFcn(app, @ScriptTreeSelectionChanged, true);
            app.ScriptTree.Position = [17 15 194 326];

            % Create ProtocolVariableTable
            app.ProtocolVariableTable = uitable(app.ProtocolTab);
            app.ProtocolVariableTable.ColumnName = {'Name'; 'Value'};
            app.ProtocolVariableTable.RowName = {};
            app.ProtocolVariableTable.Position = [231 15 480 326];

            % Create RunProtocolButton
            app.RunProtocolButton = uibutton(app.ProtocolTab, 'push');
            app.RunProtocolButton.ButtonPushedFcn = createCallbackFcn(app, @RunProtocolButtonPushed, true);
            app.RunProtocolButton.Position = [301 398 100 22];
            app.RunProtocolButton.Text = 'Run Protocol';

            % Create SaveResultsCheckBox
            app.SaveResultsCheckBox = uicheckbox(app.ProtocolTab);
            app.SaveResultsCheckBox.ValueChangedFcn = createCallbackFcn(app, @SaveResultsCheckBoxValueChanged, true);
            app.SaveResultsCheckBox.Text = 'Save Results';
            app.SaveResultsCheckBox.Position = [425 398 105 22];

            % Create FilenameEditFieldLabel
            app.FilenameEditFieldLabel = uilabel(app.ProtocolTab);
            app.FilenameEditFieldLabel.HorizontalAlignment = 'right';
            app.FilenameEditFieldLabel.Position = [231 363 55 22];
            app.FilenameEditFieldLabel.Text = 'Filename';

            % Create FilenameEditField
            app.FilenameEditField = uieditfield(app.ProtocolTab, 'text');
            app.FilenameEditField.Position = [301 363 191 22];

            % Create ExperimentTab
            app.ExperimentTab = uitab(app.TabGroup);
            app.ExperimentTab.Title = 'Experiment';

            % Create NameEditFieldLabel
            app.NameEditFieldLabel = uilabel(app.ExperimentTab);
            app.NameEditFieldLabel.HorizontalAlignment = 'right';
            app.NameEditFieldLabel.Position = [44 377 38 22];
            app.NameEditFieldLabel.Text = 'Name';

            % Create NameEditField
            app.NameEditField = uieditfield(app.ExperimentTab, 'text');
            app.NameEditField.Position = [97 377 100 22];

            % Create ResultsExplorerTab
            app.ResultsExplorerTab = uitab(app.TabGroup);
            app.ResultsExplorerTab.Title = 'Results Explorer';

            % Create TabGroup2
            app.TabGroup2 = uitabgroup(app.ResultsExplorerTab);
            app.TabGroup2.SelectionChangedFcn = createCallbackFcn(app, @TabGroup2SelectionChanged, true);
            app.TabGroup2.Position = [351 6 401 419];

            % Create RawVariablesTab
            app.RawVariablesTab = uitab(app.TabGroup2);
            app.RawVariablesTab.Title = 'Raw Variables';

            % Create ResultsVariableTable
            app.ResultsVariableTable = uitable(app.RawVariablesTab);
            app.ResultsVariableTable.ColumnName = {'Name'; 'Size(s)'; 'Plot?'};
            app.ResultsVariableTable.ColumnWidth = {'auto', 'auto', 45};
            app.ResultsVariableTable.RowName = {};
            app.ResultsVariableTable.ColumnEditable = [false false true];
            app.ResultsVariableTable.Position = [19 50 370 323];

            % Create LaunchVisualizerButton
            app.LaunchVisualizerButton = uibutton(app.RawVariablesTab, 'push');
            app.LaunchVisualizerButton.Position = [255 19 134 22];
            app.LaunchVisualizerButton.Text = 'Launch Visualizer';

            % Create SharedVariablesOnlyCheckBox
            app.SharedVariablesOnlyCheckBox = uicheckbox(app.RawVariablesTab);
            app.SharedVariablesOnlyCheckBox.Text = 'Shared Variables Only';
            app.SharedVariablesOnlyCheckBox.Position = [19 19 141 22];

            % Create PostProcessingTab
            app.PostProcessingTab = uitab(app.TabGroup2);
            app.PostProcessingTab.Title = 'Post-Processing';

            % Create Yaxis2DDropDownLabel
            app.Yaxis2DDropDownLabel = uilabel(app.PostProcessingTab);
            app.Yaxis2DDropDownLabel.HorizontalAlignment = 'right';
            app.Yaxis2DDropDownLabel.Position = [74 283 60 22];
            app.Yaxis2DDropDownLabel.Text = 'Y-axis (2D)';

            % Create Yaxis2DDropDown
            app.Yaxis2DDropDown = uidropdown(app.PostProcessingTab);
            app.Yaxis2DDropDown.Position = [214 283 175 22];

            % Create Yaxis3DDropDownLabel
            app.Yaxis3DDropDownLabel = uilabel(app.PostProcessingTab);
            app.Yaxis3DDropDownLabel.HorizontalAlignment = 'right';
            app.Yaxis3DDropDownLabel.Position = [71 251 64 22];
            app.Yaxis3DDropDownLabel.Text = 'Y-axis (3D)';

            % Create Yaxis3DDropDown
            app.Yaxis3DDropDown = uidropdown(app.PostProcessingTab);
            app.Yaxis3DDropDown.Position = [215 251 175 22];

            % Create XaxisDropDownLabel
            app.XaxisDropDownLabel = uilabel(app.PostProcessingTab);
            app.XaxisDropDownLabel.HorizontalAlignment = 'right';
            app.XaxisDropDownLabel.Position = [73 313 60 22];
            app.XaxisDropDownLabel.Text = 'X-axis';

            % Create XaxisDropDown
            app.XaxisDropDown = uidropdown(app.PostProcessingTab);
            app.XaxisDropDown.Position = [213 313 175 22];

            % Create SelectResultsCtrlorShiftClicktoSelectMultiplePanel
            app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel = uipanel(app.ResultsExplorerTab);
            app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel.Title = 'Select Results  - Ctrl or Shift Click to Select Multiple';
            app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel.Position = [9 6 332 419];

            % Create ModelsLabel
            app.ModelsLabel = uilabel(app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel);
            app.ModelsLabel.HorizontalAlignment = 'right';
            app.ModelsLabel.Position = [103 373 52 22];
            app.ModelsLabel.Text = 'Model(s)';

            % Create ExperimentsLabel
            app.ExperimentsLabel = uilabel(app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel);
            app.ExperimentsLabel.HorizontalAlignment = 'right';
            app.ExperimentsLabel.Position = [74 174 80 22];
            app.ExperimentsLabel.Text = 'Experiment(s)';

            % Create ExperimentsTree
            app.ExperimentsTree = uitree(app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel);
            app.ExperimentsTree.Multiselect = 'on';
            app.ExperimentsTree.SelectionChangedFcn = createCallbackFcn(app, @ExperimentsTreeSelectionChanged, true);
            app.ExperimentsTree.Position = [6 5 149 166];

            % Create NoneNode_2
            app.NoneNode_2 = uitreenode(app.ExperimentsTree);
            app.NoneNode_2.Text = '<None>';

            % Create ModelsTree
            app.ModelsTree = uitree(app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel);
            app.ModelsTree.Multiselect = 'on';
            app.ModelsTree.SelectionChangedFcn = createCallbackFcn(app, @ModelsTreeSelectionChanged, true);
            app.ModelsTree.Position = [6 213 149 161];

            % Create NoneNode
            app.NoneNode = uitreenode(app.ModelsTree);
            app.NoneNode.Text = '<None>';

            % Create AvailableFilesLabel
            app.AvailableFilesLabel = uilabel(app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel);
            app.AvailableFilesLabel.HorizontalAlignment = 'right';
            app.AvailableFilesLabel.Position = [233 373 91 22];
            app.AvailableFilesLabel.Text = 'Available File(s)';

            % Create FilesTree
            app.FilesTree = uitree(app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel);
            app.FilesTree.Multiselect = 'on';
            app.FilesTree.SelectionChangedFcn = createCallbackFcn(app, @FilesTreeSelectionChanged, true);
            app.FilesTree.Position = [164 4 160 369];

            % Create NoneNode_3
            app.NoneNode_3 = uitreenode(app.FilesTree);
            app.NoneNode_3.Text = '<None>';

            % Create ResultsExplorerTab_2
            app.ResultsExplorerTab_2 = uitab(app.TabGroup);
            app.ResultsExplorerTab_2.Title = 'Results Explorer';

            % Create TabGroup2_2
            app.TabGroup2_2 = uitabgroup(app.ResultsExplorerTab_2);
            app.TabGroup2_2.Position = [351 6 401 419];

            % Create IllustrativeTab_2
            app.IllustrativeTab_2 = uitab(app.TabGroup2_2);
            app.IllustrativeTab_2.Title = 'Illustrative';

            % Create ResultsVariableTable_2
            app.ResultsVariableTable_2 = uitable(app.IllustrativeTab_2);
            app.ResultsVariableTable_2.ColumnName = {'Name'; 'Size(s)'; 'Plot?'};
            app.ResultsVariableTable_2.ColumnWidth = {'auto', 'auto', 45};
            app.ResultsVariableTable_2.RowName = {};
            app.ResultsVariableTable_2.ColumnEditable = [false false true];
            app.ResultsVariableTable_2.Position = [19 125 370 248];

            % Create DCheckBox_5
            app.DCheckBox_5 = uicheckbox(app.IllustrativeTab_2);
            app.DCheckBox_5.Text = '2D';
            app.DCheckBox_5.Position = [131 87 37 22];

            % Create DCheckBox_6
            app.DCheckBox_6 = uicheckbox(app.IllustrativeTab_2);
            app.DCheckBox_6.Text = '3D';
            app.DCheckBox_6.Position = [131 50 37 22];

            % Create PseudocolorCheckBox_3
            app.PseudocolorCheckBox_3 = uicheckbox(app.IllustrativeTab_2);
            app.PseudocolorCheckBox_3.Text = 'Pseudocolor';
            app.PseudocolorCheckBox_3.Position = [164 29 89 22];

            % Create SurfaceCheckBox_3
            app.SurfaceCheckBox_3 = uicheckbox(app.IllustrativeTab_2);
            app.SurfaceCheckBox_3.Text = 'Surface';
            app.SurfaceCheckBox_3.Position = [164 8 63 22];

            % Create QuantitativeTab_2
            app.QuantitativeTab_2 = uitab(app.TabGroup2_2);
            app.QuantitativeTab_2.Title = 'Quantitative';

            % Create Yaxis2DDropDown_2Label
            app.Yaxis2DDropDown_2Label = uilabel(app.QuantitativeTab_2);
            app.Yaxis2DDropDown_2Label.HorizontalAlignment = 'right';
            app.Yaxis2DDropDown_2Label.Position = [74 283 60 22];
            app.Yaxis2DDropDown_2Label.Text = 'Y-axis (2D)';

            % Create Yaxis2DDropDown_2
            app.Yaxis2DDropDown_2 = uidropdown(app.QuantitativeTab_2);
            app.Yaxis2DDropDown_2.Position = [214 283 175 22];

            % Create Yaxis3DDropDown_2Label
            app.Yaxis3DDropDown_2Label = uilabel(app.QuantitativeTab_2);
            app.Yaxis3DDropDown_2Label.HorizontalAlignment = 'right';
            app.Yaxis3DDropDown_2Label.Position = [71 251 64 22];
            app.Yaxis3DDropDown_2Label.Text = 'Y-axis (3D)';

            % Create Yaxis3DDropDown_2
            app.Yaxis3DDropDown_2 = uidropdown(app.QuantitativeTab_2);
            app.Yaxis3DDropDown_2.Position = [215 251 175 22];

            % Create XaxisDropDown_2Label
            app.XaxisDropDown_2Label = uilabel(app.QuantitativeTab_2);
            app.XaxisDropDown_2Label.HorizontalAlignment = 'right';
            app.XaxisDropDown_2Label.Position = [73 313 60 22];
            app.XaxisDropDown_2Label.Text = 'X-axis';

            % Create XaxisDropDown_2
            app.XaxisDropDown_2 = uidropdown(app.QuantitativeTab_2);
            app.XaxisDropDown_2.Position = [213 313 175 22];

            % Create VisualizeButton_3
            app.VisualizeButton_3 = uibutton(app.ResultsExplorerTab_2, 'push');
            app.VisualizeButton_3.Position = [241 10 100 22];
            app.VisualizeButton_3.Text = 'Visualize';

            % Create SelectResultsCtrlorShiftClicktoSelectMultiplePanel_2
            app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel_2 = uipanel(app.ResultsExplorerTab_2);
            app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel_2.Title = 'Select Results  - Ctrl or Shift Click to Select Multiple';
            app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel_2.Position = [9 41 332 384];

            % Create ModelsLabel_2
            app.ModelsLabel_2 = uilabel(app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel_2);
            app.ModelsLabel_2.HorizontalAlignment = 'right';
            app.ModelsLabel_2.Position = [103 338 52 22];
            app.ModelsLabel_2.Text = 'Model(s)';

            % Create ExperimentsLabel_2
            app.ExperimentsLabel_2 = uilabel(app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel_2);
            app.ExperimentsLabel_2.HorizontalAlignment = 'right';
            app.ExperimentsLabel_2.Position = [74 157 80 22];
            app.ExperimentsLabel_2.Text = 'Experiment(s)';

            % Create ExperimentsTree_2
            app.ExperimentsTree_2 = uitree(app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel_2);
            app.ExperimentsTree_2.Multiselect = 'on';
            app.ExperimentsTree_2.Position = [6 4 149 152];

            % Create NoneNode_4
            app.NoneNode_4 = uitreenode(app.ExperimentsTree_2);
            app.NoneNode_4.Text = '<None>';

            % Create ModelsTree_2
            app.ModelsTree_2 = uitree(app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel_2);
            app.ModelsTree_2.Multiselect = 'on';
            app.ModelsTree_2.Position = [6 187 149 152];

            % Create NoneNode_5
            app.NoneNode_5 = uitreenode(app.ModelsTree_2);
            app.NoneNode_5.Text = '<None>';

            % Create AvailableFilesLabel_2
            app.AvailableFilesLabel_2 = uilabel(app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel_2);
            app.AvailableFilesLabel_2.HorizontalAlignment = 'right';
            app.AvailableFilesLabel_2.Position = [233 338 91 22];
            app.AvailableFilesLabel_2.Text = 'Available File(s)';

            % Create FilesTree_2
            app.FilesTree_2 = uitree(app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel_2);
            app.FilesTree_2.Multiselect = 'on';
            app.FilesTree_2.Position = [164 4 160 334];

            % Create NoneNode_6
            app.NoneNode_6 = uitreenode(app.FilesTree_2);
            app.NoneNode_6.Text = '<None>';

            % Create SharedVariablesOnlyCheckBox_2
            app.SharedVariablesOnlyCheckBox_2 = uicheckbox(app.ResultsExplorerTab_2);
            app.SharedVariablesOnlyCheckBox_2.Text = 'Shared Variables Only';
            app.SharedVariablesOnlyCheckBox_2.Position = [39 11 141 22];

            % Create ActiveModelLabel
            app.ActiveModelLabel = uilabel(app.RD_labUIFigure);
            app.ActiveModelLabel.Position = [22 58 73 22];
            app.ActiveModelLabel.Text = 'Active Model:';

            % Create ActiveProtocolLabel
            app.ActiveProtocolLabel = uilabel(app.RD_labUIFigure);
            app.ActiveProtocolLabel.Position = [22 33 89 22];
            app.ActiveProtocolLabel.Text = 'Active Protocol:';

            % Create ActiveExperimentLabel
            app.ActiveExperimentLabel = uilabel(app.RD_labUIFigure);
            app.ActiveExperimentLabel.Position = [22 8 105 22];
            app.ActiveExperimentLabel.Text = 'Active Experiment: ';

            % Create ModelLabel
            app.ModelLabel = uilabel(app.RD_labUIFigure);
            app.ModelLabel.Position = [98 58 520 22];
            app.ModelLabel.Text = 'None';

            % Create ProtocolLabel
            app.ProtocolLabel = uilabel(app.RD_labUIFigure);
            app.ProtocolLabel.Position = [111 33 507 22];
            app.ProtocolLabel.Text = 'None';

            % Create ExperimentLabel
            app.ExperimentLabel = uilabel(app.RD_labUIFigure);
            app.ExperimentLabel.Position = [127 8 491 22];
            app.ExperimentLabel.Text = 'None';

            % Show the figure after all components are created
            app.RD_labUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = RD_lab

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.RD_labUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.RD_labUIFigure)
        end
    end
end