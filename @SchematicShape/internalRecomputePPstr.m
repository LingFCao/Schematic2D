function internalRecomputePPstr( obj, ~, ~ )
% only be called by the call-back. This routine computes the
% interpolating spline structure

% only computes the ppstr if style is open
if strcmpi( obj.style, 'open' )
    S = getArcData( obj.xRawData, obj.yRawData );
    obj.ppstr = ...
        spline( S, [ obj.xRawData; obj.yRawData ] );
    obj.arcLength = S( end );
end
% recompute anchor position if need be
if ~obj.useCustomAnchor
    % only set anchor of this type
    numberOfElement = numel( obj.xRawData );
    xcentroid = sum( obj.xRawData ) / numberOfElement;
    ycentroid = sum( obj.yRawData ) / numberOfElement;
    obj.position.setCircleGeometry( [xcentroid, ycentroid] ); 
end

function Sdata = getArcData( xraw, yraw)

x0 = xraw(1); y0 = yraw(1); % set anchor point
Sdata = zeros( size( xraw ) );
for k = 2 : numel( xraw )
    s = norm( [xraw( k ) - x0, yraw( k ) - y0 ] );
    Sdata( k ) = Sdata( k - 1 ) + s;
    x0 = xraw( k );
    y0 = yraw( k );
end