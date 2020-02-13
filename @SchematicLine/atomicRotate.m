function atomicRotate( obj, pivot, angle )


R = [cos( angle ), -sin( angle ); +sin( angle ), cos( angle ) ];

V = pivot.' + R * [ (obj.internalStartPosition - pivot).', ( obj.internalFinalPosition - pivot).' ];

obj.draw( ...
    'start', V(:,1).', ...
    'end',   V(:,2).' );