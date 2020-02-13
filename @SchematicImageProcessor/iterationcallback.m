function iterationcallback( obj, ~, ~, q)
% simple iteration callback function when the 'iteration' field is modified
% 
string = q.String;
n      = str2double( string );
if ~isnan( n )
    n = abs( n ); n = floor( n );
    if n < 1, return; end
    obj.maxIteration = n;
end