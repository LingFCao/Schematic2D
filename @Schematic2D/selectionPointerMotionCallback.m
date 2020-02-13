function selectionPointerMotionCallback( obj, ~, ~)
% 
dispCoord = obj.parent.Axs.CurrentPoint(1, 1:2);
% store 'dispCoord' to the zoom anchor
obj.currentZoomAnchor = dispCoord;

set( obj.CoordinateDisplay, 'string', [num2str(dispCoord(1), '%.4f'), ',', num2str(dispCoord(2), '%.4f')]);
if obj.currentModeState == 2
    % only draw if the current selection counter is 1
    if obj.selectionClickCount == 1
        % obtain the start position 
        startposition = obj.FirstAnchorPosition;
        currentposition = obj.parent.Axs.CurrentPoint(1,1:2);
        p1 = startposition;
        p2 = [startposition(1), currentposition(2)];
        p3 = currentposition;
        p4 = [currentposition(1), startposition(2)];
        obj.bline01.draw( 'start', p1, 'end', p2 );
        obj.bline02.draw( 'start', p2, 'end', p3 );
        obj.bline03.draw( 'start', p3, 'end', p4 );
        obj.bline04.draw( 'start', p4, 'end', p1 );
    end
elseif obj.currentModeState == 4
    if obj.selectionClickCount == 1
        obj.arrowTextSchematicObj.draw( ...
            'start', obj.FirstAnchorPosition, ...
            'end',   obj.parent.Axs.CurrentPoint(1,1:2), ...
            'arrowscale', .075);
    end
elseif obj.currentModeState == 5
    if obj.selectionClickCount == 1
        r = norm( obj.parent.Axs.CurrentPoint(1, 1:2) - obj.FirstAnchorPosition );
        newsamplesize = floor( 2 * pi * r / .01 );
        obj.guideCircle.setSamplingSize( newsamplesize );
        % check sample size 
        obj.guideCircle.setCircleGeometry( ...
            obj.FirstAnchorPosition, ...
            r, ...
            0, ...
            2 * pi );
        obj.guideCircle.draw();
        % also update the property struct ... 
        obj.propertyCircleStruct.radius = r;
    end
elseif obj.currentModeState == 6
    % this is the atomic translation ... 
    eps    = .001;
    if ~(~isempty( obj.atomicSelectedObj ) && obj.atomicSelectedObj.isvalid), return; end
    if obj.selectionClickCount == 1
        currentPoint = obj.parent.Axs.CurrentPoint(1, 1:2);
        transVec = currentPoint - obj.atomicRealTimeAnchor;
        if norm( transVec ) > eps
            % we store the current point to the realtimeanchor property 
            obj.atomicRealTimeAnchor = currentPoint;
            obj.atomicSelectedObj.atomicTranslate( transVec );
            notify(obj,'deselectedObjects');
            
        end
        
    end
end