function stacktop( obj )

if ~isempty( obj.body  ), uistack( obj.body, 'top' ); end
if ~isempty( obj.arrow ), uistack( obj.arrow,'top' ); end
if ~isempty( obj.VectorOfPatch ), uistack( obj.VectorOfPatch, 'top' ); end