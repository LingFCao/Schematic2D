function internalCircleInitialization( obj )
% 

captureIsEnabled = obj.canvasEnabledCapture();
if captureIsEnabled, obj.setEnableCapture( 'off' ); end

% we simply create a 'guideCircle' ...
obj.guideCircle = SchematicCircle( obj, 'circle', ...
    'color', 'k', ...
    'linewidth', 1.2, ...
    'linestyle', '-');

if captureIsEnabled, obj.setEnableCapture( 'on' ); end