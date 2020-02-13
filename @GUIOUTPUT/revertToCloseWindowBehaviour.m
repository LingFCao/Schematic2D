function revertToCloseWindowBehaviour( obj )
% revert back to the default closeWindow request behaviour. 

set( obj.Fig, 'CloseRequestFcn', 'closereq' );