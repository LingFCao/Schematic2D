function move( obj, transVec )
% translate the selected objects in their respective containers.

if ~obj.SelectedSchematic.isContainerEmpty()
%     currentobj = obj.SelectedSchematic.getFirstRef();
%     while ~isempty( currentobj )
%         currentobj.translate( transVec );
%         % get the forward associate ... 
%         currentobj = currentobj.getDoublyLinkedAssociate( 'forward' );
%     end
    for p = obj.SelectedSchematic.getAll()
        p.translate( transVec );
    end
end
% once a 'move' occured, nullify the selection vector
obj.internalCapturedSelection = [];
notify( obj, 'deselectedObjects' );