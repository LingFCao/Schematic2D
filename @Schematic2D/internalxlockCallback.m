function internalxlockCallback( obj, ~, ~ )
% a simple 'xlock' callback. If the 'xlock' property is set to true, then
% we turn the visibility of the xlock panel to true, else it remains off.

if obj.xlock
    % switch on the xlock panel
    set( obj.xlockUIDisp, 'visible', 'on' );
else
    set( obj.xlockUIDisp, 'visible', 'off');
end