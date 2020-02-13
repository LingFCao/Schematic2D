function internalImageTerminationFlagCallback( obj, ~, ~ )
% 
if obj.currentModeState ~= 7
    % revert the pointer back to what ever state it is in
    if obj.useInPrecision
        set( obj.parent.Fig, 'pointer', 'cross' );
    else
        set( obj.parent.Fig, 'pointer', 'arrow' );
    end
else
    % make sure this callback is not reached during calibration 
    if obj.imageSettingTerminationPoint
        % currently we are setting the termination point
        set( obj.parent.Fig, 'pointer', 'custom', ...
            'PointerShapeCData', obj.customPointerMatrix, ...
            'PointerShapeHotSpot', [16, 16]); % modify this to [8,8] for a 16-by-16 pointers
    else
        % revert back to whatever pointer type 
        if obj.useInPrecision
            set( obj.parent.Fig, 'pointer', 'cross' );
        else
            set( obj.parent.Fig, 'pointer', 'arrow' );
        end
    end
end