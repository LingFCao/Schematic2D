function [I, J] = getDirectionalIndices( i, j, imax, jmax, s, direction )
% compute the pixel coordinates given by the 'direction'. s denotes the
% number of extending pixels. For example 
% 
%  'east' (eastward direction):
%
%                             [] [] [] ... []
%                            ...    
%                             [] [] [] ... []
%                             [] [] [] ... []
%                       (i,j) [] [] [] ... []
%                             [] [] [] ... []
%                             [] [] [] ... []
%                             ...  
%                             [] [] [] ... []
% 
%  [] = pixel
%
%  another example 'southeast':
%                       (i,j) [] [] [] ... []
%                             .      .     .
%                             .        .   .
%                             .          . .
%                             []  .  .  .  []
switch direction
    case 'north' 
        [I_, J_] = meshgrid(i - s : i + 0, j - s : j + s);
    case 'south'
        [I_, J_] = meshgrid(i + 1 : i + s, j - s : j + s );
    case 'east'
        [I_, J_] = meshgrid(i - s : i + s, j + 0 : j + s );
    case 'west'
        [I_, J_] = meshgrid(i - s : i + s, j - s : j + 0 );
    case 'northwest'
        [I_, J_] = meshgrid(i - s : i + 0, j - s : j + 0 );
    case 'northeast'
        [I_, J_] = meshgrid(i - s : i + 0, j - 0 : j + s );
    case 'southwest'
        [I_, J_] = meshgrid(i + 0 : i + s, j - s : j + 0 );
    case 'southeast'
        [I_, J_] = meshgrid(i + 0 : i + s, j - 0 : j + s );
end

flag = ( I_ > 0 & I_ <= imax ) & (J_ > 0 & J_ <= jmax ) & (I_ ~= i & J_ ~= j );

I   = I_( flag );
J   = J_( flag );