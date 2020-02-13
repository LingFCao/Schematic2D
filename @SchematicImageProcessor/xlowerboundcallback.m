function xlowerboundcallback( obj, ~, ~, q )

string = q.String;
n      = str2double( string );
if ~isnan( n ), obj.xlowerbound = n; end