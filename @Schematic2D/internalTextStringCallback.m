function internalTextStringCallback( obj, ~, ~ )

string = obj.editableobj.String;
% check the current mode ... 
if strcmpi( obj.currentMode, 'text' )
    obj.plainTextSchematicObj.setText( string, ...
        'fontsize', 17, 'interpreter','latex' );
elseif strcmpi( obj.currentMode, 'arrowtext' )
    obj.arrowTextSchematicObj.setText( string, ...
        'fontsize', 17, 'interpreter', 'latex' );
end

set( obj.savepanel,   'visible', 'off');
set( obj.editableobj, 'string',    '');