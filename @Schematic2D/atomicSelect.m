function atomicSelect( obj, pos )
% returns once a hit is found

isSelected = false;
if ~obj.schematicContainer.isContainerEmpty()
    q = obj.schematicContainer.getAll();
    for p = q(end:-1:1)
        if p.atomicSelect( pos ), obj.atomicSelectedObj = p; isSelected = true; break; end
    end
end
if ~isSelected
    % if no object is selected, skip the second click
    obj.selectionAddAnchor( obj.FirstAnchorPosition );
end