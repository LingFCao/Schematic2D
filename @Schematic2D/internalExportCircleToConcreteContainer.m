function internalExportCircleToConcreteContainer( obj, ~, ~ )

if isempty( obj.previewCircle )
    % generate preview now! 
    obj.internalExportCircle();
end
if ~isempty( obj.previewCircle )
    obj.add( obj.previewCircle );
    obj.previewCircle.addSelectionAttribute();
    
    obj.previewCircle = [];
    
%     Schematic2D.staticModifyPropertyPanelCloseRequestFcn([], [], obj );
end
Schematic2D.staticModifyPropertyPanelCloseRequestFcn([], [], obj );
obj.useCustomName = false;