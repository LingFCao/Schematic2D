function internalTextReset( obj )
% reset both the plain and arrow-style text object ...

if ~isempty( obj.plainTextSchematicObj )
    obj.plainTextSchematicObj.setText('');
    obj.plainTextSchematicObj.turn( 'off' ); 
end
if ~isempty( obj.arrowTextSchematicObj )
    obj.arrowTextSchematicObj.setText('');
    obj.arrowTextSchematicObj.turn( 'off' ); 
end