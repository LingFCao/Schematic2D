function internalTextInitialization( obj )
% The initialization of 'text' mode. This mode allows an instant annotation
% to be placed on the canvas.

% avoid the line being captured by the canvas

captureIsEnabled = obj.canvasEnabledCapture();
if captureIsEnabled, obj.setEnableCapture( 'off' ); end

obj.plainTextSchematicObj = ...
    SchematicLine( obj, 'straighttextbox', 'color', 'none');

% configurate the default textbox 
% obj.plainTextSchematicObj.setTextboxSize( .031, .031 );
obj.plainTextSchematicObj.setProperties( 'textbox', 'backgroundcolor', 'none', 'edgecolor', 'none');

if strcmpi( obj.arrowTextModeStyle, 'arrow' )
    % initialize with a single arrow head
    obj.arrowTextSchematicObj = SchematicLine( obj, ...
        'singlearrowtextbox', ...
        'Color', 'k', ...
        'linewidth', 1.2, ...
        'linestyle', '-');
elseif strcmpi( obj.arrowTextModeStyle, 'plain' )
    obj.arrowTextSchematicObj = SchematicLine( obj, ...
        'straighttextbox', ...
        'Color', 'k', ...
        'linewidth', 1.2, ...
        'linestyle', '-' );
else
    error( ...
        'SchematicTools:Canvas:illegalkeyword', ...
        'The ''arrowTextModeStyle'' property must be set to either: ''arrow'' or ''plain''!');
end
% obj.arrowTextSchematicObj.setTextboxSize( .031, .031 );
obj.arrowTextSchematicObj.setProperties( 'textbox', 'backgroundcolor', 'none', 'edgecolor', 'none', 'interpreter', 'latex');


if captureIsEnabled, obj.setEnableCapture( 'on' ); end