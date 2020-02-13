classdef Schematic2D < handle
    % A canvas class that provides methods to draw schematic diagrams
    % interactively. 
    % 
    % The canvas can be initialized by creating an instance of the
    % 'Schematic2D' object in the command window. i.e.
    %
    %  >> s = Schematic2D(); 
    %     
    %  When no argument is passed to the constructor, the object creates a
    %  figure container and configurates that container to a set of
    %  pre-defined properties.
    % 
    %  If input arguments are passed to the constructor. It must conform to
    %  the 'propname' - propval format. The following properties can be
    %  modified: 
    %    
    %      propertyname           |          description 
    %   ----------------------------------------------------
    %       'parent'                    a valid instance of the 'GUIOUTPUT'
    %                                   class. The canvas selects this
    %                                   object as the figure container
    %
    %       'path'                      either a 3-element cell array or a
    %                                   char-vector. This specifies the
    %                                   output directories. In the former
    %                                   case, Canvas separates the 3 
    %                                   distinct outputs to these folders. 
    %                                   The 3 outputs are as follow:
    %                                   'function file(.m)', 'function file
    %                                   data(.dat)' and image output(.jpg
    %                                   or .pdf). In the latter, all
    %                                   outputs are put under the same
    %                                   folder.
    % 
    %      'inprecision'                non-negative scalar. Controls the
    %                                   precision of the registered clicked
    %                                   coordinate on the canvas. Only
    %                                   active if the 'useInPrecision'
    %                                   property returns true.
    % 
    %     'traversalsteps'              a positive scalar. Affects
    %                                   operations involving translation,
    %                                   rotation and scaling (default is
    %                                   400). 
    %
    %     'zoomstepsize'                a positive scalar less than .5.
    %                                   Affects camera zoom speed. 
    %
    % In addition to the basic figure creation tools, the class also offers
    % an image-digitizing module, which include automatic line tracing(note
    % the algorithm used differs from that of 'Data Thief', we used a
    % combination of Gaussian weighted function and linear regression to
    % update the search direction. The end result is a simple and efficient
    % routine that performs comparably in most situations
    
    properties(SetAccess = private, ~Hidden)
        % current running mode('normal', 'selection', 
        %        'text', 'arrowtext', 'circle', 'atomicselect', 'image')
        currentMode                                 = 'normal'
        
    end
    properties(   Access = private )
        currentModeState                            = 1;
        
        % an uicontrol element that displays the current mode
        ModeIdentifierUi;
        
        % the coordinate diplay, which display current position in
        % real-time
        CoordinateDisplay;
        
        % export mode (associates with printing and saving figures) 
        figExportModeDisp;
        saveasPDFListener;
        
        % import mode (associates with importing background image) or is
        % used in conjunction with the 'image' mode ...
        
        % a static text uicontrol object ... 
        importUIDisp;
        
        % 'lock' displays. 
        xlockUIDisp;
        ylockUIDisp;
        
        % key map 
        keyMap;  % keymap object (used to reassign keys)
        mapui;   % an ui-component (a pushbutton) to facilitate the reassignment
        
    end
    properties( SetObservable, Hidden)
        % Only modify these flags manually if you know what you are doing.
        % By default, they are designed to be modified interactively on the
        % canvas
        
        % toggles whether to save image as a pdf or jpg
        saveasPDF(1,1) logical                      = true;
        
        % locks the x-coordinate of the guidepoint, so that if a preceded
        % guidepoint is registered, the x-coordinate of the next guide
        % point will coincide with that of the preceded point
        xlock(1,1) logical                          = false;
        
        % locks the y-coordinate of the guidepoint , ...
        ylock(1,1) logical                          = false;
        
        % 'image' mode - calibration flag (returns a warning if one tries
        % to add points to the uncalibrated image)
        isInCalibration(1,1) logical                = false;
        
        % 'image' mode - save the autogenerated data (if true and the
        % auto-generated set of data exists, the canvas saves such set to
        % the output folder - specified by the workMDataPath pathname
        saveAutoGeneratedData(1,1) logical          = false;
        
        % 'image' mode - in automatic line tracing. Sets the anchor point
        % on the canvas so if the traced line reaches within certain pixel
        % length of the point, the tracing stops.
        imageSettingTerminationPoint(1,1) logical   = false;
    end
    properties( SetObservable )
        % to be deprecated in future release ... 
        arrowTextModeStyle                          = 'arrow'
        
        
        % if the useInPrecision is true, we make the following
        % transformation:   x <- f * floor( x / f ), where f is the
        % 'inprecision' factor to the position vector x.
        useInPrecision(1,1) logical                 = false;
        
        % inprecision factor ... 
        inprecision(1,1) double                     = .05;
    end
    properties( SetObservable )
        
        % 'selection' mode only. Roughly translates to the minimum
        % presses to reach from one extreme corner to the next.
        MinimumNumberOfTraversals(1,1) double       = 400;
        
        % The 'EnableGuidePoint' property enables the canvas to draw a
        % point whenever an active area of the canvas is being clicked.
        EnableGuidePoint(1,1) logical               = true;
        
        % returns the numeric label next to the guide point if this
        % property is true
        EnableNumericLabelOnGuidePoint(1,1) logical = true;
        
        % prints the coordinates to the command window if the value of this
        % property is true.
        PrintGuidePointToCommand(1,1) logical       = false;
        
        % shape buffer is 'open' if true, else it is 'close'
        AlwaysConstructOpenCurve(1,1) logical       = true;
    end
    properties(Constant, Hidden )
        ModeSelection = { 'normal', 'selection', 'text', ...
            'arrowtext', 'circle', 'atomicselect', 'image' };
        
        % testing purpose only, set to false for release (DO NOT MODIFY
        % THIS PROPERTY!)
        testOverrideAnyInputPaths                   = false;
    end
    properties(SetAccess = private,  Hidden)
        % display resolution in pixels
        HorizontalResolution = 1920; 
        VerticalResolution   = 1080;
    end
    properties(SetAccess = private, Hidden)
        parent;   % GUIOUTPUT object (a figure container object)
    end
    properties(SetAccess = private, Hidden)
        
        % if true, canvas saves the reference of any schematic objects
        % created
        EnableCapture        = true;
        
        % any created schematic objects are saved to the following
        % containers based on their type:
               
        schematicContainer;
        schematicListenerContainer;
       
        % special container for a quick-delete operation ...
        lastAddedSchematic;
        
        % frame is a structure obtained from the 'getframe' command. It
        % contains the color data of a portion of the captured axes. This
        % is useful for fine-tuning the final output dimension.
        frame;
    end
    properties(Access = private)
        
        % Group operations require selecting the schematic objects. Any
        % selected objects are saved to the following containers.
        
        SelectedSchematic;
        
        % atomic-select, we place the atomically selected object to this
        % container.
        
        isRotating        = true;   % else, scaling ... 
        atomicSelectedObj;
        
        % real-time anchor used in the translation of atomic objects
        atomicRealTimeAnchor;
    end
    
    properties(SetAccess = private, Hidden)
        % guide point visualization
        
        % radius of the guide point as a percentage of the xlim or ylim of
        % the supplied parent object
        pointPercentageOfAxes     = 2.5E-3;
        
        % guide point color( set this manually )
        pointColor                = 'r' ;
        
        % internal guide point counter ... 
        ClickCounter              =  0;
        
        % the last created guide is stored in this place-holder
        lastCreatedPoint          = [];
        lastCreatedPointText      = [];
        ClickedPointContainer;
        
        % contains the textbox 
        ClickedPointTextContainer;     
        
        % a listener that changes the behaviour of the button click call
        % back
        EnableGuidePointListener;
        EnableNumericLabelListener;
    end
    properties(SetAccess = private, Hidden)
        % output folder paths
        
        % To be deprecated ... 
        dataFolderPath;
        
        % we require three folders for:
        workMscriptPath;    % storing the m-files ...
        workMdataPath;      % storing the data needed for the m-files ...
        workImagePath;      % outputing image files ....
        
        % applicable in 'normal' mode ...
        savepanel;
        textuiele;
        editableobj;
        panelstringmodlistener;
        
        % temporary guide shape holder
        holderIsActive          = false;
        tmpShapeHolder;
        holderStateListener;
    end
    events
        DeactivateHolder;
        DeactivateSelectionLine;
    end
    events
        deselectedObjects;
    end
    events
        atomicTranslationEnd;
    end
    properties( SetAccess = private, Hidden )
        %% properties associated with the 'selection' mode
        
        % a counter that keeps track of the number of mouse clicks on the
        % canvas 
        selectionClickCount    =     0;
        
        % representation of the selection box in the 'selection' mode
        bline01;
        bline02;
        bline03;
        bline04;
        % Those are given as 2-element-vectors
        FirstAnchorPosition;
        FinalAnchorPosition;
        deactiveSelectionLineListener;
        
        internalCapturedSelection;
        selectionStepListener;
        selectionTranslationStep;
    end
    
    properties( SetAccess = private, Hidden )
        %% text/arrowtext
        
        plainTextSchematicObj;
        
        % reuse 'FirstAnchorPosition' and 'FinalAnchorPosition' as anchor
        % points, as well as selectionclickcount ... 
        arrowTextSchematicObj;
    end
    properties( SetAccess = private, Hidden )
        %% circle guide
        
        guideCircle;
    end
    properties( SetAccess = private, Hidden )
        %% predefined property structs 
        
        % 'normal',    prop struct
        previewShape;
        propertyShapeStruct;
        
        % 'text'       prop struct
        previewText;
        propertyTextStruct;
        
        % 'arrowtext', prop struct
        previewArrowText;
        propertyArrowTextStruct;
        
        % 'circle',    prop struct
        previewCircle;
        propertyCircleStruct;
        
        % list of the uicontrol components
        propertypanelwindow;
        propertypanelstaticcomponents;     % static text
        propertypaneleditablecomponents;   % editable
        propertycomptlisteners;            % listeners for callbacks
        useCustomName               = false;
        
        %% attributes relating to 'preview' and 'export' operation ...
        
        % preview properties (a ui-obj + a listener for any callbacks )
        previewcomponent;
        previewlistener;
        
        % export to concrete container ( a ui-obj + a listener for any
        % callbacks )
        exportcomponent;
        exportlistener;
    end
    properties(SetAccess = private, Hidden)
        %% canvas internal properties associate with 'locking' 
        xlockListener;
        ylockListener;
    end
    properties(SetAccess = private, Hidden)
        %% properties associated with the image processing module
        
        % The imager is an instance of the 'SchematicImagerProcessor' class
        % This class provides the core functionalities of the digitizing
        % tools in the canvas
        imager;
        
        % calibration listener
        calibrationlistener; 
        
        % calibration point counter
        calibrationcount      = 0;
        
        % calibration guide points
        calibrationGuide;
        
        % text uiobject to indicate which saving mode we are on 
        imageSavingModeUI;
        imageSavingModeListener;
        
        % some cosmetic properties
        customPointerMatrix;
        terminationGuide;
        terminationPointPlacementListener;
    end
    properties(SetAccess = private, Hidden)
        %% properties related to custom zoom
        
        % 2-element vector
        currentZoomAnchor;
        archivedXLim;
        archivedYLim;
        % controls the zoom speed, modify this value in the constructor
        zoomStep               = .03;
    end
    methods
        function obj = Schematic2D( varargin )
            % constructor. 
            if nargin
                % parse any inputs
                obj.internalParseInputs( varargin{:} );
            else
                obj.parent = GUIOUTPUT();
                % set default canvas properties: 
                obj.internalConfigurateCanvas();
                % set default path 
                obj.internalCreateDefaultPath();
            end
            % create graph containers
            obj.schematicContainer         = GeneralManager();
            obj.schematicListenerContainer = GeneralManager();
            
            obj.SelectedSchematic = GeneralManager();
            %  
            obj.ClickedPointContainer     = GeneralManager();
            obj.ClickedPointTextContainer = GeneralManager();
                       
            % throw a warning to avoid using commands that would
            % jeopardise the canvas' default properties ...
            % obj.throwResizingWarningMsg();
            
            % initialize button-down call-back ('on' by default)
            obj.guidePointCallback();
            
            % now set listener for the 'EnableGuidePoint' property
            obj.EnableGuidePointListener   = addlistener(obj, 'EnableGuidePoint', 'PostSet', @obj.guidePointCallback );
            obj.EnableNumericLabelListener = addlistener(obj, 'EnableNumericLabelOnGuidePoint', 'PostSet', @obj.guideNumericLabelOnGuide);
            
            % this is required to implement quick-save and various other
            % shortcuts ...
            set( obj.parent.Fig, ...
                'keypressfcn',           @obj.internalKeyIsPressed, ...
                'WindowButtonMotionFcn', @obj.selectionPointerMotionCallback);
            
            % set listener for the shape holder
            obj.holderStateListener = addlistener(obj, 'DeactivateHolder', @obj.deactivateHolder);
            
            % initialize 'selection mode' ... 
            obj.selectionInitialize();
            
            % add ui-elements 
            obj.internalAddModeTextIdentifierPanel();
            
            % initialize 'text' mode 
            obj.internalTextInitialization();
            
            % initialize 'circle' mode
            obj.internalCircleInitialization();
            
            % initialize property-panel
            obj.internalPropertyStructInitialization();
            
            % create a keyMap object
            obj.keyMap = SchematicKeyMap( obj );
            
            % initialize image mode
            obj.internalImageInitialize();
            
        end
        
        % -----------
        %  'finish' to be deprecated ...
        % -----------
        function finish( obj )
            % once we have finished, we disable the axes object. Only
            % elements of the schematic objects remain
            set( obj.parent.Axs, 'visible', 'off' );
        end
        function setDeviceResolution(obj, horizontalPixelCount, verticalPixelCount)
            % Make sure that the device's resolution matches with the
            % default.
            obj.HorizontalResolution = horizontalPixelCount;
            obj.VerticalResolution   = verticalPixelCount  ;
        end
        function captureRect(obj, physicalRect)
            % The input 'physicalRect' is a 4-element vector of the form
            %  physicalRect = [xlower, ylower, xupper, yupper]
            assert( isvector( physicalRect ) && numel( physicalRect ) == 4, ...
                'SchematicTools:Canvas:illegaltype', ...
                ['The supplied input must be a 4-element vector whose elements ', ...
                'are: [xlower, ylower, xupper, yupper]!'] );
            x0 = obj.parent.Axs.XLim(1); y0 = obj.parent.Axs.YLim(1);
            x1 = obj.parent.Axs.XLim(2); y1 = obj.parent.Axs.YLim(2);
            % extract the physical elements: 
            xlower = physicalRect(1); ylower = physicalRect(2);
            xupper = physicalRect(3); yupper = physicalRect(4);
            assert( xlower < xupper && ylower < yupper, ...
                'SchematicTools:Canvas:illegaltype', ...
                'input contains illegal elements!');
            % extract the figure position
            currentFiguPosition = obj.parent.Fig.Position;
            currentAxesPosition = obj.parent.Axs.Position;
            % assume normalized
            WidthInPixel  = floor( (xupper - xlower) * currentAxesPosition(3) * currentFiguPosition(3) * obj.HorizontalResolution / (x1 - x0) );
            HeightInPixel = floor( (yupper - ylower) * currentAxesPosition(4) * currentFiguPosition(4) * obj.VerticalResolution   / (y1 - y0) );
            LowerXCoordNormalized = floor( (xlower - x0) * currentAxesPosition(3) * currentFiguPosition(3) * obj.HorizontalResolution / (x1 - x0) );
            LowerYCoordNormalized = floor( (ylower - y0) * currentAxesPosition(4) * currentFiguPosition(4) * obj.VerticalResolution   / (y1 - y0) );
            % now one simply captures the frame
            obj.frame = getframe( obj.parent.Axs, ...
                [ ...
                LowerXCoordNormalized, ...
                LowerYCoordNormalized, ...
                WidthInPixel, ...
                HeightInPixel] );
        end
        function writeCapturedFrameAsImageFile(obj, filename)
            % write the capured frame to image ... 
            
            if ~isempty(obj.frame )
                X = frame2im( obj.frame );
                [imind, cm] = rgb2ind( X, 256 );
                imwrite(imind, cm, filename);
            end
        end
        function setpath( obj, specifier, pathnames )
            % 'setpath' allows you to customize where you want to
            % output the data ... 
            
            % 'specifier' - 'multiple', 'single'
            %      'multiple' - script, script data and image outputs are
            %      separated ( pathname to be given as a 1-by-3
            %      cellarray whose elements contain the path names as
            %      character-vectors )
            %
            %      'single'   - script, script data and image outputs are
            %      put into the same folder, in which case 'pathnames'
            %      may be specified as a char-vector  
            
            usedefault       = nargin < 3;
            defaultspecifier = specifier;
            if usedefault
                [S, SD, ID] = Schematic2D.testGetWorkPath();
                defaultpath = {S, SD, ID}; 
                defaultspecifier = 'multiple';
                if strcmpi( specifier, 'single' )
                    defaultpath = Schematic2D.testReturnDefaultPath(); 
                    defaultspecifier = 'single';
                end
            else
                defaultpath = pathnames;
                if iscell( defaultpath )
                    defaultspecifier = 'multiple';
                end
            end
            switch defaultspecifier
                case 'multiple'
                    obj.workMscriptPath = defaultpath{ 1 };
                    obj.workMdataPath   = defaultpath{ 2 };
                    obj.workImagePath   = defaultpath{ 3 }; 
                case 'single'
                    obj.workMscriptPath = defaultpath;
                    obj.workMdataPath   = defaultpath;
                    obj.workImagePath   = defaultpath;
                otherwise
                    error( ...
                        'SchematicTools:Canvas:illegalkeyword', ...
                        '''specifier'' must be a char-vector with the following values: ''multiple'', ''single''!' );
            end
        end
    end
    methods
        convertExternalFigToPDF( obj, FIG, filename, printSpecifier, printspaceoffset);
    end
    methods( Hidden )
        % basic selection methods
        select( obj, rect, excludeIdentifier );
        atomicSelect( obj, pos );
        release( obj );
        atomicRelease( obj );
        move( obj, transVec );
    end
    methods( Hidden )
        flushGuide( obj, guideIdentifier );
        saveGuidePointsToFiles(obj, filename);
        
        % creates a guide point on the canvas. This only activates if
        % currentMode is set to 'normal' or 'image'
        addGuide( obj, guideCoordinate );
    end
    methods( Hidden )
        % main deletion method (deletes the last created schematic object),
        % can be used repeatedly to exhaust the object container ...
        flush( obj, objIdentifier );

    end
    methods( Access = private )
        % mainly used in the selection mode ... 
        selectionInitialize(         obj         );
        selectionAddAnchor( obj,     anchorCoord );
        selectionPointerMotionCallback( obj, ~, ~);
        deactivateSelectionLineCallback(obj, ~, ~);
    end
    methods (Hidden)
        % auxilliary methods. Users don't usually interact with those
        % methods, unless they want to fine-tune the canvas' behaviour.
        function add( obj, schematicobj )
            c = obj.schematicContainer.getSize();
            if ~obj.useCustomName
                % set default name identified by the counter
                schematicobj.name = ['schematicObj', num2str( c + 1 ) ];
            end
            obj.schematicContainer.add( schematicobj );
            
            newListener = addlistener( schematicobj, 'destroyedState', @obj.destroyReferenceCallback );
            obj.schematicListenerContainer.add( newListener );
            if ~isempty( obj.lastAddedSchematic )
                % establish a doubly-linked list between the last added
                % object and the current schematic object ...
                obj.lastAddedSchematic.setDoublyLinkedAssociate( schematicobj, 'forward' );
                schematicobj.setAssociate( obj.lastAddedSchematic );
            end
            obj.lastAddedSchematic = schematicobj;
            
        end
        function enabledState = canvasEnabledCapture( obj )
            % read-only, returns the current capture state. The capture
            % state refers to the creation of the reference of the
            % schematic object being created. If the capture state is true
            % , the canvas saves the reference of the object to the 
            % relevant container. 
            
            enabledState = obj.EnableCapture;
        end
        function setEnableCapture( obj, state )
            % method for changing the capture state (no check on the input
            % state, but should be okay since user will not be using it
            % interactively in general)
            
            obj.EnableCapture = strcmpi(  state , 'on' );
        end
        function setSaveWindowProperties( obj, varargin )
            % set the window properties 
            
            assert( ~isempty( obj.savepanel ) && obj.savepanel.isvalid, ...
                'SchematicTools:Canvas:emptyObject', ...
                'deleted save window!' );
            set( obj.savepanel, varargin{:} );
        end
    end
    methods(Access = private)
        function internalConfigurateCanvas( obj )
            % set the default master figure property. This initializes when
            % no argument is passed to the constructor of the canvas ... 
            
%             fixedFigurePosition = [.0823, .2093, .3943, .6472];
            % we fix a predefined figure 'position' ...
            fixedFigurePosition = [0.1214    0.0741    0.4724    0.8074];
            obj.parent.ggrid( 'minor' );
            obj.parent.ggrid( 'on' );
            obj.parent.turntext( 'off' );
            obj.parent.turn( 'on' );
            obj.parent.hold( 'on' );
            set( obj.parent.Fig, ...
                'position', fixedFigurePosition, ...
                'color'   , 'w', ...
                'name'    , 'canvas', ...
                'toolbar', 'none');
            set( obj.parent.Axs, ...
                'ActivePositionProperty', 'position', ...
                'gridcolormode', 'manual', ...
                'position',  [0.05, .05, .9, .9], ...
                'gridcolor', [.5, .5, .5], ...
                'gridalphamode', 'manual', ...
                'gridalpha', 1, ...
                'minorgridlinestyle', '-', ...
                'minorgridcolor', [.6, .6, .6], ...
                'minorgridcolormode', 'manual', ...
                'minorgridalpha', .45, ...
                'minorgridalphamode', 'manual', ...
                'xtick', 0:.05:1, ...
                'ytick', 0:.05:1, ...
                'fontsize', 7.5, ...
                'fontweight', 'bold');
        end
        function throwResizingWarningMsg( ~ )
            % throw the following warning upon creation of the canvas ...
            warning( ...
                'SchematicTools:Canvas:formatIntegrity', ...
                ['For best result, try avoid using ''axis(''equal'')'' or', ...
                ' ''zoom'' on the current canvas to avoid conflict with build-in MATLAB operations!'] ); 
        end
    end
    methods(Access = private)
        function guidePointCallback( obj, ~, ~ )
            if obj.EnableGuidePoint
                % set the 'ButtonDownFcn' property on the axes to the
                % specified callback
                set( obj.parent.Axs, 'ButtonDownFcn', @obj.canvasMouseClickCallback );
            else
                % else replacing it with the default value '';
                set( obj.parent.Axs, 'ButtonDownFcn', '' );
            end
        end
        function guideNumericLabelOnGuide( obj, ~, ~ )
            % Callback for the 'EnableNumericLabelOnGuidePoint' property.
            % Note: this can be triggered by a specified key from the
            % keyboard (see 'internalKeyIsPressed' function for info )
            visiblestate = 'on';
            if ~obj.EnableNumericLabelOnGuidePoint, visiblestate = 'off'; end
            if ~obj.ClickedPointTextContainer.isContainerEmpty()
                for p = obj.ClickedPointTextContainer.getAll()
                    p.setProperties('textbox', 'visible', visiblestate );
                end
            end
        end
        function deactivateHolder( obj, ~, ~)
            if ~isempty( obj.tmpShapeHolder )
                obj.tmpShapeHolder.turn( 'off' );
            end
        end
        function destroyReferenceCallback( obj, ~, evtdata )
            destroyedreference = evtdata.destroyedObjReference;
            id = obj.schematicContainer.getObjID( destroyedreference );
            if id > 0
                listenerref = obj.schematicListenerContainer.GetObjRef( id );
                listenerref.delete(); 
                obj.schematicContainer.DeleteObjReference( id );
                % we forgot to destroy the listener ... 
                obj.schematicListenerContainer.DeleteObjReference( id );
            end
        end
        %% all internal methods for controlling the behaviour of the canvas
        
        % (general)
        internalResolvePath( obj, pathinput );
        internalCreateDefaultPath(   obj    );   
        internalKeyIsPressed( obj, ~, keydata );
        internalChangeContextureListener( obj ); 
        internalAddModeTextIdentifierPanel(obj);
        internalUpdateContextureUIComponent( obj );
        internalParseInputs( obj, varargin );
        % ( normal )
        internalNormalKeyPressed( obj, key );
        internalBringContextureSaveWindow( obj );
        internalEditableStringCallback(obj,~, ~);
        internalDrawShapeBasedOnGuidePoints( obj );
        
        % (selection)
        internalSelectionKeyPressed( obj, key );
        internalSaveCapturedSelection( obj, ~, ~);
        internalSaveCapturedSelectionToPDF( obj, ~, ~ );
        internalSetTranslationStep( obj, ~, ~ );
        internalSelectionReset( obj );
        internalSaveAsPDFCallback( obj, ~, ~ );
        
        % (text)
        internalTextKeyPressed( obj, key );
        internalTextInitialization( obj );
        internalTextBringContexturePanel( obj, pos );
        internalTextStringCallback( obj, ~, ~ );
        internalTextReset( obj );
        
        % (circle)
        internalCircleInitialization( obj );
        internalCircleKeyPressed( obj, keypressed );
        
        % (property panel)
        internalPropertyStructInitialization( obj );
        [propertynamecell, logicalVec, propertyvalcell] = ...
            internalPropertyReturnCurrentPropertyName( obj );
        %   ... export to the preview-place holder
        internalExportShape(obj, ~, ~ );
        internalExportText( obj, ~, ~  );
        internalExportArrowText(obj, ~, ~ );
        internalExportCircle(obj, ~, ~);
        
        internalExportShapeToConcreteContainer(     obj, ~,  ~);
        internalExportTextToConcreteContainer(      obj, ~,  ~);
        internalExportArrowTextToConcreteContainer( obj, ~,  ~);
        internalExportCircleToConcreteContainer(    obj, ~,  ~);
        
        internalPropertyPanelInitialize(          obj            );
        internalPropertyEditableCallback( obj, ~, ~, strID, uiObj);
        internalPropertySetEditableListener(          obj        );
        
        % (atomic select)
        internalAtomicSelectKeyPressed( obj, keypressed );
        
        % (output current script to .m file )
        internalOutputContainerToScript( obj, filename  );
        internalOutputBringContextureWindow(     obj    ); 
        internalOutputSetListener(               obj    );
        internalOutputCallback(          obj, ~, ~      );
        
        % make sure 'stack' behavior is correct 
        internalCorrectStackOrder( obj );
        
        % import image callbacks ... 
        internalImportImageCallback(obj, ~, ~ );
        internalImportImageDestory( obj );
        
        % locking methods
        internalxlockCallback( obj, ~, ~ );
        internalylockCallback( obj, ~, ~ );
        
        % key-assignment callback 
        internalAssignKeys( obj, ~, ~ );
        
        % internal methods for the imager
        internalImageInitialize( obj                );
        internalImageCalibrationCallback( obj, ~,  ~);
        internalImageKeyPressed( obj, keypressed    );
        internalImageSavingModeUICallback(obj, ~, ~ );
        internalImageTerminationFlagCallback(obj,~,~);
        internalImageReset( obj );
        
        % internal zoom methods ...
        internalZoomIn(   obj  );
        internalZoomOut(  obj  );
        internalZoomReset( obj );
    end
    methods(Access = private)
        canvasMouseClickCallback( obj, ~, ~ );
        resortNumericNameOfGuides( obj );
    end
    methods(Access = private, Static)
        % will be deprecated in future release ... 
        defaultpath = testReturnDefaultPath();
        
        % folder path for the 'mscript', 'mscriptdata' and an 'image' output path
        [Mscriptpath, Mscriptdatapath, ImageOutputpath] = testGetWorkPath();
    end
    methods(Static, Hidden)
        % some static methods
        
        staticModifyCloseRequestFcn(~, ~, FigureWind);
        staticModifyPropertyPanelCloseRequestFcn( ~, ~, canvas );
        stringoutput = staticgetstringasoutput( input );
        clockasstring = staticgetclockasstring();
        A = staticgetcustompointer();
    end
end
