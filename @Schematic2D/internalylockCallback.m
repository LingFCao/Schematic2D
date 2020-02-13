function internalylockCallback( obj, ~, ~ )
% a simple 'ylock' callback. If the 'ylock' property is set to true, then
% we turn the visibility of the xlock panel to true, else it remains off.

if obj.ylock
    % switch on the xlock panel
    set( obj.ylockUIDisp, 'visible', 'on' );
else
    set( obj.ylockUIDisp, 'visible', 'off');
end