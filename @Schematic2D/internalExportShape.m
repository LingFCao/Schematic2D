function internalExportShape( obj, ~, ~ )
% convert the shape buffer object to concrete schematic object whose
% properties are controlled by the 'propertyShapeStruct' property.

if ~isempty( obj.previewShape ), obj.previewShape.deleteObj(); obj.previewShape = []; end

% check if current holder is empty 
if ~isempty( obj.tmpShapeHolder )  && isa( obj.tmpShapeHolder, 'SchematicShape' )
    % also check if current holder holds any data
    captureIsEnabled = obj.canvasEnabledCapture();
    if captureIsEnabled, obj.setEnableCapture( 'off' ); end
    if ~( isempty( obj.tmpShapeHolder.xRawData ) || isempty( obj.tmpShapeHolder.yRawData ) )
        % create the concrete schematicShape object
        p = SchematicShape( obj, obj.propertyShapeStruct.style, ...
            'color',     obj.propertyShapeStruct.color, ...
            'linewidth', obj.propertyShapeStruct.linewidth, ...
            'linestyle', obj.propertyShapeStruct.linestyle );
        p.fillShape = obj.propertyShapeStruct.fillShape;
        p.setFillColor( obj.propertyShapeStruct.fillColor );
        %
        p.getData( obj.tmpShapeHolder.xRawData, obj.tmpShapeHolder.yRawData );
        p.draw();
        % set the alpha data ... 
        p.setAlphaData( obj.propertyShapeStruct.facealpha );
        if obj.useCustomName, p.name = obj.propertyShapeStruct.name; end
        % place 'p' to the special container 
        obj.previewShape = p;
    end
    if captureIsEnabled, obj.setEnableCapture( 'on' ); end
end
if ~isempty( obj.tmpShapeHolder ) && isa( obj.tmpShapeHolder, 'SchematicLine' )
    % also check if current holder holds any data
    captureIsEnabled = obj.canvasEnabledCapture();
    if captureIsEnabled, obj.setEnableCapture( 'off' ); end
    p = SchematicLine( obj, 'straight', ...
        'color', obj.propertyShapeStruct.color, ...
        'linewidth', obj.propertyShapeStruct.linewidth, ...
        'linestyle', obj.propertyShapeStruct.linestyle );
    p.draw(  ...
        'start', obj.tmpShapeHolder.internalStartPosition, ...
        'end', obj.tmpShapeHolder.internalFinalPosition );
    if obj.useCustomName, p.name = obj.propertyShapeStruct.name; end
    
    obj.previewShape = p;
    if captureIsEnabled, obj.setEnableCapture( 'on' ); end
end
