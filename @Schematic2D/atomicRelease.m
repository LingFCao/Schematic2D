function atomicRelease( obj )
% release, atomically, the special holder in the 'atomicSelectedObj'
% property of the canvas

% check if it is non-empty 
if ~isempty( obj.atomicSelectedObj ), obj.atomicSelectedObj = []; end