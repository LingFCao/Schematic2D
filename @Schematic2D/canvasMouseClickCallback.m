function canvasMouseClickCallback( obj, ~, ~ )
% 
% obtain the current 
ClickPosition = obj.parent.Axs.CurrentPoint;
% ignore the rest of the 2-by-3 matrix
ClickPosition = ClickPosition(1, 1:2);
if obj.useInPrecision
    ClickPosition = obj.inprecision * floor( ClickPosition / obj.inprecision );
end

switch obj.currentModeState
    case 1  % corresponds to 'normal' mode
        % upon clicked, one simply adds a guide point to the canvas
        %
        obj.addGuide( ClickPosition );
    case 2  % corresponds to 'selection' mode
        % try to include a toggle, so that one can avoid performing the
        % select operation if we are only interested in saving the figure
        obj.selectionAddAnchor( ClickPosition );
        if obj.selectionClickCount == 2
            X = [obj.FirstAnchorPosition.', obj.FinalAnchorPosition.'];
            x0 = min( X(1,:) ); y0 = min( X(2, : ) );
            x1 = max( X(1,:) ); y1 = max( X(2, : ) );
            obj.select( [x0, y0, x1, y1] );
            % make a copy of the captured selection 
            obj.internalCapturedSelection = [x0, y0, x1, y1];
            notify( obj, 'DeactivateSelectionLine' );
        end
    case 3  % corresponds to 'text' mode
        % immediate throw the contexture window to the front and update the
        % text-box 
%         obj.internalTextReset();
        obj.internalTextBringContexturePanel( ClickPosition );
    case 4  % corresponds to 'arrowtext' mode
%         obj.internalTextReset();
        obj.selectionAddAnchor( ClickPosition );
        if obj.selectionClickCount == 2
            obj.internalTextBringContexturePanel( obj.FirstAnchorPosition );
        end
    case 5
        % nothing else to do
        obj.selectionAddAnchor( ClickPosition );
    case 6
        % add the first anchor
        obj.selectionAddAnchor( ClickPosition );
        if obj.selectionClickCount == 1
            % release any previously held holder
            obj.atomicRealTimeAnchor = ClickPosition;
            obj.atomicRelease();
            % make an atomic check to identify selected objects 
            obj.atomicSelect( ClickPosition );
        else
            % notify that the translation has ended
            notify( obj, 'atomicTranslationEnd' );   % this event only affects 'open' schematicshape objects
            notify( obj, 'deselectedObjects'    );
            % reset the selected holder 
            obj.atomicSelectedObj = [];
            
            % make sure that the stack order is preserved ... 
            %obj.internalCorrectStackOrder();
        end
    case 7
        % when we are in this mode
        
        % check if we are calibration mode
        if obj.isInCalibration 
            f = obj.calibrationcount;
            % f is the current calibration count
            % f = 1,2,3,4,0
            f = mod( f + 1, 5 );
            if f ~= 0                
                c = obj.calibrationGuide.GetObjRef( f );
                c.setCircleGeometry( ClickPosition, .005, 0, 3 * pi / 2 );
                c.draw();
                obj.imager.calibrate( ClickPosition, f );
            else
                % reset all of the points
                for p = obj.calibrationGuide.getAll()
                    p.turn( 'off' );
                end
            end
            
            obj.calibrationcount = f;
            if f == 4, obj.isInCalibration = false;end
        else
            % in data mode, check if we are currently setting the
            % termination point on the curve
            if obj.imageSettingTerminationPoint
                % once clicked we place the marker to the clicked position
                % and add the termination point to the imager
                obj.terminationGuide.setCircleGeometry( ClickPosition, ...
                    .0025, 0, 2 * pi );
                obj.terminationGuide.draw();
                obj.imager.setTerminationPoint( ClickPosition );
                
                % once this is done, we are no longer in this mode, so
                % disable it now
                obj.imageSettingTerminationPoint = false;
            else
                % note here that the guide will be used
                obj.addGuide( ClickPosition );
                obj.imager.addpoint( ClickPosition );
            end
        end
end
