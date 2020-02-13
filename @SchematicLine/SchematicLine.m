classdef SchematicLine < AbstractSchematicComponent
    % a generalized line class for the canvas.
    
    properties
        % name - identifier ... 
        name = 'name';   
        
        % type is 'line'
        type = 'line';
        
        % style (''straight'', ''singlearrow'', ''doublearrow'', ... 
        %        ''straighttextbox'', ''doublestraighttextbox'',  ... 
        %        ''singlearrowtextbox'', 'doublearrowtextbox'' )
        style = 'straight'; 
        
        % parent should be a valid instance of the 'Schematic2D' - a canvas
        % class
        parent = [];
    end
    properties(SetObservable, Hidden )
        
        % a hidden arrow style ('patch' or 'quiver')
        arrowstyle = 'patch';
    end
    properties(SetAccess = private, Hidden)
        % line property cells
        lastPropertyCell           = [];
        CurrentPropertyCell        = [];
        
        internalStartPosition      = [0, 0];
        internalFinalPosition      = [0, 0];
        
        % textbox property cells
        lastTextboxPropertyCell    = [];
        currentTextboxPropertyCell = [];
        
        % draw handle - depending on the style of the SchematicLine ... 
        drawhandle;
        
        % associate holder 
        associate;
        
        % doubly linked list 
        BackwardAssociate;
        ForwardAssociate;
    end
    properties(SetAccess = private, Hidden)
        % line composition
        defaultTextBoxWidth  = .07;  %
        defaultTextBoxHeight = .03;  % 
        textBox;    % annotation object
        rightLine;  % line-obj
        arrowhead;  % arrowhead
        % a listener(mainly used to check input)
        arrowstylelistener;
        
        fillColor = 'k';
        headproportion = .15; % in proportion to the length of the line drawn
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
        function obj = SchematicLine(Parent, Style, varargin)
            assert( ...
                isa( Parent, 'Schematic2D' ) || Parent.isvalid, ...
                'SchematicTools:Line:illegalConstructorInput', ...
                'First argument in the supplied input must be a valid instance of the ''Schematic2D'' class' );
            obj.parent = Parent;
            if nargin > 1
                % explicit 'style' initialization, parse and check that
                % input conforms to rules
                obj.style = SchematicLine.checkLineStyle( Style );
            end
            obj.setDefaultProperty();
            if nargin > 2
                obj.setProperties( 'line', varargin{:} );
            end
            if Parent.canvasEnabledCapture()
                Parent.add( obj );
                obj.addSelectionAttribute();
            end
            obj.arrowstylelistener = addlistener(obj, 'arrowstyle', 'PostSet', @obj.arrowheadcallback);
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
        function setProperties( obj, ofWhat, varargin)
            % renew line properties
            if strcmpi( ofWhat, 'line' )
                % The line 
                obj.CurrentPropertyCell = varargin;
                % check colorspec ... 
                colorkey = SchematicLine.checkColorSpec( obj.CurrentPropertyCell );
                if ~isempty( colorkey ), obj.fillColor = colorkey; end
            elseif strcmpi( ofWhat, 'textbox')
                obj.currentTextboxPropertyCell = varargin;
            else
                error( ...
                    'SchematicTools:Line:illegalkeyword', ...
                    'property target name is not recognised!');
            end
            obj.updateProperty();
        end
        function draw(obj, varargin)
            % input must conform to ...
            %     'start', startObj, ...
            %     'end',   endObj
            % startObj or endObj either numeric (2-element vector), or
            % other object that has the 'position' property
%             narginchk(5, inf);
            n = nargin - 1;
            assert( mod(n, 2) == 0, ...
                'SchematicTools:Line:incorrectInputFormat', ...
                'inputs must conform to ''prop-name'', prop-val'', ... pair');
            extStartPos = obj.internalStartPosition;
            extEndPos   = obj.internalFinalPosition;
            for k = 1 : n / 2
                switch varargin{2 *k - 1}
                    case 'start'
                        StartObj = varargin{ 2 * k };
                        extStartPos = StartObj;
                        while ~isnumeric( extStartPos )
                            extStartPos = extStartPos.position;
                        end
                        % store the startObj's position to the internal
                        % property 'internalStartPosition'
                        obj.internalStartPosition = extStartPos;
                    case 'end'
                        EndObj = varargin{ 2 * k };
                        extEndPos = EndObj;
                        while ~isnumeric( extEndPos )
                            extEndPos = extEndPos.position;
                        end
                        obj.internalFinalPosition = extEndPos;
                    case 'arrowscale'
                        obj.headproportion = varargin{ 2 * k };
                    otherwise
                        error( ...
                            'SchematicTools:Line:illegalkeyword', ...
                            'property-name not recognised!');
                end
            end
            % use the drawhandle to update
            obj.drawhandle( extStartPos, extEndPos );
            
            % turn on such object
            obj.turn( 'on' );
        end
        
        function movetextbox( obj, newPosition )
            % move the text-box position to a new-position; assuming that
            % the text-box is already created ... 
            GrandAxes = obj.parent.parent.Axs;
%             GrandFigu = obj.parent.parent.Fig;
            x0 = GrandAxes.XLim(1);
            x1 = GrandAxes.XLim(2);
            y0 = GrandAxes.YLim(1); 
            y1 = GrandAxes.YLim(2);
            % also, we assume that 'newPosition' is within the axes' limit
            x  = newPosition(1); 
            y  = newPosition(2);
            % get current graph position
            currentAxesPos = GrandAxes.Position;
%             currentFiguPos = GrandFigu.Position;
            %currentBoxPos  = obj.textBox.Position;
            BoxDim = zeros(1, 4);
            BoxDim(1) = currentAxesPos(1) + (x - x0) * currentAxesPos(3) / (x1 - x0);
            BoxDim(2) = currentAxesPos(2) + (y - y0) * currentAxesPos(4) / (y1 - y0);
            BoxDim(3) = obj.defaultTextBoxWidth  * currentAxesPos(3)  / (x1 - x0);
            BoxDim(4) = obj.defaultTextBoxHeight * currentAxesPos(4)  / (y1 - y0);
            
            
            BoxDim(1:2) = BoxDim(1:2) - .5 * BoxDim(3:4);
            set( obj.textBox, 'position', BoxDim);
        end
        function addtextbox( obj, position )
            % add text-box if it is not already created ... 
            GrandAxes = obj.parent.parent.Axs;
            GrandFigu = obj.parent.parent.Fig;
            
            x0 = GrandAxes.XLim(1);
            x1 = GrandAxes.XLim(2); 

            y0 = GrandAxes.YLim(1); 
            y1 = GrandAxes.YLim(2);
            
            x = position(1); 
            y = position(2);
            %
            currentAxesPos = GrandAxes.Position;
%             currentFiguPos = GrandFigu.Position;
            BoxDim = zeros(1, 4);
            BoxDim(1) = currentAxesPos(1) + (x - x0) * currentAxesPos(3) / (x1 - x0);
            BoxDim(2) = currentAxesPos(2) + (y - y0) * currentAxesPos(4) / (y1 - y0);
            BoxDim(3) =  obj.defaultTextBoxWidth * currentAxesPos(3) / (x1 - x0);
            BoxDim(4) = obj.defaultTextBoxHeight * currentAxesPos(4) / (y1 - y0);
            
            % shift to the centroid
            BoxDim(1:2) = BoxDim(1:2) - .5 * BoxDim(3:4);
            obj.textBox = annotation( GrandFigu, ...
                'textbox', BoxDim, ...
                'visible', 'off', ...
                'pickableparts', 'none', ...
                'HorizontalAlignment', 'center', ...
                'verticalalignment', 'middle', ...
                obj.currentTextboxPropertyCell{:} );
            % revert back to the default axis limit, in cases this is not
            % done automatically 
            obj.parent.parent.aaxis( [x0, x1, y0, y1] );
        end
        function turn( obj, state )
            %
            if ~isempty( obj.rightLine ), set( obj.rightLine, 'visible', state ); end
            if ~isempty( obj.textBox   ), set( obj.textBox,   'visible', state ); end
            if ~isempty( obj.arrowhead ), set( obj.arrowhead, 'visible', state ); end
        end
        function setTextboxSize(obj, Width, Height)
            obj.defaultTextBoxWidth = Width;
            obj.defaultTextBoxHeight = Height;
        end
        function setText(obj, textcharstring, varargin )
            set( obj.textBox, 'string', textcharstring, varargin{:} );
        end
        function updateProperty( obj )
            % only update if they are defined
            if ~isempty( obj.rightLine )
                set( obj.rightLine, obj.CurrentPropertyCell{:} );
            end
            if ~isempty( obj.textBox )
                set( obj.textBox, obj.currentTextboxPropertyCell{:} );
            end
            if ~isempty( obj.arrowhead )
                set( obj.arrowhead, 'facecolor', obj.fillColor );
            end
            
        end
        function deleteObj( obj )
            % deletes all graphical elements, before deleting itself ... 
            if ~isempty( obj.rightLine )
                obj.rightLine.delete();
            end
            if ~isempty( obj.textBox )
                obj.textBox.delete();
            end
            if ~isempty( obj.arrowhead )
                obj.arrowhead.delete();
            end
            % deleting listeners
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
            % what happens is that after the obj is destroyed it will pass
            % its reference to other listeners, so that they may remove its
            % reference from their container
        end
        
        
        % these two methods allow a continual chain to be created ...
        
        % ----------------------------
        % singly-linked list ... to be deprecated!
        % -----------------------------
        
        function setAssociate( obj, associateObj )
            % we don't really care about 
            obj.associate = associateObj;
        end
        
        function associateObj = getAssociate( obj )
            associateObj = obj.associate;
        end
        
        % ----------------------------
        % doubly-linked list ... currently active
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
    methods(Hidden)
        function setDefaultProperty( obj )
            styleIsOfLine = false;
            switch obj.style
                case 'straight'
                    obj.drawhandle = @(START, END) obj.internalSetStraight( START, END );
                    styleIsOfLine = true;
                case 'straighttextbox' 
                    obj.drawhandle = @(START, END) obj.internalSetStraightTextBox( START, END );
                    styleIsOfLine = true;
                case 'doublestraighttextbox'
                    obj.drawhandle = @(START, END) obj.internalSetDoubleStraightTextBox( START, END );
                    styleIsOfLine = true;
                case 'singlearrow' 
                    obj.drawhandle = @(START, END) obj.internalSetSingleArrow( START, END );
                case 'doublearrow'
                    obj.drawhandle = @(START, END) obj.internalSetDoubleArrow( START, END );
                case 'singlearrowtextbox'
                    obj.drawhandle = @(START, END) obj.internalSetSingleArrowTextBox( START, END );
                case 'doublearrowtextbox'
                    obj.drawhandle = @(START, END) obj.internalSetDoubleArrowTextBox( START, END );
            end
            if styleIsOfLine
                % line style
                obj.setLineDefaultPropertyCell();
            else
                obj.setQuiverDefaultPropertyCell();
            end
            % set default textbox property ... 
            obj.setTextboxDefaultPropertyCell();
        end
        function setLineDefaultPropertyCell( obj )
            % By default (assume that the axes object uses 'normalized' as
            % the position metric )
            
            obj.lastPropertyCell = { ...
                'visible', 'off', ...
                'linestyle', '-', ...
                'linewidth', 1.2, ...
                'color', 'k', ...
                };
            % copy cell to current-property cell ... 
            obj.CurrentPropertyCell = obj.lastPropertyCell;
        end
        function setQuiverDefaultPropertyCell( obj )
            %
            obj.lastPropertyCell = { ...
                'visible', 'off', ...
                'linestyle', '-', ...
                'linewidth', 1.2, ...
                'color', 'k'};
            % copy cell to current-property cell ...
            obj.CurrentPropertyCell = obj.lastPropertyCell;
        end
        function setTextboxDefaultPropertyCell( obj )
            obj.lastTextboxPropertyCell = { ...
                'color', 'k', ...
                'interpreter', 'latex', ...
                'fontsize', 15, ...
                'EdgeColor', 'none', ...
                'BackgroundColor', 'w', ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle'};
            % copy cell to current-property cell ... 
            obj.currentTextboxPropertyCell = obj.lastTextboxPropertyCell;
        end
        function isLineSelected = Selected( obj, rect )
            % rect is a 4-element vector with elements: [xlower, ylower,
            % xupper, yupper]. Together, they correspond to the bottom
            % left and upper right corners of the box. 
            isLineSelected = false;
            % check that positions have been created ... 
            if isempty( obj.internalStartPosition ) || ...
                    isempty( obj.internalFinalPosition )
                % empty line, always return false
                return;
            end
            x0 = obj.internalStartPosition(1); 
            y0 = obj.internalStartPosition(2);
            
            x1 = obj.internalFinalPosition(1); 
            y1 = obj.internalFinalPosition(2);
%             isLineSelected = ...
%                 ( ...
%                 ( rect(1) <= x0 && x0 <= rect(3) ) && ...
%                 ( rect(2) <= y0 && y0 <= rect(4) ) ) || ...
%                 ( ...
%                 ( rect(1) <= x1 && x1 <= rect(3) ) && ...
%                 ( rect(2) <= y1 && y1 <= rect(4) ) );
            % actually, one can vectorize the above
            x = [x0, x1];
            y = [y0, y1];
            isLineSelected = any( ...
                ( rect(1) <= x & x <= rect(3) ) & ...
                ( rect(2) <= y & y <= rect(4) ) );
            if isLineSelected
                % notify that the current line is selected ... 
                notify( obj, 'selectedState' );
            end
        end
%         function isObjSelected = atomicSelect( obj, pos, offset )
%             isObjSelected = false;
%             % check that positions have been created ... 
%             if isempty( obj.internalStartPosition ) || ...
%                     isempty( obj.internalFinalPosition )
%                 % empty line, always return false
%                 return;
%             end
%             defaultoffset = .02;
%             if nargin > 2, defaultoffset = offset;end
%             x0 = obj.internalStartPosition(1); 
%             y0 = obj.internalStartPosition(2);
%             
%             x1 = obj.internalFinalPosition(1); 
%             y1 = obj.internalFinalPosition(2);
%             xmin = min( [x0, x1] ); xmax = max( [x0, x1] );
%             ymin = min( [y0, y1] ); ymax = max( [y0, y1] );
%             isObjSelected = ...
%                 xmin - defaultoffset <= pos(1) && pos(1) <= xmax + defaultoffset && ...
%                 ymin - defaultoffset <= pos(2) && pos(2) <= ymax + defaultoffset;
%             if isObjSelected, notify( obj, 'selectedState' ); end
%         end
        function isObjSelected = atomicSelect( obj, pos, offset )
            % the original 'atomicSelect' is problematic, since it allows a
            % relatively large selection area to be created which may
            % dominate other objects in the immediate vincity ... 
            
            % Given a line with certain orientation, one should project the
            % the point relative to the local coordinate
            % 
            %             . 
            isObjSelected = false; 
            if isempty( obj.internalStartPosition ) || ...
                    isempty( obj.internalFinalPosition )
                return;
            end
            defaultoffset = .01;
            if nargin > 2, defaultoffset = offset; end
            % define the norm now with a small scalar added to avoid
            % singular behavior 
            lengthOfLine = norm( obj.internalFinalPosition - obj.internalStartPosition ) + 1E-6;
            xdirection   = ( (obj.internalFinalPosition - obj.internalStartPosition )    + 1E-6 ) / lengthOfLine;
            ydirection   = [ -xdirection(2), +xdirection(1) ];
            % project the given point now
            tx = dot( pos - obj.internalStartPosition, xdirection );
            ty = dot( pos - obj.internalStartPosition, ydirection );
            isObjSelected = ...
                (-defaultoffset <= tx && tx <= lengthOfLine + defaultoffset) && ...
                (-defaultoffset <= ty && ty <= +defaultoffset );
            if isObjSelected, notify( obj, 'selectedState' ); end
        end
        function translate( obj, transVec )
            % translate the line with/without textbox according to the
            % translation vector 'transVec' ...
            
            % check that line is non-empty
            if isempty( obj.internalStartPosition ) || ...
                    isempty( obj.internalFinalPosition )
                return; 
            end
            % apply the translation (undecided whether to throw some
            % exceptions in cases that the line may move out-of-bound of
            % the canvas ...  )
            
            obj.internalStartPosition = obj.internalStartPosition + transVec;
            obj.internalFinalPosition = obj.internalFinalPosition + transVec;
            % update the position of the line if the line object is
            % available
            if ~isempty( obj.rightLine )
                % move now
                set( obj.rightLine, ...
                    'xdata', [ obj.internalStartPosition(1), obj.internalFinalPosition(1) ], ...
                    'ydata', [ obj.internalStartPosition(2), obj.internalFinalPosition(2) ]);
            end
            if ~isempty( obj.arrowhead )
                xdata = obj.arrowhead.XData + transVec(1);
                ydata = obj.arrowhead.YData + transVec(2);
                set( obj.arrowhead, 'xdata', xdata, 'ydata', ydata);
            end
            % translate the text-box if it exists
            if ~isempty( obj.textBox )
                % the translation is slightly different, since the textBox
                % uses a different distance metric. The procedure is as
                % follows: 
                %     first one needs to convert the current textbox
                %     position to the physical position
                %     
                %     secondly, superimpose the physical position with the
                %     translation vector
                
                %     finally,  convert the resulting physical position
                %     back to its local metric 
                % 
                % or equivalently, convert the translation vector to the
                % textbox's local metric, then superimpose ... 
                
                x0 = obj.parent.parent.Axs.XLim(1); 
                x1 = obj.parent.parent.Axs.XLim(2); 
                
                y0 = obj.parent.parent.Axs.YLim(1);
                y1 = obj.parent.parent.Axs.YLim(2);
                
                CurrentAxesPosition = obj.parent.parent.Axs.Position;
                % convert the translation vector to the local metric
                xlocal = ( transVec(1) ) * CurrentAxesPosition(3) / ( x1 - x0 );
                ylocal = ( transVec(2) ) * CurrentAxesPosition(4) / ( y1 - y0 );
                % get the current textbox' position
                CurrentTextBoxPosition = obj.textBox.Position;
                CurrentTextBoxPosition(1:2) = CurrentTextBoxPosition(1:2) + [xlocal, ylocal];
                set( obj.textBox, 'position', CurrentTextBoxPosition );
                
            end
        end
        function atomicTranslate( obj, transVec ), obj.translate( transVec ); end
    end
    methods(Access = private)
        function arrowheadcallback(obj, ~, ~)
            % a callback 
            assert( ...
                strcmpi( obj.arrowstyle, 'quiver' ) || ...
                strcmpi( obj.arrowstyle, 'patch'  ), ...
                'SchematicTools:Line:illegalkeyword', ...
                'arrow style must take the following values: ''quiver'' or ''patch''.');
        end
        function selectedStateCallback( obj, ~, ~ )
            % a call-back that responds to the selected state
           
            pos = .5 * (obj.internalStartPosition + obj.internalFinalPosition );
            obj.selectedTextBox.draw( 'start', pos, 'end', pos );
            obj.selectedTextBox.setText( 'selected', 'fontsize', 10, 'color', 'g');
        end
        function deselectedStateCallback( obj, ~, ~ )
            % simply turn-off the selectedTextbox 
            obj.selectedTextBox.turn( 'off' );
        end
    end
    methods
        [stringcell, datafile] = outputstream( obj );
    end
    methods(Hidden)
        % atomic - rotate and scale 
        atomicScale( obj, pivot, scale );
        atomicRotate( obj, pivot, angle);
        stacktop( obj );
        isSchematicContainedAnyText = schematicContainsText( obj );
    end
    methods(Access = private)
        internalSetStraight(obj, startPosition,  endPosition);                  % 
        internalSetSingleArrow( obj, startPosition, endPosition);               % 
        internalSetDoubleArrow( obj, startPosition, endPosition);               %
        internalSetStraightTextBox( obj, startPosition, endPosition);           % 
        internalSetDoubleStraightTextBox( obj, startPosition, endPosition);     %
        internalSetSingleArrowTextBox( obj, startPosition, endPosition);        %
        internalSetDoubleArrowTextBox( obj, startPosition, endPosition);        % 
    end
    methods(Static, Hidden)
        correctedKey = checkLineStyle( styleKey );
        colorKey     = checkColorSpec( somePropertyCell );
    end
end