function internalOutputSetListener( obj )

if ~isempty( obj.panelstringmodlistener )
    obj.panelstringmodlistener.delete();
end
if ~isempty( obj.editableobj )
    obj.panelstringmodlistener = addlistener( obj.editableobj, ...
        'String', 'PostSet', @obj.internalOutputCallback );
end