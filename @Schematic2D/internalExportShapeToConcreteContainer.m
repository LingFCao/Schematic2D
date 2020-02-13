function internalExportShapeToConcreteContainer( obj, ~, ~ )

% first we check if the place holder exists
if isempty( obj.previewShape )
    % generate the preview now! 
    obj.internalExportShape();
end
% there may be a chance that it still doens't exist ...
if ~isempty( obj.previewShape )
    obj.add( obj.previewShape );
    obj.previewShape.addSelectionAttribute();
    if isa( obj.previewShape, 'SchematicShape' )
        obj.previewShape.addAtomicTranslationListener();
    end
    % destroy the reference to the current holder now (note this will not
    % destroy the shape since canvas also holds a reference to it
    obj.previewShape = [];
    
%     Schematic2D.staticModifyPropertyPanelCloseRequestFcn([], [], obj );
    
end
Schematic2D.staticModifyPropertyPanelCloseRequestFcn([], [], obj );
obj.useCustomName = false;