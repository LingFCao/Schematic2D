function atomicScale( obj, pivot, scale )

% simple scale

newstart = pivot + scale * ( obj.internalStartPosition - pivot );
newfinal = pivot + scale * ( obj.internalFinalPosition - pivot );

% redraw now
obj.draw( 'start', newstart, 'end', newfinal );