function stacktop( obj )
% stack on top of the current graph

if ~isempty( obj.rightLine ), uistack( obj.rightLine, 'top' ); end
if ~isempty( obj.arrowhead ), uistack( obj.arrowhead, 'top' ); end
if ~isempty( obj.textBox   ), uistack( obj.textBox,   'top' ); end