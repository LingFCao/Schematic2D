function internalExportText( obj, ~, ~ )
% convert the text buffer object to concrete schematic object whose
% properties are controlled by the 'propertyTexStruct' property.

% check that the 'plainTextSchematicObj' is non-empty
%
if ~isempty( obj.previewText ), obj.previewText.deleteObj(); obj.previewText = []; end

if ~isempty( obj.plainTextSchematicObj )
    % do not add to the concrete container yet.
    captureIsEnabled = obj.canvasEnabledCapture();
    if captureIsEnabled, obj.setEnableCapture( 'off' ); end
    p = SchematicLine( obj, obj.propertyTextStruct.style, ...
        'color', obj.propertyTextStruct.color );
    p.setTextboxSize( ...
        obj.propertyTextStruct.width, ...
        obj.propertyTextStruct.height );
    % set textbox property 
    p.setProperties( 'textbox', ...
        'interpreter', 'latex', ...
        'color',           obj.propertyTextStruct.textcolor, ...
        'backgroundcolor', obj.propertyTextStruct.backgroundcolor, ...
        'edgecolor',       obj.propertyTextStruct.edgecolor, ...
        'fontsize',        obj.propertyTextStruct.fontsize );
    p.draw( ...
        'start', obj.plainTextSchematicObj.internalStartPosition, ...
        'end',   obj.plainTextSchematicObj.internalFinalPosition );
    p.setText( obj.plainTextSchematicObj.textBox.String );
    
    if obj.useCustomName, p.name = obj.propertyTextStruct.name; end
    
    % save p to tthe 'previewText' property 
    obj.previewText = p;
    % disable guide
    obj.plainTextSchematicObj.turn( 'off' );
    if captureIsEnabled, obj.setEnableCapture( 'on' ); end
end
