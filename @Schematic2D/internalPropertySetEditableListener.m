function internalPropertySetEditableListener( obj )
% destroy and rebuild the listeners for the various ui components
if obj.propertypaneleditablecomponents.isContainerEmpty(), return; end

if ~obj.propertycomptlisteners.isContainerEmpty()
    p = obj.propertycomptlisteners.getAll(); 
    obj.propertycomptlisteners.reset();
    p.delete();
end
[~, flag] = obj.internalPropertyReturnCurrentPropertyName();
count = 0;
for k = 1 : length( flag )
    % load the component reference 
    p = obj.propertypaneleditablecomponents.GetObjRef( k );
    if flag( k )
        count = count + 1;
        % create a listener 
        newListener = addlistener(p, 'String', 'PostSet', @(src, evt)obj.internalPropertyEditableCallback(src, evt, count, p));
        % save the newListener
        obj.propertycomptlisteners.add( newListener );
    end
end
if ~isempty( obj.previewlistener )
    % destroy it now 
    obj.previewlistener.delete();
end
if ~isempty( obj.exportlistener )
    obj.exportlistener.delete();
end
switch obj.currentModeState
    case 1
        obj.previewlistener = addlistener( obj.previewcomponent, ...
            'Value', 'PostSet', @obj.internalExportShape);
        obj.exportlistener = addlistener( obj.exportcomponent, ...
            'Value', 'PostSet', @obj.internalExportShapeToConcreteContainer);
    case 3
        obj.previewlistener = addlistener( obj.previewcomponent, ...
            'Value', 'PostSet', @obj.internalExportText);
        obj.exportlistener = addlistener( obj.exportcomponent, ...
            'Value', 'PostSet', @obj.internalExportTextToConcreteContainer );
    case 4
        obj.previewlistener = addlistener( obj.previewcomponent, ...
            'Value', 'PostSet', @obj.internalExportArrowText);
        obj.exportlistener = addlistener( obj.exportcomponent, ...
            'Value', 'PostSet', @obj.internalExportArrowTextToConcreteContainer );
    case 5
        obj.previewlistener = addlistener( obj.previewcomponent, ...
            'Value', 'PostSet', @obj.internalExportCircle);
        obj.exportlistener = addlistener( obj.exportcomponent, ...
            'Value', 'PostSet', @obj.internalExportCircleToConcreteContainer );
end