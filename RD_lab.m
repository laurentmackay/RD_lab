classdef RD_lab < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        RD_labUIFigure               matlab.ui.Figure
        TabGroup                     matlab.ui.container.TabGroup
        ModelTab                     matlab.ui.container.Tab
        DeployModelButton            matlab.ui.control.Button
        SelectModelDropDownLabel     matlab.ui.control.Label
        SelectModelDropDown          matlab.ui.control.DropDown
        ModelSpecificationTextAreaLabel  matlab.ui.control.Label
        ModelSpecificationTextArea   matlab.ui.control.TextArea
        SaveChangesButton            matlab.ui.control.Button
        OpenDirectoryButton          matlab.ui.control.Button
        ProtocolTab                  matlab.ui.container.Tab
        SelectProtocolDropDownLabel  matlab.ui.control.Label
        SelectProtocolDropDown       matlab.ui.control.DropDown
        ScriptTree                   matlab.ui.container.Tree
        ProtocolVariableTable        matlab.ui.control.Table
        RunProtocolButton            matlab.ui.control.Button
        SetProtocolButton            matlab.ui.control.Button
        SaveResultsCheckBox          matlab.ui.control.CheckBox
        FilenameEditFieldLabel       matlab.ui.control.Label
        FilenameEditField            matlab.ui.control.EditField
        ExperimentTab                matlab.ui.container.Tab
        NameEditFieldLabel           matlab.ui.control.Label
        NameEditField                matlab.ui.control.EditField
        ResultsExplorerTab           matlab.ui.container.Tab
        TabGroup2                    matlab.ui.container.TabGroup
        IllustrativeTab              matlab.ui.container.Tab
        ResultsVariableTable         matlab.ui.control.Table
        DCheckBox_3                  matlab.ui.control.CheckBox
        DCheckBox_4                  matlab.ui.control.CheckBox
        PseudocolorCheckBox_2        matlab.ui.control.CheckBox
        SurfaceCheckBox_2            matlab.ui.control.CheckBox
        QuantitativeTab              matlab.ui.container.Tab
        Yaxis2DDropDownLabel         matlab.ui.control.Label
        Yaxis2DDropDown              matlab.ui.control.DropDown
        Yaxis3DDropDownLabel         matlab.ui.control.Label
        Yaxis3DDropDown              matlab.ui.control.DropDown
        XaxisDropDownLabel           matlab.ui.control.Label
        XaxisDropDown                matlab.ui.control.DropDown
        VisualizeButton_2            matlab.ui.control.Button
        SelectResultsCtrlorShiftClicktoSelectMultiplePanel  matlab.ui.container.Panel
        ModelsLabel                  matlab.ui.control.Label
        ExperimentsLabel             matlab.ui.control.Label
        ExperimentsTree              matlab.ui.container.Tree
        NoneNode_2                   matlab.ui.container.TreeNode
        ModelsTree                   matlab.ui.container.Tree
        NoneNode                     matlab.ui.container.TreeNode
        AvailableFilesLabel          matlab.ui.control.Label
        FilesTree                    matlab.ui.container.Tree
        NoneNode_3                   matlab.ui.container.TreeNode
        SharedVariablesOnlyCheckBox  matlab.ui.control.CheckBox
        ActiveModelLabel             matlab.ui.control.Label
        ActiveProtocolLabel          matlab.ui.control.Label
        ActiveExperimentLabel        matlab.ui.control.Label
        ModelLabel                   matlab.ui.control.Label
        ProtocolLabel                matlab.ui.control.Label
        ExperimentLabel              matlab.ui.control.Label
    end

    
    properties (Access = private)
        model = 'None' % Description
        active_model = []
        protocol = 'None'
        active_protocol = []
        
    end
    
    methods (Access = private)
        
        function models = getModels(app)
            models = dir("models/*");
            models = {models(arrayfun(@(x) x.name(1)~='.',models)).name};
        end
        
        function prots = getProtocols(app)
            prots = dir("protocols/");
            prots ={prots(arrayfun(@(x) x.name(1)~='.',prots)).name};
        end
        
        function setModel(app, model)
            app.model=model;
            app.ModelSpecificationTextArea.Value = fileread(strcat("models/",model));
            app.checkModelDirectory()
        end
        
        function checkModelDirectory(app)
            if ~isempty(ls(strcat('_',app.model)))
                app.OpenDirectoryButton.Enable=true;
            else
                app.OpenDirectoryButton.Enable=false;
            end
        end
        
        
        function setProtocol(app,prot)
            global protocol
            set_protocol(prot)
            
            main_path = strcat("protocols/",prot,'/main.m');
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
    end
    

    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            addpath('lib/')
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
            if isempty(app.active_model) || strcmp(app.model,'None')
                msgbox('Invalid Command: Please deploy a model first.')
            else
                if app.SaveResultsCheckBox.Value
                    if isempty(app.FilenameEditField.Value)
                        fn=uiputfile('*.mat','Save Filename','result.mat')
                    else
                        fn=strcat(results_dir(),app.FilenameEditField.Value);
                    end
                    mk_fun('main',{},{},strcat("save('", fn, "')"));
                else
                    mk_fun('main');
                end
                main_func()
            end
            
        end

        % Button pushed function: DeployModelButton
        function DeployModelButtonPushed(app, event)
            global active_model
            if ~isempty(app.model) && ~strcmp(app.model,'None')
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
            if strcmp(selectedTab.Title,'Results Explorer')
                models=cellstr(ls('_*'));
                model_results = cellfun(@(x) cellstr(ls(strcat(x,filesep,'results'))),models,'UniformOutput',0);
                has_results = cellfun(@(x) ~isempty(x{1}), model_results);
                
                models = cellfun(@(x) x(2:end),models(has_results),'UniformOutput',0);
                model_results=model_results(has_results);

                is_file = cellfun(@(x) cellfun(@(y) ~all(y=='.'),x),model_results,'UniformOutput',0);
                model_results = cellfun(@(x,i) x(i), model_results,is_file,'UniformOutput',0);
            
                app.ModelsTree.Children.delete();
                cellfun(@(x,y) uitreenode(app.ModelsTree,'Text',x, 'NodeData', y),['<None>'; models],[{''}; model_results]);

                
                experiments = cellstr(ls('experiments/*'));
                is_dir  = cellfun(@(x) ~all(x=='.'),experiments);
                experiments = experiments(is_dir);
                
                experiment_results = cellfun(@(x) cellstr(ls(strcat('experiments',filesep,x))),experiments,'UniformOutput',0);
                
                is_file = cellfun(@(x) cellfun(@(y) ~all(y=='.'),x),experiment_results,'UniformOutput',0);
                experiment_results = cellfun(@(x,i) x(i), experiment_results,is_file,'UniformOutput',0);
                
                
                
                app.ExperimentsTree.Children.delete();
                cellfun(@(x, y) uitreenode(app.ExperimentsTree,'Text',x,'NodeData',y),['<None>'; experiments],[{''}; experiment_results]);
%                 app.ExperimentsListBox.Items=['<None>' experiments];
                
                
                
                
            end
        end

        % Selection changed function: ModelsTree
        function ModelsTreeSelectionChanged(app, event)
            selectedNodes = app.ModelsTree.SelectedNodes';
            app.handleNewFileNodes(selectedNodes ,@(x) strcat('_',x,'/results'))
        end

        % Selection changed function: ExperimentsTree
        function ExperimentsTreeSelectionChanged(app, event)
            selectedNodes = app.ExperimentsTree.SelectedNodes';
            app.handleNewFileNodes(selectedNodes, @(x) strcat('experiments/',x))
        end

        % Selection changed function: FilesTree
        function FilesTreeSelectionChanged(app, event)
            selectedNodes = app.FilesTree.SelectedNodes;

            for node = selectedNodes'
                if isempty(node.NodeData) && ischar(node.Parent.NodeData)
                    node.NodeData=whos('-file',strcat(node.Parent.NodeData,'/',node.Text));
                end
            end
            
            data={selectedNodes.NodeData};
            names=cellfun(@(x) {x.name},data,'UniformOutput',false);
            names_tot = unique([names{:}],'stable');
            if app.SharedVariablesOnlyCheckBox.Value
                disp('this is going to be implemented later bro')
            end
            app.ResultsVariableTable.Data=[names_tot',names_tot'];
        end

        % Button pushed function: OpenDirectoryButton
        function OpenDirectoryButtonPushed(app, event)
            winopen(strcat('_',app.model))
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
            app.ModelSpecificationTextArea.Position = [27 15 703 343];

            % Create SaveChangesButton
            app.SaveChangesButton = uibutton(app.ModelTab, 'push');
            app.SaveChangesButton.Position = [303 398 100 22];
            app.SaveChangesButton.Text = 'Save Changes';

            % Create OpenDirectoryButton
            app.OpenDirectoryButton = uibutton(app.ModelTab, 'push');
            app.OpenDirectoryButton.ButtonPushedFcn = createCallbackFcn(app, @OpenDirectoryButtonPushed, true);
            app.OpenDirectoryButton.Enable = 'off';
            app.OpenDirectoryButton.Position = [616 398 100 22];
            app.OpenDirectoryButton.Text = 'Open Directory';

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

            % Create SetProtocolButton
            app.SetProtocolButton = uibutton(app.ProtocolTab, 'push');
            app.SetProtocolButton.Position = [42 357 100 22];
            app.SetProtocolButton.Text = 'Set Protocol';

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

            % Create IllustrativeTab
            app.IllustrativeTab = uitab(app.TabGroup2);
            app.IllustrativeTab.Title = 'Illustrative';

            % Create ResultsVariableTable
            app.ResultsVariableTable = uitable(app.IllustrativeTab);
            app.ResultsVariableTable.ColumnName = {'Name'; 'Size'};
            app.ResultsVariableTable.RowName = {};
            app.ResultsVariableTable.Position = [19 192 370 170];

            % Create DCheckBox_3
            app.DCheckBox_3 = uicheckbox(app.IllustrativeTab);
            app.DCheckBox_3.Text = '2D';
            app.DCheckBox_3.Position = [131 123 37 22];

            % Create DCheckBox_4
            app.DCheckBox_4 = uicheckbox(app.IllustrativeTab);
            app.DCheckBox_4.Text = '3D';
            app.DCheckBox_4.Position = [131 86 37 22];

            % Create PseudocolorCheckBox_2
            app.PseudocolorCheckBox_2 = uicheckbox(app.IllustrativeTab);
            app.PseudocolorCheckBox_2.Text = 'Pseudocolor';
            app.PseudocolorCheckBox_2.Position = [164 65 89 22];

            % Create SurfaceCheckBox_2
            app.SurfaceCheckBox_2 = uicheckbox(app.IllustrativeTab);
            app.SurfaceCheckBox_2.Text = 'Surface';
            app.SurfaceCheckBox_2.Position = [164 44 63 22];

            % Create QuantitativeTab
            app.QuantitativeTab = uitab(app.TabGroup2);
            app.QuantitativeTab.Title = 'Quantitative';

            % Create Yaxis2DDropDownLabel
            app.Yaxis2DDropDownLabel = uilabel(app.QuantitativeTab);
            app.Yaxis2DDropDownLabel.HorizontalAlignment = 'right';
            app.Yaxis2DDropDownLabel.Position = [74 283 60 22];
            app.Yaxis2DDropDownLabel.Text = 'Y-axis (2D)';

            % Create Yaxis2DDropDown
            app.Yaxis2DDropDown = uidropdown(app.QuantitativeTab);
            app.Yaxis2DDropDown.Position = [214 283 175 22];

            % Create Yaxis3DDropDownLabel
            app.Yaxis3DDropDownLabel = uilabel(app.QuantitativeTab);
            app.Yaxis3DDropDownLabel.HorizontalAlignment = 'right';
            app.Yaxis3DDropDownLabel.Position = [71 251 64 22];
            app.Yaxis3DDropDownLabel.Text = 'Y-axis (3D)';

            % Create Yaxis3DDropDown
            app.Yaxis3DDropDown = uidropdown(app.QuantitativeTab);
            app.Yaxis3DDropDown.Position = [215 251 175 22];

            % Create XaxisDropDownLabel
            app.XaxisDropDownLabel = uilabel(app.QuantitativeTab);
            app.XaxisDropDownLabel.HorizontalAlignment = 'right';
            app.XaxisDropDownLabel.Position = [73 313 60 22];
            app.XaxisDropDownLabel.Text = 'X-axis';

            % Create XaxisDropDown
            app.XaxisDropDown = uidropdown(app.QuantitativeTab);
            app.XaxisDropDown.Position = [213 313 175 22];

            % Create VisualizeButton_2
            app.VisualizeButton_2 = uibutton(app.ResultsExplorerTab, 'push');
            app.VisualizeButton_2.Position = [241 10 100 22];
            app.VisualizeButton_2.Text = 'Visualize';

            % Create SelectResultsCtrlorShiftClicktoSelectMultiplePanel
            app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel = uipanel(app.ResultsExplorerTab);
            app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel.Title = 'Select Results  - Ctrl or Shift Click to Select Multiple';
            app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel.Position = [9 41 332 384];

            % Create ModelsLabel
            app.ModelsLabel = uilabel(app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel);
            app.ModelsLabel.HorizontalAlignment = 'right';
            app.ModelsLabel.Position = [103 338 52 22];
            app.ModelsLabel.Text = 'Model(s)';

            % Create ExperimentsLabel
            app.ExperimentsLabel = uilabel(app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel);
            app.ExperimentsLabel.HorizontalAlignment = 'right';
            app.ExperimentsLabel.Position = [74 157 80 22];
            app.ExperimentsLabel.Text = 'Experiment(s)';

            % Create ExperimentsTree
            app.ExperimentsTree = uitree(app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel);
            app.ExperimentsTree.Multiselect = 'on';
            app.ExperimentsTree.SelectionChangedFcn = createCallbackFcn(app, @ExperimentsTreeSelectionChanged, true);
            app.ExperimentsTree.Position = [6 4 149 152];

            % Create NoneNode_2
            app.NoneNode_2 = uitreenode(app.ExperimentsTree);
            app.NoneNode_2.Text = '<None>';

            % Create ModelsTree
            app.ModelsTree = uitree(app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel);
            app.ModelsTree.Multiselect = 'on';
            app.ModelsTree.SelectionChangedFcn = createCallbackFcn(app, @ModelsTreeSelectionChanged, true);
            app.ModelsTree.Position = [6 187 149 152];

            % Create NoneNode
            app.NoneNode = uitreenode(app.ModelsTree);
            app.NoneNode.Text = '<None>';

            % Create AvailableFilesLabel
            app.AvailableFilesLabel = uilabel(app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel);
            app.AvailableFilesLabel.HorizontalAlignment = 'right';
            app.AvailableFilesLabel.Position = [233 338 91 22];
            app.AvailableFilesLabel.Text = 'Available File(s)';

            % Create FilesTree
            app.FilesTree = uitree(app.SelectResultsCtrlorShiftClicktoSelectMultiplePanel);
            app.FilesTree.Multiselect = 'on';
            app.FilesTree.SelectionChangedFcn = createCallbackFcn(app, @FilesTreeSelectionChanged, true);
            app.FilesTree.Position = [164 4 160 334];

            % Create NoneNode_3
            app.NoneNode_3 = uitreenode(app.FilesTree);
            app.NoneNode_3.Text = '<None>';

            % Create SharedVariablesOnlyCheckBox
            app.SharedVariablesOnlyCheckBox = uicheckbox(app.ResultsExplorerTab);
            app.SharedVariablesOnlyCheckBox.Text = 'Shared Variables Only';
            app.SharedVariablesOnlyCheckBox.Position = [39 11 141 22];

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