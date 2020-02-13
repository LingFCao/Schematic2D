classdef SchematicImageProcessor < handle
    % image processing class - provides methods to process image including
    % methods to automate curve tracing and image-digitizing
    % 
    % (users don't normally interact with this class unless they want to
    % fine-tune its behaviour)
    properties(Hidden)
        maxIteration       =  700;
    end
    properties(SetAccess = private, Hidden)
        parent;
    end
    properties(SetAccess = private, Hidden)
        % rgb image (double)
        rgbImage;
        % 
        rowNumb;
        colNumb;
        % traversal steps
        Step                =   4;
        
        % pixel bounding-box size
        boundingSize        =   10;
        pointhelper         =   [];
        
        % pointcontainer 
        pixelBin            =   [];
        coordBin            =   [];
        
        % rgb guide to fine-tune the initial capture ...
        guideRGB            =   [];
        
        % termination criterion
        withinpixels        =    5;
        
        %
        terminationPoint    =   [];
        
        % direction
        direction           = 'east';
        
        % type of axis('linear', 'semilogx', 'semilogy', 'loglog')
        axisType            = 'linear';
        conversionHandle    = [];
    end
    
    properties(Hidden)
        % property window
        xlowerbound;
        xupperbound;   
        ylowerbound;
        yupperbound;
        
        % a simple flag to check if the current image is calibrated
        isCalibrated = false;
        
        % these are the anchor points, which need to be set during
        % calibration
        x1;
        x2;
        y1;
        y2;
        %
        evaluationPoint;
        
        % data container
        lastRowAdded   = 0;
        dataContainer;
    end
    properties(SetAccess = private)
        imagepropertypanel;
        statictextcompts;
        editabletextcompts;
        editablelisteners;
        curvehandle;
        imagehandle;
        imageIsDisable      = true;
    end
    
    methods 
        function obj = SchematicImageProcessor( Parent )
            assert( isa( Parent, 'Schematic2D' ), ...
                'SchematicTools:imageProcesssor:illegaltype', ...
                'The supplied input must be a valid instance of the ''Schematic2D'' class!' );
            obj.parent      = Parent;
            % create helper ... 
            obj.pointhelper = SchematicImageProcessorHelper( obj );
            
            % initialize the internal variables
            obj.internalInitialize();
            obj.dataContainer = double.empty(0,2);
            
            % set the initial conversion handle to linear
            obj.conversionHandle = @obj.linearConvert;
            
        end
        function readImageFromFilename( obj, filename )
            [f, map] = imread( filename );
            if ~isempty( map )
                % convert the map to rgb array 
                f = ind2rgb(f, map);
            end
            % assume 8-bit depth
            f = double( f ) / 255;
            obj.rgbImage = f;
            [ ...
                obj.rowNumb, ...
                obj.colNumb, ~] = size( f );
            % now create an image
            if ~isempty( obj.imagehandle )
                set( obj.imagehandle, 'cdata', obj.rgbImage);
            else
                obj.imagehandle = image( ...
                    obj.parent.parent.Axs, ...
                    obj.rgbImage, 'visible', 'off' );
            end
            obj.imageIsDisable = false;
        end
        function rgbstr = readRGBnormalized( obj, x, y )
             % read the r, g, b values provided that x and y are normalized
             % coordinates
             f = obj.rgbImage;
             rownumb = obj.rowNumb; 
             colnumb = obj.colNumb;
             rowindx = rownumb - floor( (rownumb - 1) * y );
             colindx = 1       + floor( (colnumb - 1) * x );
             rgbstr.r = f(rowindx, colindx, 1);
             rgbstr.g = f(rowindx, colindx, 2); 
             rgbstr.b = f(rowindx, colindx, 3);
        end
        function calibrate(obj, calipoint, direction)
            % the calibration process requires 4 clicks to establish the
            % axes. Here 'direction' can take the values 1,2, 3 and 4. For
            % the physical bounds, let user tweak them using the property
            % panel
            switch direction
                case 1
                    % start from the lower x
                    obj.x1 = calipoint;
                case 2
                    obj.x2 = calipoint;
                case 3
                    obj.y1 = calipoint;
                case 4
                    obj.y2 = calipoint;
            end
            obj.isCalibrated = ...
                ~isempty( obj.x1 ) && ...
                ~isempty( obj.x2 ) && ...
                ~isempty( obj.y1 ) && ...
                ~isempty( obj.y2 );
        end
        function setEvaluationPoint(obj, x)
            % we need to normalize x with respect to the current axes
%             xlim = obj.parent.parent.Axs.XLim;
%             ylim = obj.parent.parent.Axs.YLim;
            xlim = obj.parent.archivedXLim;
            ylim = obj.parent.archivedYLim;
            x1_   = x(1);
            y1_   = x(2);
            x1_   = ( x1_ - xlim(1) ) / diff( xlim );
            y1_   = ( y1_ - ylim(1) ) / diff( ylim );
            % store the evaluation point
            obj.evaluationPoint = [x1_, y1_];
        end
        
        function automatetrace( obj )
            % automate the trace provided that the evaluation point is
            % non-empty and the graph is properly calibrated ...
            if ~isempty( obj.evaluationPoint ) && obj.isCalibrated 
                % we don't want those values - we want the archived XLim
                % and YLim!
%                 xlim = obj.parent.parent.Axs.XLim;
%                 ylim = obj.parent.parent.Axs.YLim;
                xlim = obj.parent.archivedXLim;
                ylim = obj.parent.archivedYLim;
                X    = [];
                if ~isempty( obj.terminationPoint )
                    % X should be appropriately normalized
                    X = obj.terminationPoint;
                    X(1) = (X(1) - xlim(1)) / diff( xlim );
                    X(2) = (X(2) - ylim(1)) / diff( ylim );
                end
                % apply the internal method ...
                obj.iterateimagewithoutsmoothing( ...
                    obj.evaluationPoint, ...
                    obj.direction, X);
                % once we have a set of pixel coordinates, we then
                % transform them to the actual coordinates and update the
                % trace-line ...
                rowIndex = obj.pixelBin(:, 1);
                colIndex = obj.pixelBin(:, 2);
                % this is the normalized x 
                x        = (colIndex - 1)            / ( obj.colNumb - 1);
                y        = (obj.rowNumb - rowIndex ) / ( obj.rowNumb - 1); 
                % convert the normalized coordinates back to the axes'
                x        = xlim(1) + diff( xlim ) * x;
                y        = ylim(1) + diff( ylim ) * y;
                % convert [x, y] to physical units and store them to the
                % coordinate bin ... 
                [xa, ya] = obj.conversionHandle( x, y );
                obj.coordBin = [xa, ya];
                % set the visible property to true
                if ~isempty( obj.curvehandle )
                    set( obj.curvehandle, 'xdata', x, 'ydata', y, 'visible', 'on' );
                else
                    obj.curvehandle = plot( ...
                        obj.parent.parent.Axs, ...
                        x, y, '-g', 'linewidth', 1.2, 'visible', 'on', 'pickableparts', 'none');
                end
                
            end
        end
        function reset( obj )
            % reset the object
            obj.isCalibrated     = false;
            obj.guideRGB         = [];
            obj.coordBin         = [];
            obj.lastRowAdded     =  0;
            obj.terminationPoint = [];
            if ~isempty( obj.imagehandle ), set( obj.imagehandle, 'visible', 'off' ); end
            if ~isempty( obj.curvehandle ), set( obj.curvehandle, 'visible', 'off' ); end
        end
        
        function addpoint(obj, point)
            % check if it is calibrated ... 
            if ~obj.isCalibrated
%                 warning( ...
%                     'SchematicTools:imageProcessor:calibration',...
%                     'image has not been calibrated!');
                fprintf( ['note: image has not yet calibrated.\n', ...
                    ' Any data points produced while the image is', ...
                    ' uncalibrated will not be added to file\n' ]);
                return;
            end
            [x, y] = obj.conversionHandle(point(1), point(2));
            obj.lastRowAdded = obj.lastRowAdded + 1;
            obj.dataContainer( obj.lastRowAdded, :) = [x, y];
            
            % also sets the evaluation point
            obj.setEvaluationPoint( point );
        end
        
        function setTerminationPoint( obj, termPt)
            % set termination point
            obj.terminationPoint = termPt;
        end
        function flush( obj, key )
            switch key 
                case 'last'
                    obj.deletelastpoint();
                case 'all'
                    obj.deleteallpoints();
            end
        end
        
        function deletelastpoint( obj )
            % we don't need to flush the entire container 
            obj.lastRowAdded = max( obj.lastRowAdded - 1, 0 );
        end
        function deleteallpoints( obj )
            obj.lastRowAdded = 0;
        end
        
        function writeToOutputFile( obj, filename, writeAutoTracedData)
            if writeAutoTracedData
                % store the data obtained by the auto-generated data
                if ~isempty( obj.coordBin )
                    dlmwrite(filename, obj.coordBin );
                end
            else
                % write 'dataContainer'
                if obj.lastRowAdded > 0
                    dlmwrite( filename, obj.dataContainer(1 : obj.lastRowAdded, :) );
                end
            end
            
        end
        
    end
    methods(Hidden)
        pixelbin = iterateimagewithoutsmoothing( obj, ...
            startposition, initialdirection, endposition );
        internalbringuppropertypanel( obj );
    end
    methods(Access = private)
        internalInitialize( obj );
        iterationcallback(   obj, ~, ~, q );
        guidergbcallback(    obj, ~, ~, q );
        xlowerboundcallback( obj, ~, ~, q );
        xupperboundcallback( obj, ~, ~, q );
        ylowerboundcallback( obj, ~, ~, q );
        yupperboundcallback( obj, ~, ~, q );
        directioncallback(   obj, ~, ~, q );
        axisTypeCallback(    obj, ~, ~, q );
    end
    methods(Access = private)
        [xp, yp] = linearConvert(   obj, xr, yr         );
        [xp, yp] = logotherConvert( obj, xr, yr, otherid);
    end
    methods(Static, Hidden)
        [I, J] = getDirectionalIndices( i, j, imax, jmax, s, direction);
        [I, J] = getpixelind( tx, ty, i, j, imax, jmax, s);
    end
    
end