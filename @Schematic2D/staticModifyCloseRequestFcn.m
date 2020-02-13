function staticModifyCloseRequestFcn( ~, ~, canvas )
% modifies the close request behaviour. This affects the figure window when
% the user clicks the 'close' button ... 

% canvas.setSaveWindowProperties( 'visible', 'off' );
set( canvas, 'visible', 'off' );
