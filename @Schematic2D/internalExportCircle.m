function internalExportCircle( obj, ~, ~)

if ~isempty( obj.previewCircle ), obj.previewCircle.deleteObj(); obj.previewCircle = []; end
if isempty( obj.guideCircle.position ), return; end

if ~isempty( obj.guideCircle )
    captureIsEnabled = obj.canvasEnabledCapture();
    if captureIsEnabled, obj.setEnableCapture( 'off' ); end
    p = SchematicCircle( obj, ...
        obj.propertyCircleStruct.style, ...
        'color',     obj.propertyCircleStruct.color, ...
        'linewidth', obj.propertyCircleStruct.linewidth, ...
        'linestyle', obj.propertyCircleStruct.linestyle );
    p.fillCircle = obj.propertyCircleStruct.fillShape;
    p.setCircleGeometry( ...
        obj.guideCircle.position, ...
        obj.propertyCircleStruct.radius, ...
        obj.propertyCircleStruct.ipolar, ...
        obj.propertyCircleStruct.fpolar );
    p.draw();
    if obj.useCustomName, p.name = obj.propertyCircleStruct.name; end
    
    % save p 
    obj.previewCircle = p;
    % disable guide 
    obj.guideCircle.turn( 'off' );
    if captureIsEnabled, obj.setEnableCapture( 'on' ); end
    
end
