function [I, J] = getpixelind( tx, ty, i, j, imax, jmax, s)
% This function returns the pixel coordinates specified by the direction
% vector [tx, ty] and a bounding length 's' in normalized unit. 

% Convert i and j to normalized coordinate
xi = ( j - 1 )   / ( jmax - 1 );
yj = (imax - i ) / ( imax - 1 );
% creat the transformation matrix (note that we require theta to be in the
% range 0 to 2 * pi)
theta = atan2(ty, tx);  
if theta < 0, theta = theta + 2 * pi; end
% ds is the half-pixel length
ds = .5 * min( 1/imax, 1/jmax);
% create a mesh grid
[x, y] = meshgrid( -s/2 : ds : s/2, -s/2 : ds : s/2); 
% deactivate those points with -x > y with an offset '3'. This seems to
% produce acceptable result. Modify it if need be.
flag = y > 3 * ds - x;
x    = x( flag );
y    = y( flag );
% create the rotation matrix such that [tx, ty] subtending a 45[deg] angle
% with respect to the x-axis
cs   = cos( theta - pi/4 ); 
ss   = sin( theta - pi/4 ); 
% RR is anti-clockwise
RR   = [ cs, -ss; ss, cs];
% incases that x and y are not row-vectors
x    = x(:);
y    = y(:);
u    = RR * [x.';y.'];
% extract the adjusted x and y coordinates
x    = xi + u(1, :);
y    = yj + u(2, :);
% transform back to I and J indices
J    = 1 + floor(    (jmax - 1) * x );
I    = imax - floor( (imax - 1) * y );
% check for duplicates ...
V    = unique( [I', J'], 'row' );
I    = V(:, 1);
J    = V(:, 2);
% only return those pixels within bounds
flag = ( I > 0 & I <= imax ) & ( J > 0 & J <= jmax );
I    = I( flag );
J    = J( flag );
% note the end results are col-vectors