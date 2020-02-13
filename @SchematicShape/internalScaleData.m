function internalScaleData( obj, pivot, scalefactor )
% scale the supplied data relative to the pivot. The scaling formula is
% given by:
%    x' = x* + \lambda * (x - x*)
% where x' is the scaled position, x* is the pivot point and \lambda is the
% scale factor.
% Routine does not check the availability of the supplied raw data. This is
% left to the more front-end routines that make use of the scaling.

while ~isnumeric( pivot )
    % if pivot is not numeric, then it must have a 'position' property ... 
    pivot = pivot.position;
end

xraw = pivot(1) + scalefactor * ( obj.xRawData - pivot(1) );
yraw = pivot(2) + scalefactor * ( obj.yRawData - pivot(2) );
% scale the anchor position
obj.position.setCircleGeometry( pivot + scalefactor * ( obj.position.position - pivot ) );


% for the final check
obj.internalCheckAndScaleDataRelativeToCentroid( xraw, yraw );