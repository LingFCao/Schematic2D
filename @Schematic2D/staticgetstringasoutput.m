function stringoutput = staticgetstringasoutput( input )
if ischar(   input  ), stringoutput = getstringstring( input );  return; end
if isnumeric( input ), stringoutput = getnumericstring( input ); return; end
if islogical( input ), stringoutput = getbooleanstring( input ); return; end


function booleanstring = getbooleanstring( bool )
% get boolean string
if bool, booleanstring = 'true'; else, booleanstring = 'false'; end

function stringstring  = getstringstring( string )

stringstring = ['''', string, ''''];


function numericstring = getnumericstring( data )

if isscalar( data ), numericstring = num2str( data ); return; end
if isvector( data ), numericstring = ['[ ', num2str( data ), ' ]' ]; return; end


