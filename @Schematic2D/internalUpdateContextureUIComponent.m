function internalUpdateContextureUIComponent( obj )

if obj.currentModeState < 3
    if ~isempty( obj.textuiele )
        set( obj.textuiele, 'string', 'save as:' );
    end
else
    if ~isempty( obj.textuiele )
        set( obj.textuiele, 'string', 'text as:' );
    end
end