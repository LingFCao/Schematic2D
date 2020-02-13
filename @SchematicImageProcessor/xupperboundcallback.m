function xupperboundcallback( obj, ~, ~, q )

string = q.String;
n      = str2double( string );
if ~isnan( n ), obj.xupperbound = n; end