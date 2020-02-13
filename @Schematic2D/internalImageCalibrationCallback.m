function internalImageCalibrationCallback( obj, ~, ~)

if obj.currentModeState ~= 7
    % revert the pointer back to what ever state it is in
    if obj.useInPrecision
        set( obj.parent.Fig, 'pointer', 'cross' );
    else
        set( obj.parent.Fig, 'pointer', 'arrow' );
    end
else
    if obj.isInCalibration
        % if it is in calibration, set the pointer type to 'crosshair'
        set( obj.parent.Fig, 'pointer', 'crosshair' );
        
        % also turn off the termination guide as well as reset the
        % termination point
        obj.terminationGuide.turn( 'off' );
        obj.imager.setTerminationPoint( [] );
    else
        % revert back to whatever pointer type 
        if obj.useInPrecision
            set( obj.parent.Fig, 'pointer', 'cross' );
        else
            set( obj.parent.Fig, 'pointer', 'arrow' );
        end
    end
end