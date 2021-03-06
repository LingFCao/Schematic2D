function internalImageInitialize( obj )
% initialize properties associated with the image mode of the canvas ...

obj.imager = SchematicImageProcessor( obj );
obj.calibrationlistener = addlistener( obj, 'isInCalibration', 'PostSet', ...
    @obj.internalImageCalibrationCallback);
% let's create a floating text to help guide the user
obj.calibrationGuide = GeneralManager();

EnabledCapture = obj.canvasEnabledCapture();
if EnabledCapture, obj.setEnableCapture( 'off' ); end
% create the guides
p = SchematicCircle(obj, 'arc', 'color', 'b', 'linestyle', '-'); p.setSamplingSize( 30 );
obj.calibrationGuide.add( p );
q = SchematicCircle(obj, 'arc', 'color', 'k', 'linestyle', '-'); q.setSamplingSize( 30 );
obj.calibrationGuide.add( q );
p = SchematicCircle(obj, 'arc', 'color', 'r', 'linestyle', '-'); p.setSamplingSize( 30 );
obj.calibrationGuide.add( p );
p = SchematicCircle(obj, 'arc', 'color', 'm', 'linestyle', '-'); p.setSamplingSize( 30 );
obj.calibrationGuide.add( p );

% set the termination guide
obj.terminationGuide = SchematicCircle( obj, 'circle');
obj.terminationGuide.fillCircle = true;
obj.terminationGuide.setFillColor( 'g' );
obj.terminationGuide.setSamplingSize( 30 );

if EnabledCapture, obj.setEnableCapture( 'on' ); end

obj.imageSavingModeUI = uicontrol( ...
    obj.parent.Fig, ...
    'style', 'text', ...
    'units', 'normalized', ...
    'position', [.0052, .955, .088, .02], ...
    'backgroundcolor', [1.0, .0, .0], ...
    'fontsize', 10, ...
    'ForegroundColor', [.8, .8, .8], ...
    'string', 'manual', ...
    'visible', 'off');
% create the listener
obj.imageSavingModeListener = addlistener( obj, 'saveAutoGeneratedData', ...
    'PostSet', @obj.internalImageSavingModeUICallback);

% okay let's create the custom pointer type! 
obj.customPointerMatrix = Schematic2D.staticgetcustompointer();

% add an listener for setting the termination point ...
obj.terminationPointPlacementListener = ...
    addlistener(obj, 'imageSettingTerminationPoint', 'PostSet', ...
    @obj.internalImageTerminationFlagCallback);
