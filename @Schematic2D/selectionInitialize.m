function selectionInitialize( obj )
% create the bounding line 

captureIsEnabled = obj.canvasEnabledCapture();
if captureIsEnabled, obj.setEnableCapture( 'off' ); end

obj.bline01 = SchematicLine( obj, 'straight', 'color', 'm', 'linestyle', '-.', 'linewidth', .6 );
obj.bline02 = SchematicLine( obj, 'straight', 'color', 'm', 'linestyle', '-.', 'linewidth', .6 );
obj.bline03 = SchematicLine( obj, 'straight', 'color', 'm', 'linestyle', '-.', 'linewidth', .6 );
obj.bline04 = SchematicLine( obj, 'straight', 'color', 'm', 'linestyle', '-.', 'linewidth', .6 );

if captureIsEnabled, obj.setEnableCapture( 'on' ); end

% create the listener for the 'DeactivateSelectionLine' event ... 
obj.deactiveSelectionLineListener = addlistener(obj, 'DeactivateSelectionLine', @obj.deactivateSelectionLineCallback );
obj.selectionStepListener         = addlistener(obj, 'MinimumNumberOfTraversals', 'PostSet',  @obj.internalSetTranslationStep );
obj.internalSetTranslationStep();