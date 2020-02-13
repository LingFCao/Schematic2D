function internalExportArrowTextToConcreteContainer( obj, ~, ~ )
% first we check if the place holder exists and generate it if not ...
if isempty( obj.previewText )
    % generate the preview now! 
    obj.internalExportArrowText();
end
% there may be a chance that it still doens't exist ...
if ~isempty( obj.previewArrowText )
    obj.add( obj.previewArrowText );
    obj.previewArrowText.addSelectionAttribute();
    % destroy the reference to the current holder now (note this will not
    % destroy the shape since canvas also holds a reference to it in the
    % relevant container 
    obj.previewArrowText = [];
    
    % set the visible property to off, 
%     Schematic2D.staticModifyPropertyPanelCloseRequestFcn([], [], obj );
    if ~isempty( obj.arrowTextSchematicObj )
        obj.arrowTextSchematicObj.turn( 'off' );
    end
end
Schematic2D.staticModifyPropertyPanelCloseRequestFcn([], [], obj );
obj.useCustomName = false;