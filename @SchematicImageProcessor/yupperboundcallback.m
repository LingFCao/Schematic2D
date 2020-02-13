function yupperboundcallback( obj, ~, ~, q )

string = q.String;
n      = str2double( string );
if ~isnan( n ), obj.yupperbound = n; end