classdef SchematicCircle < AbstractSchematicComponent
    properties
        % name - identifier ... 
        name  =  'name';
        
        % type is circle
        type  =  'circle';
        
        % style (''circle'', ''arc'', ''counterclockeddy'', ''clockeddy'')
        style =  'circle';
        
        % parent should be a valid instance of the 'Schematic2D' - a canvas
        %
        parent = [];
        
        % position 
        position;
        radius;
        
        % fill circle by creating a collection of patch objects
        fillCircle   = false;
    end
    properties (SetAccess = private, Hidden)
        % line property cell
        lastPropertyCell        =  [];
        CurrentPropertyCell     =  [];
        
        % generating handle
        drawhandle;
        
        % associate 
        associate;
        
        % doubly linked list 
        BackwardAssociate;
        ForwardAssociate;
        
    end
    properties(SetAccess = private, Hidden)
        % basic circle composition: 
        body;                       % mainly a plot object
        arrow;                      % square triangular head
        headproportion  = .5;       % in percentage of the radius
        StartPolarAngle =      0;        %
        EndPolarAngle   = 2 * pi;   % 
        fillColor       = 'k';      % 'circle' style only 
        SampleSize      =  40;      %
        VectorOfPatch   =  [];      % vector of patch objects
    end
    properties(Access = private)
        % listener for the selectedState
        selectedTextBox;
        selectedStateListener;
        deselectedStateListener;
    end
    events
        selectedState;
        destroyedState;
    end
    methods
        function obj = SchematicCircle( Parent, Style, varargin )
            assert( ...
                isa( Parent, 'Schematic2D' ) || Parent.isvalid, ...
                'SchematicTools:Circle:illegalConstructorInput', ...
                'First argument in the supplied inputs must be a valid instance of the ''Schematic2D'' class' );
            obj.parent = Parent;
            if nargin > 1
                % explicit 'style' initialization, parse and check that
                % input conforms to rules
                obj.style = SchematicCircle.checkCircleStyle( Style );
            end
            obj.setDefaultProperty();
            if nargin > 2
                % set default properties ... 
                obj.setProperties( varargin{:} );
            end
            if Parent.canvasEnabledCapture()
                Parent.add( obj );
                obj.addSelectionAttribute();
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
        function setProperties( obj, varargin)
            obj.CurrentPropertyCell = varargin;
            % check for the colorspec ... 
            colorkey = SchematicLine.checkColorSpec( obj.CurrentPropertyCell );
            if ~isempty( colorkey ), obj.fillColor = colorkey; end
            obj.updateProperty();
        end
        function updateProperty( obj )
            if ~isempty( obj.body )
               set( obj.body, obj.CurrentPropertyCell{:} );
            end
            if ~isempty( obj.arrow )
                set( obj.arrow, 'facecolor', obj.fillColor );
            end
        end
        function setCircleGeometry( obj, newPosition, newRadius, newInitialPolar, newFinalPolar, newHeadProportion )
            % one sets the circle geometry ... 
            if nargin > 1, obj.position = newPosition; end
            if nargin > 2, obj.radius   = newRadius  ; end
            if nargin > 3, obj.StartPolarAngle = newInitialPolar; end
            if nargin > 4, obj.EndPolarAngle   = newFinalPolar  ; end
            if nargin > 5, obj.headproportion  = newHeadProportion; end
        end
        function setSamplingSize( obj, newSampleSize )
            % if the current sampling size is not sufficient, use this to
            % set the new sameple size
            assert( isnumeric( newSampleSize ) && isscalar( newSampleSize ), ...
                'SchematicTools:Circle:illegaltype', ...
                'specified sample size must be a scalar positive numerical value!');
            % prepared size
            newSampleSize = floor( abs( newSampleSize ) );
            obj.SampleSize = newSampleSize;
        end
        function turn( obj, state )
            if ~isempty( obj.body )
                set( obj.body, 'visible', state );
            end
            if ~isempty( obj.arrow )
                set( obj.arrow, 'visible', state);
            end
            if ~isempty( obj.VectorOfPatch )
                set( obj.VectorOfPatch, 'visible', state );
            end
        end
        % finally, the important draw routine
        function draw( obj, varargin )
            %
            defaultPosition = obj.position;
            defaultRadius   = obj.radius;
            defaultInitialPolar = obj.StartPolarAngle;
            defaultFinalPolar   = obj.EndPolarAngle;
            n = nargin - 1;
            if n > 0
                assert( mod(n, 2) == 0, ...
                    'SchematicTools:Circle:incorrectInputFormat', ...
                    'inputs must conform to ''propname'', propval'', ... pair');
                for k = 1 : n / 2
                    switch varargin{ 2 * k - 1 }
                        case 'position'
                            defaultPosition = varargin{ 2 * k };
                            % saves the color position
                            obj.position = defaultPosition;
                        case 'radius' 
                            defaultRadius   = varargin{ 2 * k };
                            obj.radius = defaultRadius;
                        case 'initialpolar'
                            defaultInitialPolar = varargin{ 2 * k };
                            obj.StartPolarAngle = defaultInitialPolar;
                        case 'finalpolar'
                            defaultFinalPolar   = varargin{ 2 * k };
                            obj.EndPolarAngle = defaultFinalPolar;
                        otherwise
                            error( ...
                                'SchematicTools:Circle:illegalkeyword', ...
                                'property-name not recognised!' );
                    end
                end
            end
            obj.drawhandle( defaultPosition, defaultRadius, defaultInitialPolar, defaultFinalPolar );
            
            % turn on graph object now! 
            obj.turn( 'on' );
        end
        function setFillColor( obj, colorSpec )
            % colorSpec is either an 'rgb' vector, or one of the color
            % short keys.
            %
            obj.fillColor = colorSpec;
        end
        function deleteObj( obj )
            % first check that the graph elements exist ... 
            if ~isempty( obj.body ) && obj.body.isvalid
                if ~isempty( obj.VectorOfPatch )
                    obj.VectorOfPatch.delete();
                end
                obj.body.delete();
            end
            if ~isempty( obj.arrow ) && obj.arrow.isvalid
                obj.arrow.delete();
            end
            if ~isempty( obj.selectedStateListener )
                obj.selectedStateListener.delete();
            end
            if ~isempty( obj.deselectedStateListener )
                obj.deselectedStateListener.delete();
            end
             % re-connect the doubly linked nodes
            if ~isempty( obj.BackwardAssociate )
                obj.BackwardAssociate.setDoublyLinkedAssociate( ...
                    obj.ForwardAssociate, 'forward'   );
            elseif ~isempty( obj.ForwardAssociate ) 
                obj.ForwardAssociate.setDoublyLinkedAssociate( ...
                    obj.BackwardAssociate, 'backward' );
            end
            evntdat = SchematicDestroyEventData( obj );
            notify( obj, 'destroyedState', evntdat );
            obj.delete();
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
        function isCircleSelected = Selected( obj, rect )
            % First bound the 'circle' with a square, get the corner data
            % of the square, then we check if they intersect with each
            % other.
            % uses the following orientation: 
            % 
            %              1 --- 2
            %              |     |    
            %              |     |
            %              4 --- 3
            
            isCircleSelected = false;
            if isempty( obj.position ) || isempty( obj.radius ), return; end
            % luckily, both of which use the physical metric system ... 
            x = [ ...
                obj.position(1) - obj.radius, ...
                obj.position(1) + obj.radius, ...
                obj.position(1) + obj.radius, ...
                obj.position(1) - obj.radius ];
            y = [ ...
                obj.position(2) + obj.radius, ...
                obj.position(2) + obj.radius, ...
                obj.position(2) - obj.radius, ...
                obj.position(2) - obj.radius ];
            isCircleSelected = any( ...
                ( rect(1) <= x & x <= rect(3) ) & ...
                ( rect(2) <= y & y <= rect(4) ) );
            if isCircleSelected
                notify( obj, 'selectedState');
            end
        end
        function isObjSelected = atomicSelect( obj, pos, offset )
            isObjSelected = false;
            if isempty( obj.position ) || isempty( obj.radius ), return; end
            defaultoffset = .02;
            if nargin > 2, defaultoffset = offset; end
            if ~isempty( obj.VectorOfPatch )
                % best indication that the obj is filled ... 
                isObjSelected = norm( pos - obj.position ) <= obj.radius + defaultoffset;
            else
                isObjSelected = ...
                    obj.radius - defaultoffset <= norm( pos - obj.position ) && ...
                    norm( pos - obj.position ) <= obj.radius + defaultoffset;
            end
            if isObjSelected, notify(obj, 'selectedState' ); end
            
        end
        function translate( obj, transVec )
            % simple translation
            obj.position = obj.position + transVec;
            obj.draw();
            
        end
        function atomicTranslate( obj, transvec ), obj.translate( transvec ); end
    end
    methods(Access = private)
        function setDefaultCircleStemProperty( obj )
            obj.lastPropertyCell = { ...
                'visible', 'off', ...
                'linestyle', '-', ...
                'linewidth', 1.2, ...
                'color', 'k'};
            %
            obj.CurrentPropertyCell = obj.lastPropertyCell;
        end
        
        function setDefaultProperty( obj )
            obj.setDefaultCircleStemProperty();
            switch obj.style
                case 'circle'
                    obj.drawhandle = @(pos, rad, polarInitial, polarFinal) ...
                        obj.internalSetCircle( pos, rad, polarInitial, polarFinal);
                case 'arc'
                    % 
                    obj.drawhandle = @(pos, rad, polarInitial, polarFinal) ...
                        obj.internalSetArc( pos, rad, polarInitial, polarFinal );
                case 'counterclockeddy'
                    obj.drawhandle = @(pos, rad, polarInitial, polarFinal) ...
                        obj.internalSetCounterClockEddy( pos, rad, polarInitial, polarFinal );
                case 'clockeddy'
                    obj.drawhandle = @(pos, rad, polarInitial, polarFinal) ...
                        obj.internalSetClockEddy( pos, rad, polarInitial, polarFinal );
            end
        end
    end
    methods(Hidden)
        setArrowHead( obj, HeadPosition, HeadOrientation, HeadSize );
        [stringcell, datafile] = outputstream( obj );
        stacktop( obj );
        function dummy = schematicContainsText( ~ ), dummy = false; end
    end
    methods(Access = private)
        % 
        function internalSetCircle( obj, position, radius, ~, ~ )
            % 
            % get the current XLIM and YLIM
            xlim = obj.parent.parent.Axs.XLim;
            ylim = obj.parent.parent.Axs.YLim;
            startPolarAngle = 0;
            endPolarAngle   = 2 * pi;
            dphi = (endPolarAngle - startPolarAngle) / ( obj.SampleSize - 1);
            if radius * dphi > .01
                obj.SampleSize = floor( radius *(endPolarAngle - startPolarAngle) / .01 );
                dphi = (endPolarAngle - startPolarAngle) / ( obj.SampleSize - 1);
            end
            phi  = (0 : obj.SampleSize - 1) * dphi;
            xdata = position(1) + radius * cos( phi );
            ydata = position(2) + radius * sin( phi );
            defaultBody = obj.body;
            if isempty( defaultBody )
                defaultBody = plot( ...
                    obj.parent.parent.Axs, ...
                    xdata, ...
                    ydata, ...
                    'pickableparts', 'none', ...
                    'visible', 'off', ...
                    obj.CurrentPropertyCell{:} );
                obj.body = defaultBody;
            else
                set( defaultBody, ...
                    'xdata', xdata, ...
                    'ydata', ydata);
            end
            % check if fill is activated
            if obj.fillCircle
                % flush the previously filled patches if they exist
                if ~isempty( obj.VectorOfPatch )
                    obj.VectorOfPatch.delete();
                end
                obj.VectorOfPatch = fill( ...
                    obj.parent.parent.Axs, ...
                    xdata, ydata, obj.fillColor, 'pickableparts', 'none' );
            end
            % manually set the limits if they have not adjusted
            % automatically
            obj.parent.parent.aaxis([xlim, ylim]);
        end
        function internalSetArc( obj, position, radius, startPolar, endPolar )
            % create an arc
            xlim = obj.parent.parent.Axs.XLim;
            ylim = obj.parent.parent.Axs.YLim;
            
            dphi = (endPolar - startPolar) / ( obj.SampleSize - 1 );
            if radius * dphi > .01
                obj.SampleSize = floor( radius *(endPolar - startPolar) / .01 );
                dphi = (endPolar - startPolar) / ( obj.SampleSize - 1);
            end
            phi  = startPolar + (0 : obj.SampleSize - 1) * dphi;
            xdata = position(1) + radius * cos( phi );
            ydata = position(2) + radius * sin( phi );
            defaultBody = obj.body;
            if isempty( defaultBody )
                defaultBody = plot( ...
                    obj.parent.parent.Axs, ...
                    xdata, ...
                    ydata, ...
                    'pickableparts', 'none', ...
                    'visible', 'off', ...
                    obj.CurrentPropertyCell{:} );
                obj.body = defaultBody;
            else
                set(defaultBody, 'xdata', xdata, 'ydata', ydata );
            end
            obj.parent.parent.aaxis([xlim, ylim]);
        end
        function internalSetCounterClockEddy( obj, position, radius, startPolar, endPolar)
            % 
            xlim = obj.parent.parent.Axs.XLim;
            ylim = obj.parent.parent.Axs.YLim;
            
            dphi  = (endPolar - startPolar) / (obj.SampleSize - 1);
            if radius * dphi > .01
                obj.SampleSize = floor( radius *(endPolar - startPolar) / .01 );
                dphi = (endPolar - startPolar) / ( obj.SampleSize - 1);
            end
            phi   = startPolar + (0 : obj.SampleSize - 1) * dphi;
            xdata = position(1) + radius * cos( phi );
            ydata = position(2) + radius * sin( phi );
            %udata = -radius * sin( phi( end ) ) * dphi;
            %vdata = +radius * cos( phi( end ) ) * dphi;
            defaultbody  = obj.body;
            % for the arrow, first determine how many divisions we need to
            % produce the necessary head size
            K = ceil( obj.headproportion / dphi );
            % determine the orientation 
            HeadOrientation = [ -sin( phi( end - K ) ), +cos( phi( end - K ) )];
            HeadSize        = obj.headproportion * radius * ones(1, 20);
            HeadPosition    = [ xdata( end - K ), ydata( end - K) ];
            if isempty( defaultbody )
                % create the body stem
                defaultbody = plot( ...
                    obj.parent.parent.Axs, ...
                    xdata(1:end - K), ...
                    ydata(1:end - K), ...
                    'pickableparts', 'none', ...
                    'visible', 'off', ...
                    obj.CurrentPropertyCell{:} );
                obj.body = defaultbody;
            else
                set( defaultbody, 'xdata', xdata(1:end - K), 'ydata', ydata(1:end - K) );
            end
            % add/update arrow head
            obj.setArrowHead( HeadPosition, HeadOrientation, HeadSize );
            obj.parent.parent.aaxis([xlim, ylim]);
        end
        function internalSetClockEddy( obj, position, radius, startPolar, endPolar )
            
            xlim = obj.parent.parent.Axs.XLim;
            ylim = obj.parent.parent.Axs.YLim;
            
            dphi  = (endPolar - startPolar) / (obj.SampleSize - 1);
            if radius * dphi > .01
                obj.SampleSize = floor( radius *(endPolar - startPolar) / .01 );
                dphi = (endPolar - startPolar) / ( obj.SampleSize - 1);
            end
            phi   = startPolar + (0 : obj.SampleSize - 1) * dphi;
            xdata = position(1) + radius * cos( phi );
            ydata = position(2) + radius * sin( phi );
            % differentiate and take the negation of the derivative ...
            %udata = +radius * cos( phi(1) ) * dphi;
            %vdata = -radius * sin( phi(1) ) * dphi;
            defaultbody  = obj.body;
            % determine the number of division needed to produce the
            % required head size. 
            K = ceil( obj.headproportion / dphi );
            HeadOrientation = [ sin( phi( K ) ), -cos( phi( K ) ) ];
            HeadPosition    = [ xdata( K ), ydata( K ) ];
            HeadSize        = obj.headproportion * radius * ones(1, 2);
            
            if isempty( defaultbody )
                defaultbody = plot( ...
                    obj.parent.parent.Axs, ...
                    xdata(K:end), ...
                    ydata(K:end), ...
                    'pickableparts', 'none', ...
                    'visible', 'off', ...
                    obj.CurrentPropertyCell{:} );
                obj.body = defaultbody;
            else
                set( obj.body, 'xdata', xdata(K:end), 'ydata', ydata(K:end) );
            end
            % add/update patch
            obj.setArrowHead( HeadPosition, HeadOrientation, HeadSize );
            obj.parent.parent.aaxis([xlim, ylim]);
        end
    end
    methods(Access = private)
        function selectedStateCallback( obj, ~, ~ )
            % a call-back that responds to the selected state
            obj.selectedTextBox.draw( 'start', obj.position, 'end', obj.position );
            obj.selectedTextBox.setText( 'selected', 'fontsize', 10, 'color', 'g');
        end
        function deselectedStateCallback( obj, ~, ~ )
            % simply turn-off the selectedTextbox 
            obj.selectedTextBox.turn( 'off' );
        end
    end
    methods( Hidden )
        atomicScale( obj, pivot, scale );
        atomicRotate( obj, pivot, angle);
    end
    methods(Static, Hidden)
        correctedKey = checkCircleStyle( styleKey );
    end
    
    methods(Static, Hidden)
        patchStruct = staticSetArrowHead( xpos, ypos, xdir, ydir, width, height);
    end
end