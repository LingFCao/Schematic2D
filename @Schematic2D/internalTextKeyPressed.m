function internalTextKeyPressed( obj, key )
mapref = obj.keyMap;

switch lower( key )
    case mapref.resetTemporaryTextHolder
        % simply resets the text-container
        obj.internalTextReset();
        
    case mapref.bringUpTextEditor
        % bring out the property-panel ... 
        obj.internalPropertyPanelInitialize();
end