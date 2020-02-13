classdef SchematicShape < AbstractSchematicComponent 
    % SchematicShape - general shape class that allows various operations
    % to be performed on the parametrized shape.
    
    properties
        % name - identifier
        name  = 'name';
        
        % type is 'shape'
        type  = 'shape';
        
        % style ('open', 'close')
        style = 'close';
        
        % parent should be a valid instance of the 'Schematic2D' class
        parent = [];
        
        % anchor position, by default it is set to the centroid of the data
        % set ... 
        position;       
        
        % fill shape -> only applicable to the 'close' style 
        fillShape  = false;
    end
    properties(Hidden)
        inautogenmode  = false;
    end
    
    properties(SetAccess = private, Hidden)
        % raw data - must be given as row-vectors and must conform to
        % certain rules
        xRawData;
        yRawData;
        
        % interpolated spline structure that contains the spline
        % information
        SampleSize                =  120;
        ppstr; 
        
        % final-arclength
        arcLength;
        fillColor                  = 'k';  
        faceAlpha                  =   1;
        vectorOfPatches            =  [];
        
        % shape composition
        lastPropertyCell           =  [];
        currentPropertyCell        =  [];
        shape;                  
        
        % custom anchor ... 
        useCustomAnchor            = false;
        % draw handle 
        drawhandle;
        
        
        %% associates
        
        % doubly linked
        BackwardAssociate;
        ForwardAssociate;
        
        % singly linked (to be deprecated)
        associate;
        
        %% listener for the data modification event 
        DataModificationListener;
    end
    properties(SetAccess = private, Hidden)
        % pointManager ...
        lastPointAdded             = [];
        pointManager;
    end
    properties(Access = private)
        % listener for the selectedState
        selectedTextBox;
        selectedStateListener;
        deselectedStateListener;
        
        % data-path
        datafilename               = [];
    end
    properties(Access = private)
        atomicTranslationListener;
    end
    events
        RawDataModified;
        selectedState;
        destroyedState;
    end
    methods
        function obj = SchematicShape( Parent, Style, varargin)
            %
            assert( isa( Parent, 'Schematic2D') || Parent.isvalid, ...
                'SchematicTools:Shape:illegalConstructorInput', ...
                'First argument in the supplied inputs must be a valid instance of the ''Schematic2D'' class');
            obj.parent = Parent;
            if nargin > 1
                % explicit 'style' initialization, parse and check that
                % input conforms to rules. 
                obj.style = SchematicShape.checkShapeStyle( Style );
            end
            % add listener to the 'RawDataModified' event
            obj.DataModificationListener = addlistener(obj, 'RawDataModified', @obj.internalRecomputePPstr );
            obj.setDefaultProperty();
            if nargin > 2
                obj.setProperties( varargin{:} );
            end
            if Parent.canvasEnabledCapture()
                Parent.add( obj );
                obj.addSelectionAttribute();
                obj.addAtomicTranslationListener();
            end
        end
        function addSelectionAttribute( obj )
            % manually set the selection attribute ... 
            obj.parent.setEnableCapture( 'off' );
            % prevent the selectedTextbox being captured by the canvas,
            % since its purpose is to inform the user 
            obj.selectedTextBox = SchematicLine( obj.parent, 'straighttextbox','Color', 'none');
            % set the dimension of the box
            obj.selectedTextBox.setTextboxSize( 0.04, .025 );
            obj.selectedTextBox.setProperties('textbox', 'backgroundcolor', 'none', 'edgecolor', 'none' );
            %
            obj.parent.setEnableCapture( 'on' );
            % create the listener for the selectedState
            obj.selectedStateListener = addlistener( obj, 'selectedState', @obj.selectedStateCallback);

            % create the listener for the deselectedState
            obj.deselectedStateListener = addlistener( obj.parent, 'deselectedObjects', @obj.deselectedStateCallback);
        end
        function addAtomicTranslationListener( obj )
            obj.atomicTranslationListener = addlistener( obj.parent, ...
                'atomicTranslationEnd', @obj.atomicTranslationEndedCallback);
        end
        function getDataFromDataFile( obj, fileName )
            % Data file must be a N-by-2 matrix
            dataMatrix = dlmread( fileName );
            xraw = dataMatrix(:, 1);
            yraw = dataMatrix(:, 2);
            % before one can add to the internal properties 'xRawData' and
            % 'yRawData', we need to make sure that the correct dimension
            % is obtained by applying the necessary scaling operation.
            
            obj.internalCheckAndScaleDataRelativeToCentroid( xraw, yraw );
            
            % try to store the 'fileName' ...
            obj.datafilename = fileName;
        end
        function getData( obj, xraw, yraw )
            obj.internalCheckAndScaleDataRelativeToCentroid( xraw, yraw );
        end
        function draw( obj, varargin )
            %
            if ~isempty( obj.xRawData ) && ~isempty( obj.yRawData )
                n = nargin - 1;
                if n > 0
                    % compute the centroid
                    for k = 1 : n / 2
                        switch varargin{ 2 * k - 1}
                            case 'translate'
                                translatevector = varargin{ 2 * k };
                                obj.internalMoveData( translatevector );
                            case 'move'
                                % the 'move' is to translate the data in
                                % such a way the anchor coincides with the
                                % destination vector
                                movevector = varargin{ 2 * k };
                                translatevector = movevector - obj.position.position;
                                obj.internalMoveData( translatevector );
                            case 'rotate'
                                angle      = varargin{ 2 * k };
                                obj.internalRotateData( obj.position, angle );
                            case 'scale'
                                scale      = varargin{ 2 * k };
                                obj.internalScaleData(  obj.position, scale );
                            otherwise
                                error( ...
                                    'SchematicTools:Shape:illegalkeyword', ...
                                    'property-name not recognised!' );
                        end
                    end
                end
                obj.drawhandle();
                obj.turn( 'on' );
            end
        end
        function setProperties( obj, varargin )
            obj.currentPropertyCell = varargin;
            % update now
            obj.updateProperty();
        end
        function updateProperty( obj )
            if ~isempty( obj.shape )
                set( obj.shape, obj.currentPropertyCell{:} );
            end
        end
        function turn( obj, state )
            if ~isempty( obj.shape )
                set( obj.shape, 'visible', state );
            end
            if ~isempty( obj.vectorOfPatches )
                for p = obj.vectorOfPatches
                    set( p, 'visible', state );
                end
            end
        end
        function setFillColor( obj, colorSpec)
            obj.fillColor = colorSpec;
        end
        function deleteObj( obj )
            % delete the graph elements first if they exist ... 
            if ~isempty( obj.shape ) && obj.shape.isvalid
                obj.shape.delete();
            end
            if ~isempty( obj.position ) && obj.position.isvalid
                obj.position.deleteObj();
            end
            
            if ~isempty( obj.vectorOfPatches )
                obj.vectorOfPatches.delete();
            end
            % delete listeners
            if ~isempty( obj.selectedStateListener )
                obj.selectedStateListener.delete();
            end
            if ~isempty( obj.deselectedStateListener )
                obj.deselectedStateListener.delete();
            end
            if ~isempty( obj.atomicTranslationListener )
                obj.atomicTranslationListener.delete();
            end
            % re-connect the doubly linked nodes
            if ~isempty( obj.BackwardAssociate )
                obj.BackwardAssociate.setDoublyLinkedAssociate( ...
                    obj.ForwardAssociate, 'forward'   );
            elseif ~isempty( obj.ForwardAssociate ) 
                obj.ForwardAssociate.setDoublyLinkedAssociate( ...
                    obj.BackwardAssociate, 'backward' );
            end
            if exist( obj.datafilename, 'file' ) == 2 && obj.inautogenmode
                % delete the associated file ... 
                delete(obj.datafilename);
            end
            evntdat = SchematicDestroyEventData( obj );
            notify( obj, 'destroyedState', evntdat );
            obj.delete();
        end
        function setSamplingSize( obj, newSampleSize)
            % if the current sampling size is not sufficient, use this to
            % set the new sameple size
            assert( isnumeric( newSampleSize ) && isscalar( newSampleSize ), ...
                'SchematicTools:Shape:illegaltype', ...
                'specified sample size must be a scalar positive numerical value!');
            newSampleSize = floor( abs( newSampleSize ) );
            obj.SampleSize = newSampleSize;
        end
        function setCustomAnchor( obj, info )
            % 'info' is either numeric (scalar or 2-element vector) or
            % instance of the 'SchematicCircle' class
            if isnumeric( info )
                % differentiate between scalar and vector
                if isscalar( info )
                    info = abs( floor( info ) );
                    % compare the number of elements
                    assert( info <= numel( obj.xRawData ), ...
                        'SchematicTools:Shape:illegalAccess', ...
                        'Supplied indexing argument exceeds the size of the data set!' );
                    % for this, the anchor position is given by 
                    obj.position.setCircleGeometry( [obj.xRawData( info ), obj.yRawData( info ) ] );
                    obj.useCustomAnchor = true;
                elseif isvector( info ) && numel( info ) == 2
                    if ~isrow( info ), info = info.'; end
                    obj.position.setCircleGeometry( info );
                    obj.useCustomAnchor = true;
                else
                    error( ...
                        'SchematicTools:Shape:illegalDimension', ...
                        'Supplied argument must be a scalar or a two-element vector!' );
                end
            else
                % check whether info is an instance of the
                % 'SchematicCircle' class
                assert( isa(info, 'SchematicCircle'), ...
                    'SchematicTools:Shape:illegaltype', ...
                    'Supplied argument must be a valid instance of the ''SchematicCircle'' class!');
                % extract the position data from 'info'
                obj.position.SetCircleGeometry( info.position );
                obj.useCustomAnchor = true;
                
            end
        end
        function testLoadAerofoilData( obj )
            X = SchematicShape.testLoadAerofoilDataFromTestFolder();
            obj.getData( X(:,1).', X(:, 2).' );
        end
        function setFromOtherShape( obj, otherShape, sampleSize )
            % 'copy' the parametrized shape from 'otherShape'
            assert( isa( otherShape, 'SchematicShape' ), ...
                'SchematicTools:Shape:illegaltype', ...
                'First argument must be a valid instance of the ''SchematicShape'' class!' );
            % check the style
            assert( strcmpi( otherShape.style, 'open' ), ...
                'SchematicTools:Shape:illegalProperty', ...
                'The supplied SchematicShape object is of incorrect ''style''!' );
            if nargin > 2
                % set the internal sample size to the supplied argument
                obj.SampleSize = sampleSize;
            end
            % we create the x and y coordinate from the evaluator
            evaluator = otherShape.getShapeEvaluator();
            arclength = otherShape.arcLength;
            s = (0 : obj.SampleSize - 1 ) * arclength / (obj.SampleSize - 1);
            [x, y] = evaluator( s ); 
            obj.getData(x, y);
            
            % sets the anchor point of 'obj' to match with the anchor in
            % 'othershape' 
            obj.setCustomAnchor( otherShape.position.position );
        end
        
        % these two methods allow a continual chain to be created ...
        
        % ----------------------------
        % singly-linked list ... 
        % -----------------------------
        
        function setAssociate( obj, associateObj )
            % we don't really care about 
            obj.associate = associateObj;
        end
        
        function associateObj = getAssociate( obj )
            associateObj = obj.associate;
        end
        
        % ----------------------------
        % doubly-linked list ... 
        % -----------------------------
        
        
        function setDoublyLinkedAssociate( obj, LinkedObj, DirectionStr )
            switch lower( DirectionStr )
                case 'forward'
                    if isempty( LinkedObj )
                        obj.ForwardAssociate = []; return;
                    end
                    if obj.ForwardAssociate == LinkedObj, return; end
                    obj.ForwardAssociate = LinkedObj;
                    LinkedObj.setDoublyLinkedAssociate( obj, 'backward' );
                case 'backward'
                    if isempty( LinkedObj )
                        obj.BackwardAssociate = []; return;
                    end
                    if obj.BackwardAssociate == LinkedObj, return; end
                    obj.BackwardAssociate = LinkedObj;
                    LinkedObj.setDoublyLinkedAssociate( obj, 'forward' );
                    
            end
        end
        
        function associate_ = getDoublyLinkedAssociate( obj, DirectionStr )
            switch lower( DirectionStr )
                case 'forward'
                    associate_ = obj.ForwardAssociate;
                case 'backward'
                    associate_ = obj.BackwardAssociate;
            end
        end
    end
    methods( Hidden )
        function isShapeSelected = Selected( obj, rect )
            % create the bounding box of the data
            % we use the orientation ... 
            % 
            %              1 --- 2
            %              |     |    
            %              |     |
            %              4 --- 3
            isShapeSelected = false;
            if isempty( obj.xRawData ) || isempty( obj.yRawData ) 
                return;
            end
            xmin = min( obj.xRawData ); xmax = max( obj.xRawData );
            ymin = min( obj.yRawData ); ymax = max( obj.yRawData );
            
            x = [xmin, xmax, xmax, xmin];
            y = [ymax, ymax, ymin, ymin];
            isShapeSelected = any( ...
                ( rect(1) <= x & x <= rect(3) ) & ...
                ( rect(2) <= y & y <= rect(4) ) );
%             isShapeSelected = ...
%                 ( (xmin <= rect(1) && rect(1) <= xmax ) && ( ymin <= rect(2) && rect(2) <= ymax ) ) || ...
%                 ( (xmin <= rect(3) && rect(3) <= xmax ) && ( ymin <= rect(4) && rect(4) <= ymax ) );
            if isShapeSelected
                notify( obj, 'selectedState' ); 
            end
        end
        function translate( obj, transVec )
            % already contained an internal method that translates the
            % point. So one only needs to guard the safety of the element
            % access ... 
            if isempty( obj.xRawData ) || isempty( obj.yRawData ), return; end
            obj.internalMoveData( transVec );
            % update now
            obj.drawhandle();
            
        end
    end
    methods
        % those are atomic operations
        atomicTranslate( obj, transVec );
        function atomicScale(  obj, pivot, scale ), obj.internalScaleData( pivot, scale ); obj.drawhandle(); end
        function atomicRotate( obj, pivot, angle ), obj.internalRotateData(pivot, angle ); obj.drawhandle(); end
    end
    methods(Hidden)
        addpoint( obj, pos );
        deletepoint( obj, identifier );
        make( obj );
        evaluator = getShapeEvaluator( obj );
        isObjSelected = atomicSelect( obj, pos, offset);
        [stringcell, datafile] = outputstream( obj );
        stacktop(obj);
        setAlphaData( obj, alpha );
        function dummy = schematicContainsText( ~ ), dummy = false; end
    end
    methods(Hidden)
        function setDefaultProperty( obj )
            obj.setLineDefaultPropertyCell();
            switch obj.style
                case 'close'
                    obj.drawhandle = @obj.internalEvaluateClosedShape;
                case 'open'
                    obj.drawhandle = @obj.internalEvaluateOpenShape;
            end
            % create a default anchor
            
            % note that the anchor should not be captured by the canvas,
            % since it acts as a ghost node in the shape ... 
            captureStateIsEnabled = obj.parent.canvasEnabledCapture();
            if captureStateIsEnabled, obj.parent.setEnableCapture( 'off' ); end
            obj.position = SchematicCircle( obj.parent, 'circle' );
            obj.position.setCircleGeometry( [0, 0], .001, 0, 2 * pi );
            obj.pointManager = GeneralManager();
            % revert back to the previously default state 
            if captureStateIsEnabled, obj.parent.setEnableCapture( 'on' ); end
        end
        function setLineDefaultPropertyCell( obj )
            obj.lastPropertyCell = { ...
                'visible', 'off', ...
                'linestyle', '-', ...
                'linewidth', 1.2, ...
                'color', 'k', ...
                };
            obj.currentPropertyCell = obj.lastPropertyCell;
        end
    end
    methods(Access = private)
        internalRecomputePPstr( obj, ~, ~);
        % scaling
        internalScaleData( obj, pivot, scalefactor);
        % translation
        internalMoveData( obj, TranslationVector );
        % rotation
        internalRotateData( obj, pivot, angle );
        % final check
        internalCheckAndScaleDataRelativeToCentroid( obj, xraw, yraw);
        
        % final evaluation
        internalEvaluateClosedShape( obj );
        internalEvaluateOpenShape(  obj  );
    end
    methods(Access = private)
        function selectedStateCallback( obj, ~, ~ )
            % a call-back that responds to the selected state
            % 
            numberOfElement = numel( obj.xRawData );
            xcentroid = sum( obj.xRawData ) / numberOfElement;
            ycentroid = sum( obj.yRawData ) / numberOfElement;
            obj.selectedTextBox.draw( 'start', [xcentroid, ycentroid], 'end', [xcentroid, ycentroid] );
            obj.selectedTextBox.setText( 'selected', 'fontsize', 10, 'color', 'g');
        end
        function deselectedStateCallback( obj, ~, ~ )
            % simply turn-off the selectedTextbox 
            obj.selectedTextBox.turn( 'off' );
        end
        function atomicTranslationEndedCallback( obj, ~, ~ )
            % recompute ppstr and update
            obj.internalRecomputePPstr(); 
            obj.drawhandle();
        end
    end
    methods(Access = private)
        resortPointManager( obj );
    end
    methods(Static, Hidden)
        function correctedKey = checkShapeStyle( styleKey )
            defaultKey = 'close';
            styleKeyIsValid = ischar( styleKey ) && ( ...
                strcmpi( styleKey, 'close' ) || ...
                strcmpi( styleKey, 'open' ) );
            if ~styleKeyIsValid
                % throw a warning and set default key to ''close''
                warning( ...
                    'SchematicTools:Shape:illegalKeyword', ...
                    ['style key must be a char array and take the following values: ', ...
                    '''close'', ', ...
                    '''open'''] );
            else
                defaultKey = lower( styleKey );
            end
            correctedKey = defaultKey;
            
        end
    end
    methods(Static, Hidden)
        X = testLoadAerofoilDataFromTestFolder();
    end
end