function setText( obj, CharArray )
% set title text. Title object must exist

assert( ~isempty( obj.CounterTextObject ) || ~obj.CounterTextObject.isvalid, ...
    'GUIOUTPUT:Text:invalidObject', ...
    'Title object is not available');

set( obj.CounterTextObject, 'string', CharArray);