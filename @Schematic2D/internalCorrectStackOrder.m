function internalCorrectStackOrder( obj )
% restack each component to make sure that the stack order is consistent!

currentelement = obj.schematicContainer.getFirstRef();
while ~isempty( currentelement )
    currentelement.stacktop(); 
    currentelement = currentelement.getDoublyLinkedAssociate( 'forward' );
end