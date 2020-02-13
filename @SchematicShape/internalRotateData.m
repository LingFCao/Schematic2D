function internalRotateData( obj, pivot, angle )
% rotate the raw data by a certain angle relative to the pivot
if ~isnumeric( pivot )
    % if pivot is not numeric, then it must have a 'position' property
    pivot = pivot.position;
end

R = [cos( angle ), -sin( angle ); +sin( angle ), cos( angle ) ];

V = [obj.xRawData - pivot(1); obj.yRawData - pivot(2)];
V = R * V;
xraw = V(1, :) + pivot(1);
yraw = V(2, :) + pivot(2);

% check that the resulting data fits the canvas

obj.internalCheckAndScaleDataRelativeToCentroid( xraw, yraw );