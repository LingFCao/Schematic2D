function staticModifyPropertyPanelCloseRequestFcn( ~, ~, canvas )

if strcmpi( canvas.currentMode, 'normal' )
    if ~isempty( canvas.previewShape ), canvas.previewShape.turn( 'off' ); end
elseif strcmpi( canvas.currentMode, 'text' )
    if ~isempty( canvas.previewText ), canvas.previewText.turn( 'off' ); end
%     if ~isempty( canvas.plainTextSchematicObj )
%         canvas.plainTextSchematicObj.turn( 'on' );
%     end
elseif strcmpi( canvas.currentMode, 'arrowtext' )
    if ~isempty( canvas.previewArrowText ), canvas.previewArrowText.turn( 'off' ); end
%     if ~isempty( canvas.arrowTextSchematicObj )
%         canvas.arrowTextSchematicObj.turn( 'on' ); 
%     end
end

set( canvas.propertypanelwindow, 'visible', 'off' );