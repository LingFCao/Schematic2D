function internalOutputCallback( obj, ~, ~ )

string = obj.editableobj.String;
% check if the string is a valid string
if strcmpi( string, '' ), return; end
obj.internalOutputContainerToScript( string );

set( obj.savepanel,   'visible', 'off' );
set( obj.editableobj, 'string',     '' );