function addpoint( obj, pos )
% add anchor point
while ~isnumeric( pos )
    pos = pos.position;
end
% since 'point' is simply a ghost point, one may not need to enable the
% canvas to capture it. 
captureIsEnabled = obj.parent.canvasEnabledCapture();
if captureIsEnabled, obj.parent.setEnableCapture( 'off' );end
point = SchematicCircle( obj.parent, 'circle');

n = obj.pointManager.getSize();
point.name = n + 1; % use numeric identifier
point.setCircleGeometry( pos );
obj.pointManager.add( point );

% create a reference to the last point being added
obj.lastPointAdded = point;
if captureIsEnabled, obj.parent.setEnableCapture( 'on' ); end