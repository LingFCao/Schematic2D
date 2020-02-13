function ylowerboundcallback( obj, ~, ~, q )

string = q.String;
n      = str2double( string );
if ~isnan( n ), obj.ylowerbound = n; end