function internalSetDoubleArrowTextBox( obj, startPosition, endPosition )
obj.internalSetDoubleArrow( startPosition, endPosition );
MidCoord = .5 * ( startPosition + endPosition );
if isempty( obj.textBox )
    obj.addtextbox( MidCoord );
else
    % move textbox to the mid-coord position ...
    obj.movetextbox( MidCoord );
end