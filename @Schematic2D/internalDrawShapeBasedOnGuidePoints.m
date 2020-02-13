function internalDrawShapeBasedOnGuidePoints( obj )
% create an open/close 'SchematicShape' based on the current guide point

% do nothing if click counter is than 2 
if obj.ClickCounter < 2, return; end
captureStateIsEnabled = obj.canvasEnabledCapture();

if captureStateIsEnabled, obj.setEnableCapture( 'off' ); end
if obj.ClickCounter == 2
    % check that if the previously created holder is of 'SchematicLine' ...
    % 
    if ~isempty( obj.tmpShapeHolder ) && ~isa( obj.tmpShapeHolder, 'SchematicLine' )
        % destroy the object now
        obj.tmpShapeHolder.deleteObj();
        obj.tmpShapeHolder = [];
    end
    if isempty( obj.tmpShapeHolder )
        % either it is empty from the beginning or is previously destroyed
        % in any case, we need to recreate it
        
        % we create a 'SchematicLine' object
        obj.tmpShapeHolder = SchematicLine( obj, 'straight', ...
            'color', 'b', 'linewidth', 1.2, 'linestyle', '-.' );
        
    end
    obj.tmpShapeHolder.draw( ...
        'start', obj.ClickedPointContainer.getFirstRef(), ...
        'end'  , obj.ClickedPointContainer.getLastRef( ) );
    % holder is active ... 
    obj.holderIsActive = true;
    if captureStateIsEnabled, obj.setEnableCapture( 'on' ); end
    return;
end

% one can construct the open - parametrized curve
curveStyle = 'open';
if ~obj.AlwaysConstructOpenCurve, curveStyle = 'close'; end

% perform the same check again 
if ~isempty( obj.tmpShapeHolder ) && ~isa( obj.tmpShapeHolder, 'SchematicShape')
    % destroy the object and rebuild it from scratch ... 
    obj.tmpShapeHolder.deleteObj(); 
    obj.tmpShapeHolder = [];
end
if isempty( obj.tmpShapeHolder )
    obj.tmpShapeHolder = SchematicShape( obj, curveStyle, ...
        'color', 'b', 'linewidth', 1.2, 'linestyle', '-.' );
end
for p = obj.ClickedPointContainer.getAll()
    obj.tmpShapeHolder.addpoint( p );
end
obj.tmpShapeHolder.make();
obj.tmpShapeHolder.draw();

obj.holderIsActive = true;
if captureStateIsEnabled, obj.setEnableCapture( 'on' ); end