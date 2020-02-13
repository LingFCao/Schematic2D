function resortNumericNameOfGuides( obj )

obj.ClickCounter = obj.ClickedPointContainer.getSize();
if ~obj.ClickedPointContainer.isContainerEmpty()
    count = 0;
    for p = obj.ClickedPointContainer.getAll()
        count = count + 1;
        p.name = count;
    end
    % the last added point is relocated to the point with the largest name
    % count ... 
    obj.lastCreatedPoint = obj.ClickedPointContainer.getLastRef();
    % reset the text
    count = 0;
    for p = obj.ClickedPointTextContainer.getAll()
        count = count + 1;
        p.name = count;
        p.setText( num2str( count ) );
    end
    obj.lastCreatedPointText = obj.ClickedPointTextContainer.getLastRef();
end