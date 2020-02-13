classdef GUIOUTPUT < handle
    properties(SetObservable)
        Fig;                             % figure object
        Axs;                             % axes object
        IsHold = false;
        IsActive = false;
        EnableCounter = true;
        CapObj;                         % e'axes' or 'figure'
    end
    properties(SetAccess = private, Hidden)
        MaxNumberOfHeldData = 300;
        HasFigAndAxs = false;            % 
        CurrentHeldDataObject;           % cell array 
        NumberOfHeldData = 0;            % 
        LastObjectBeingCopied = 0;
        InternalCount = 0;
        CounterTextObject;
        CounterListener;
        AssociateCount;
        Associate;                       % associate container
        LastCreatedPlot;                 % last created plot
        
        % internal-frame properties
        MaxFrameToBeStored = 1E+3;
        CurrentNumberOfAxeFrames = 0;
        CurrentNumberOfFigFrames = 0;
        AxeFrameContainer;
        FigFrameContainer;
        MovieObjTypeCheckListener;
        DefaultCapObj;
        DefaultFrameCount = 0;
        LightSource;                      % a light src
        
        xLabelString;
        yLabelString;
        zLabelString;
        
        % a reference to an image object ... 
        imageObj;
        
    end
    methods
        function obj = GUIOUTPUT(ext_fig, ext_axs)
            obj.CurrentHeldDataObject = cell(1,obj.MaxNumberOfHeldData);
            obj.Associate = GUIOUTPUT.empty(1,0);
            obj.AssociateCount = 0; obj.CapObj = 'figure';
            if nargin == 1
                % set Fig to an existing ext_fig
                obj.Fig = ext_fig; obj.IsActive = strcmpi(ext_fig.Visible, 'on');
                obj.Axs = axes('Parent', ext_fig);
                %axis(obj.Axs, 'equal');
            elseif nargin == 2
                % set Fig to the axs's new parent
                obj.Fig = ext_axs.Parent;
                obj.Axs = ext_axs;
                %axis(obj.Axs, 'equal');
            else
                % create an invisibile fig
                obj.Fig = figure('Visible','off','CloseRequestFcn', {@SomeCallBack, obj}, ...
                    'KeyPressFcn', {@AdjustedDeleteFig, obj}, 'Units', 'normalized');
                obj.Axs = axes('Parent', obj.Fig);
                %axis(obj.Axs, 'equal');
            end
            obj.CounterTextObject = title(obj.Axs, ['count: ', num2str(0, '%2d')]);
            if ~obj.EnableCounter, obj.CounterTextObject.Visible = 'off';end
            obj.HasFigAndAxs = true;
            obj.CounterListener = addlistener(obj,'EnableCounter','PostSet', @obj.CounterCallBack);
            obj.MovieObjTypeCheckListener = addlistener(obj, 'CapObj', ...
                'PostSet', @obj.CheckMovieObjInput);
            obj.DefaultCapObj = obj.Fig;
        end
        function varargout = pplot(obj, varargin)
            % simple line plot
            [varargout{1:nargout}] = plot(obj.Axs, varargin{:});
            obj.LastCreatedPlot = obj.Axs.Children(1);
        end
        function varargout = pplot3(obj, varargin)
            % simple 3d line plot
            [varargout{1:nargout}] = plot3(obj.Axs, varargin{:});
            obj.LastCreatedPlot = obj.Axs.Children(1);
        end
        function varargout = splot(obj, varargin)
            % simple scatter plot
            [varargout{1:nargout}] = scatter(obj.Axs, varargin{:});
            obj.LastCreatedPlot = obj.Axs.Children(1);
        end
        function varargout = splot3(obj, varargin)
            % simple scatter3 plot
            [varargout{1:nargout}] = scatter3(obj.Axs, varargin{:});
            obj.LastCreatedPlot = obj.Axs.Children(1);
        end
        function varargout = ppatch(obj, varargin)
            % patch plot
            [varargout{1:nargout}] = patch(obj.Axs, varargin{:});
            obj.LastCreatedPlot = obj.Axs.Children(1);
            
        end
        function cplot(obj, varargin)
            % simple composite plot
            DefaultAxsHold = ishold(obj.Axs);
            if ~ishold(obj.Axs), hold(obj.Axs,'on');end
            obj.pplot(varargin{:});
            obj.splot(varargin{:});
            if ~DefaultAxsHold, set(obj.Axs,'NextPlot','replace');end
            
        end
        function DeleteLastPlotObj(obj)
            if ~isempty(obj.LastCreatedPlot)
                obj.LastCreatedPlot.delete;
                obj.LastCreatedPlot = [];
            end
        end
        function RegenerateGUI(obj)
            % create a new figure
            obj.Fig = figure('Visible', 'off', 'CloseRequestFcn', {@SomeCallBack,obj}, ...
                'KeyPressFcn', {@AdjustedDeleteFig, obj}, 'Units', 'normalized');
            obj.Axs = axes('Parent', obj.Fig);
            obj.CounterTextObject = title(obj.Axs, ['count: ', num2str(0, '%2d')]);
            if ~obj.EnableCounter, obj.CounterTextObject.Visible = 'off';end
            obj.ClearRef;
            obj.HasFigAndAxs = true;
        end
        function Syn(obj, NewAxs)
            % if a new axis is given, synchronise with the NewAxs
            if obj.HasFigAndAxs, obj.Fig.delete();end
            obj.Axs = NewAxs;
            obj.Fig = NewAxs.Parent;
            if ~isempty(obj.CounterTextObject)
                % resets the string field in the text object
                obj.CounterTextObject.String = ['count: ', num2str(0,'%2d')];
            end
        end
        function turn(obj, state)
            DefaultState = 'on';
            if nargin > 1
                DefaultState = state;
            end
            assert(obj.Fig.isvalid, 'reference to deleted figure handle');
            switch DefaultState
                case 'on'
                    obj.IsActive = true;
                    obj.Fig.Visible = 'on';
                    obj.Axs.Visible = 'on';
                case 'off'
                    obj.IsActive = false;
                    obj.Fig.Visible = 'off';
                    obj.Axs.Visible = 'off';
                otherwise
                    error('state no recognised!');
            end
        end
        function turntext( obj, state)
            set( obj.CounterTextObject, 'Visible', state);
        end
        function hold(obj, state)
            DefaultState = 'on';
            if nargin > 1
                DefaultState = GUIOUTPUT.parseHoldState(state);
            end
            switch DefaultState
                case 'on'
                    obj.IsHold = true;
                    hold(obj.Axs, 'on');
                case 'off'
                    obj.IsHold = false;
                    hold(obj.Axs, 'off');
            end
        end
        function add(obj, DataObject)
            % add a DataObject to the current list
            ToAdd = obj.LastObjectBeingCopied ~= DataObject;
            if ToAdd
                obj.NumberOfHeldData = obj.NumberOfHeldData + 1;
                obj.CurrentHeldDataObject{obj.NumberOfHeldData} = DataObject;
                obj.LastObjectBeingCopied = DataObject;
            end
            
        end
        function ClearGraphContent(obj)
            obj.Fig.delete();
            obj.HasFigAndAxs = false;
            obj.IsActive = false;
            obj.ClearRef();
        end
        function ClearRef(obj, DataType)
            % clear handle reference DataType
            if nargin > 1
                if iscell(DataType)
                    % CellArray
                    N = length(DataType);
                    for j = 1:N
                        n = obj.NumberOfHeldData;
                        for k = 1:n
                            valid = obj.CurrentHeldDataObject{k} == DataType{j};
                            if valid
                                obj.CurrentHeldDataObect(k) = [];
                                obj.NumberOfHeldData = obj.NumberOfHeldData - 1;
                            end
                        end
                    end
                else
                    % DataType is a class
                    n = obj.NumberOfHeldData;
                    for k = 1:n
                        valid = obj.CurrentHeldDataObject{k} == DataType;
                        if valid
                            obj.CurrentHeldDataObject(k) = [];
                            obj.NumberOfHeldData = obj.NumberOfHeldData - 1;
                        end
                    end
                end
            else
                % delete all reference 
                obj.CurrentHeldDataObject = cell(1,obj.MaxNumberOfHeldData);
                obj.LastObjectBeingCopied = 0;
                obj.NumberOfHeldData = 0;
                obj.InternalCount = 0;
            end
        end
        function show(obj)
            % update plot based on the specific object being passed to
            % 'GUIOUTPUT', which needs to include the method
            % 'advanceprivategraphobject'
            assert(isvalid(obj.Fig), ...
                'GUIOUTPUT:Fig:DestroyedObject', ...
                'Figure is destroyed');
            if obj.NumberOfHeldData < 1 
%                 warning( ...
%                     'GUIOUTPUT:Data:noDataObject', ...
%                     'No data object held by GUIOUTPUT');
                return;
            end
            obj.InternalCount = obj.InternalCount + 1;
            for j = 1:obj.NumberOfHeldData
                % Let Matlab handle any underlying exception
                obj.CurrentHeldDataObject{j}.advanceprivategraphobject();
            end
            % update the text counter
            if obj.EnableCounter
                obj.CounterTextObject.String = ['count: ', num2str(obj.InternalCount, '%2d')];
            end
            if ~obj.IsActive, obj.turn;end
        end
        function ResetCounter(obj)
            % reset counter
            obj.InternalCount = 0;
            obj.CounterTextObject.String = ['count: ', num2str(0, '%2d')];
        end
        function AddAssociate(obj, associate)
            % add associate to the associate list
            IsListContainedAssociate = any(obj.Associate == associate);
            if ~IsListContainedAssociate
                obj.Associate = [obj.Associate, associate];
                obj.AssociateCount = obj.AssociateCount + 1;
            end
        end
        function HandleArray = ReturnAssociate(obj)
            HandleArray = obj.Associate;
        end
        function FrameContainer = GetFrameContainer(obj)
            if strcmpi(obj.CapObj, 'figure')
                FrameContainer = obj.FigFrameContainer;
            else
                FrameContainer = obj.AxeFrameContainer;
            end
        end
        function CreateLightObject(obj, varargin)
            % create a light obj on the existing axe
            assert(obj.Axs.isvalid, ...
                'GUIOUTPUT:Axs:DestroyedObject', ...
                'cannot create a light object on a deleted axe');
            obj.LightSource = light(obj.Axs, varargin{:});
        end
        function setLightProperties(obj, varargin)
            % set the light Source properties
            assert(isempty(obj.LightSource), ...
                'GUIOUTPUT:LightSource:invalidObject', ...
                'The light source object is not available');
            set(obj.LightSource, varargin{:});
        end
        function xxlabel(obj, varargin), obj.xLabelString = xlabel(obj.Axs, varargin{:}); end
        function yylabel(obj, varargin), obj.yLabelString = ylabel(obj.Axs, varargin{:}); end
        function zzlabel(obj, varargin), obj.zLabelString = zlabel(obj.Axs, varargin{:}); end
        function ggrid(obj, varargin), grid(obj.Axs, varargin{:}); end
        function aaxis(obj, varargin), axis(obj.Axs, varargin{:}); end
        function setTextProperties( obj, varargin ), set( obj.CounterTextObject, varargin{:}); end
        function setXLabel(obj, varargin), set( obj.xLabelString, varargin{:}); end
        function setYLabel(obj, varargin), set( obj.yLabelString, varargin{:}); end
        function setZLabel(obj, varargin), set( obj.zLabelString, varargin{:}); end
        function lcp = getLastCreatedPlot( obj ), lcp = obj.LastCreatedPlot; end
        function setImageProperties( obj, varargin )
            if ~isempty( obj.imageObj )
                set( obj.imageObj, varargin{:} );
            end
        end
        function destroyImageObj( obj ), if ~isempty( obj.imageObj ), obj.imageObj.delete(); obj.imageObj = []; end, end
    end
    methods
        % methods implemented on separate files
        record_frame(obj, target);
        make_animation(obj, filename, varargin);
        ClearFrameContainer(obj, target);
        usePreset(obj);
        setText( obj, CharArray);
        revertToCloseWindowBehaviour( obj );
        readAndScaleImage(obj, filename, varargin);
    end
    methods (Access = private)
        function CounterCallBack(obj, ~, ~)
            if ~obj.EnableCounter
                obj.CounterTextObject.Visible = 'off';
            else
                obj.CounterTextObject.Visible = 'on';
            end
        end
        function CheckMovieObjInput(obj, ~, ~)
            validinput = ischar(obj.CapObj) && ( strcmpi(obj.CapObj, 'axes') || ...
                strcmpi(obj.CapObj, 'figure'));
            if ~validinput
                warningID = 'GUI:Keywords:illegalCharacter';
                warningTx = 'illegal property value, ''figure'' was assumed';
                warning(warningID, warningTx);
                obj.CapObj = 'figure';
                obj.DefaultCapObj = obj.Fig; return;
            end
            if strcmpi(obj.CapObj, 'figure')
                obj.DefaultCapObj = obj.Fig;
            else
                obj.DefaultCapObj = obj.Axs;
            end
        end
    end
    methods(Static, Hidden)
        function state = parseHoldState(STATE)
            errorID = 'static:argument:invalidType';
            if islogical(STATE)
                if STATE, state = 'on'; else, state = 'off'; end
            elseif ischar(STATE)
                if strcmpi(STATE, 'on')
                    state = 'on';
                elseif strcmpi(STATE, 'off')
                    state = 'off';
                else
                    errorID = 'static:argument:illegalKeyword';
                    error(errorID, ...
                        '%s is not a valid input, specify either ''on'' or ''off''', STATE);
                end
            else
                error(errorID, 'illegal input type!');
            end
        end
    end
end