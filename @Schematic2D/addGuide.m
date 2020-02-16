function addGuide( obj, guideCoordinate )
% manually add a guide point on the canvas. 

ClickPosition = guideCoordinate;
if ~isempty( obj.lastCreatedPoint )
    if obj.lastCreatedPoint.isvalid
        if obj.xlock
            ClickPosition(1) = obj.lastCreatedPoint.position(1);
        end
        if obj.ylock
            ClickPosition(2) = obj.lastCreatedPoint.position(2);
        end
    end
end

currentCaptureStateIsOn = obj.EnableCapture;
% disable the current capture state ...
if currentCaptureStateIsOn, obj.setEnableCapture( 'off' ); end

%xlim = obj.parent.Axs.XLim;
%ylim = obj.parent.Axs.YLim;
% those values will be used instead to correct the zoom behaviour when adding points while zoom is active
xlim = obj.archivedXLim;
ylim = obj.archivedYLim;


pointIsInCanvas = ...
    ( xlim(1) <= ClickPosition(1) && ClickPosition(1) <= xlim(2) ) && ...
    ( ylim(1) <= ClickPosition(2) && ClickPosition(2) <= ylim(2) );
MaxCanvasSize = max( [diff( xlim ), diff( ylim ) ] );
if pointIsInCanvas
    obj.ClickCounter = obj.ClickCounter + 1;
    GuideRadius = obj.pointPercentageOfAxes * MaxCanvasSize;
    pointToDraw = SchematicCircle( obj, 'circle', 'Color', 'r', 'linewidth', .01);
    pointToDraw.fillCircle = false;
    pointToDraw.setFillColor( obj.pointColor );
    % set geometry property: 
    pointToDraw.setCircleGeometry( ClickPosition, GuideRadius, 0, 2 * pi );
    % draw now
    pointToDraw.draw();
    % create the text-box
    texttobedisplayed = SchematicLine( obj, 'straighttextbox', 'visible', 'off', 'color', 'none');
    % reduce the size of the text-box, and set it to the left side
    texttobedisplayed.setTextboxSize( .01, .01 );
    texttobedisplayed.setProperties('textbox', 'backgroundcolor', 'none', ...
        'visible', 'off', 'edgecolor', 'none', ...
        'horizontalalignment', 'center', ...
        'verticalalignment'  , 'middle');
    offset = [-1.5E-2, 0];
    texttobedisplayed.draw('start', ClickPosition + offset, 'end', ClickPosition);
    if obj.EnableNumericLabelOnGuidePoint
        % only set visible, if value is true
        texttobedisplayed.turn( 'on' );
        texttobedisplayed.setText( num2str( obj.ClickCounter ), 'fontsize', 10, 'Color', 'b' );
    else
        texttobedisplayed.turn( 'off' );
    end
    obj.lastCreatedPoint = pointToDraw;
    obj.lastCreatedPointText = texttobedisplayed;
    % add to the container
    obj.ClickedPointContainer.add( pointToDraw );
    obj.ClickedPointTextContainer.add( texttobedisplayed ); 
    
    if obj.PrintGuidePointToCommand
        displayClickedCoordinate( ClickPosition );
    end
    
    % reset back to the original limit if it is being done so already
    xlim = obj.parent.Axs.XLim;
    ylim = obj.parent.Axs.YLim;
    obj.parent.aaxis( [xlim, ylim] );
else
    warning( ...
        'SchematicTools:Canvas:outOfBoundAccess', ...
        'guide point out of bound!' );
end
if currentCaptureStateIsOn, obj.setEnableCapture( 'on' ); end

function displayClickedCoordinate( position )
% 
fprintf( '[%+.4f, %+.4f] \n', position );
