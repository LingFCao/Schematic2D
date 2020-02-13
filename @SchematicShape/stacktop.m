function stacktop( obj )

if ~isempty( obj.shape ),            uistack( obj.shape, 'top' ); end
if ~isempty( obj.vectorOfPatches ),  uistack( obj.vectorOfPatches, 'top' ); end