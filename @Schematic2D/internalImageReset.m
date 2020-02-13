function internalImageReset( obj )

obj.imager.reset();
%  reset the calibration count and turn-off any anchor points
obj.calibrationcount                 = 0;
obj.isInCalibration              = false;
obj.imageSettingTerminationPoint = false;
for p = obj.calibrationGuide.getAll()
    p.turn( 'off' );
end
% turn off the termination anchor ... 
obj.terminationGuide.turn( 'off' );