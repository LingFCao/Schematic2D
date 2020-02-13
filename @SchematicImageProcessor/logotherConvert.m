function [xp, yp] = logotherConvert( obj, xr, yr, otherid)
% either 'semilogy'  - y is log, x is linear
%        'semilogx'  - y is linear, x is log
%        'loglog'    - y is log, x is log
% one important feature of the log axis is that the distance measured from 
% a tic scales logarithmically. Namely, the normalized distance r is
% given by r = log10( x / 10^n ); so if one knows the normalized distance,
% then x is computed by inverting the log10. i.e. 10^( r + n )
% 
% In a nutshell, if \alpha and \beta are the registered coordinates, then
% one extracts the physical coordinate as \alpha * ( \beta / \alpha )^R,
% where R = (x - x1) / (x2 - x1)

% first we project the raw position to the directions as outlined in the
% linear routine
rx  = norm( obj.x2 - obj.x1 );
ry  = norm( obj.y2 - obj.y1 );
ex = ( obj.x2 - obj.x1 ) / rx;
ey = ( obj.y2 - obj.y1 ) / ry;

% obtain the local x and y coordinates
x  = (xr - obj.x1(1)) * ex(1) + (yr - obj.x1(2)) * ex(2);
y  = (xr - obj.y1(1)) * ey(1) + (yr - obj.y1(2)) * ey(2);
% normalize x and y 
x  = x / rx;  % so 0 <= x <= 1
y  = y / ry;

switch lower( otherid )
    case 'semilogy'
        yp = log2linear(y, obj.ylowerbound, obj.yupperbound);
        xp = obj.xlowerbound + ( obj.xupperbound - obj.xlowerbound ) * x;
    case 'semilogx'
        xp = log2linear(x, obj.xlowerbound, obj.xupperbound);
        yp = obj.ylowerbound + ( obj.yupperbound - obj.ylowerbound ) * y;
    case 'loglog'
        xp = log2linear(x, obj.xlowerbound, obj.xupperbound);
        yp = log2linear(y, obj.ylowerbound, obj.yupperbound);
    otherwise
        error( ...
            'SchematicTools:ImageProcessor:illegalkeyword', ...
            'keyword not recognised!');
end


function y = log2linear(R, alp, bet)
y = alp * (bet /alp).^R;