function atomicScale( obj, pivot, scale )

if ~isempty( obj.position ) && ~isempty( obj.radius )
    newpos = pivot + scale * ( obj.position - pivot );
    newrad = scale * obj.radius;
    obj.draw('position', newpos, 'radius', newrad);
end