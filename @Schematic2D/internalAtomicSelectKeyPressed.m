function internalAtomicSelectKeyPressed( obj, keypressed )

if isempty( obj.atomicSelectedObj ) || ~obj.atomicSelectedObj.isvalid, return; end
dphi = 2 * pi / obj.MinimumNumberOfTraversals;
dlam =    10  / obj.MinimumNumberOfTraversals;
% if current click counter is 1, use the
% 'atomicRealTimeAnchor' as pivot, else use
% 'FinalAnchorPosition' ...
if obj.selectionClickCount == 1
    pivot = obj.atomicRealTimeAnchor;
else
    pivot = obj.FinalAnchorPosition;
end
mapref = obj.keyMap;
switch keypressed
    case mapref.rotateAntiClockWiseOrScaleDown
        % counter clockwise rotation and scale reduction ...
        if obj.isRotating
            obj.atomicSelectedObj.atomicRotate( pivot, dphi );
        else
            % scaling reduction
            obj.atomicSelectedObj.atomicScale(  pivot, 1 - dlam );
            %obj.currentScaling = max( obj.currentScaling - dlam,  0);
        end
        
    case mapref.rotateClockWiseOrScaleUp
        if obj.isRotating
            obj.atomicSelectedObj.atomicRotate( pivot, -dphi );
        else
            % scaling increment ... 
            obj.atomicSelectedObj.atomicScale( pivot, 1 + dlam );
            %obj.currentScaling = obj.currentScaling + dlam;
        end
        
    case mapref.toggleBetweenRotOrScale
        % toggles rotating and scaling mode ... 
        obj.isRotating = ~obj.isRotating;
        
    case mapref.deleteSelectedObject
        % delete the selected obj ... 
        
        notify( obj, 'deselectedObjects' );
        obj.atomicSelectedObj.deleteObj();
        obj.lastAddedSchematic = obj.schematicContainer.getLastRef();
end