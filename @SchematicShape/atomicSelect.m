function isObjSelected = atomicSelect( obj, pos, offset )
% check if current position is contained within the object body...

defaultOffSet = 0;
if nargin > 2, defaultOffSet = offset; end

isObjSelected = false;
if isempty( obj.xRawData ) || isempty( obj.yRawData )
    return;
end

xmin = min( obj.xRawData ); xmax = max( obj.xRawData );
ymin = min( obj.yRawData ); ymax = max( obj.yRawData );

x = pos(1);
y = pos(2);
isObjSelected = ...
    xmin - defaultOffSet <= x && x <= xmax + defaultOffSet && ...
    ymin - defaultOffSet <= y && y <= ymax + defaultOffSet;
if isObjSelected
    notify( obj, 'selectedState' );
end