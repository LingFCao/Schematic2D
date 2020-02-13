function internalExportTextToConcreteContainer( obj, ~, ~ )
% first we check if the place holder exists
if isempty( obj.previewText )
    % generate the preview now! 
    obj.internalExportText();
end
% there may be a chance that it still doens't exist ...
if ~isempty( obj.previewText )
    obj.add( obj.previewText );
    obj.previewText.addSelectionAttribute();
    % destroy the reference to the current holder now (note this will not
    % destroy the shape since canvas also holds a reference to it in the
    % relevant container 
    obj.previewText = [];
    
%     Schematic2D.staticModifyPropertyPanelCloseRequestFcn([], [], obj );
end
Schematic2D.staticModifyPropertyPanelCloseRequestFcn([], [], obj );
obj.useCustomName = false;