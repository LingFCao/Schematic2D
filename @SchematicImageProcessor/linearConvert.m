function [xp, yp] = linearConvert(   obj, xr, yr         )
% handles the conversion between raw 'xr' and 'yr' to physical data 'xp'
% and 'yp'. 
% 
% we assume that the image is properly calibrated, so that the internal
% properties 'x1', 'x2', 'y1' and 'y2' exists

% define the coordinate vectors in each direction
rx  = norm( obj.x2 - obj.x1 );
ry  = norm( obj.y2 - obj.y1 );
ex = (obj.x2 - obj.x1) / rx;
ey = (obj.y2 - obj.y1) / ry;

% project the xr and yr to these two directions (note that xr and yr in
% general are vectors or matrices, so can't just simply invoke the 'dot'
% routine)
x   = (xr - obj.x1(1) ) * ex(1) + (yr - obj.x1(2) ) * ex(2);
y   = (xr - obj.y1(1) ) * ey(1) + (yr - obj.y1(2) ) * ey(2);
% normalize x and y 
x   = x / rx;
y   = y / ry;
% so 
xp  = obj.xlowerbound + ( obj.xupperbound - obj.xlowerbound ) * x;
yp  = obj.ylowerbound + ( obj.yupperbound - obj.ylowerbound ) * y;