function atomicRotate( obj, pivot, angle )

if ~isempty( obj.position ) && ~isempty( obj.radius )
    R = [cos( angle ), -sin( angle ); +sin( angle ), cos( angle ) ];
    newpos = pivot.' + R * (obj.position - pivot).';
    obj.draw( 'position', newpos.' );
end